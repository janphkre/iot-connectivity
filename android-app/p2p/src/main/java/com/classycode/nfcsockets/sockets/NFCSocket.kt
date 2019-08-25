package com.classycode.nfcsockets.sockets

import android.content.ContentValues.TAG
import android.os.Looper
import android.util.Log
import com.classycode.nfcsockets.NFCMessageProvider
import com.classycode.nfcsockets.messages.Close
import com.classycode.nfcsockets.messages.Connect
import com.classycode.nfcsockets.messages.ConnectResponse
import com.classycode.nfcsockets.messages.Recv
import com.classycode.nfcsockets.messages.RecvResponse
import com.classycode.nfcsockets.messages.Send
import com.classycode.nfcsockets.messages.SocketResponse
import com.classycode.nfcsockets.util.SocketResponseSubscriber
import org.koin.standalone.KoinComponent
import org.koin.standalone.inject
import timber.log.Timber
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.net.InetAddress
import java.net.InetSocketAddress
import java.net.Socket
import java.net.SocketAddress
import java.net.SocketException
import java.nio.channels.SocketChannel

/**
 * @author Alex Suzuki, Classy Code GmbH, 2017
 */
class NFCSocket : Socket, KoinComponent {

    private val illegalFd = -1

    private val provider by inject<NFCMessageProvider>()
    private var remoteFd: Int = 0

    private var socketAddress: InetSocketAddress? = null

    private var `in`: NFCSocketInputStream? = null
    private var out: NFCSocketOutputStream? = null

    constructor() {
        try {
            init(null, 0, false)
        } catch (e: IOException) {
            throw IllegalStateException("Creation of unconnected socket threw exception", e)
        }

    }

    @Throws(IOException::class)
    constructor(host: String, port: Int) {
        init(host, port, true)
    }

    @Throws(IOException::class)
    constructor(address: InetAddress, port: Int) {
        init(address.hostAddress, port, true)
    }

    @Throws(IOException::class)
    private fun init(host: String?, port: Int, connect: Boolean) {
        Log.d(TAG, "NFCSocket.init()")

        if (Thread.currentThread() === Looper.getMainLooper().thread) {
            throw IllegalStateException("Can not use NFC socket on main thread")
        }

        remoteFd = illegalFd
        try {
            if (connect) {
                doConnect(host, port)
            }
        } catch (ex: InterruptedException) {
            throw IOException("Interrupted while waiting for NFC socket", ex)
        }

    }

    @Throws(InterruptedException::class, IOException::class)
    private fun doConnect(host: String?, port: Int) {
        Log.d(TAG, "NFCSocket.doConnect($host, $port)")

        val subscriber = object : SocketResponseSubscriber() {
            override fun onResponse(response: SocketResponse) {
                if(response !is ConnectResponse) {
                    Timber.e("connect() returned different type: ${response::class}")
                    return
                }
                if (!response.isSuccess) {
                    Timber.e("connect() returned: $response")
                    return
                }
                remoteFd = response.res
                `in` = NFCSocketInputStream(this@NFCSocket)
                out = NFCSocketOutputStream(this@NFCSocket)
                socketAddress = InetSocketAddress(host, port)
            }
        }
        provider.socketRequest(Connect(host, port), subscriber)
        subscriber.awaitCompletion()
    }

    @Throws(IOException::class)
    override fun connect(endpoint: SocketAddress) {
        Timber.d("NFCSocket.connect()")
        val inetSocketAddress = endpoint as InetSocketAddress
        try {
            doConnect(inetSocketAddress.hostName, inetSocketAddress.port)
        } catch (ex: InterruptedException) {
            throw IOException("Interrupted while waiting for NFC socket", ex)
        }

    }

    @Throws(IOException::class)
    override fun connect(endpoint: SocketAddress, timeout: Int) {
        Timber.d("NFCSocket.connect()")
        val inetSocketAddress = endpoint as InetSocketAddress
        try {
            doConnect(inetSocketAddress.hostName, inetSocketAddress.port)
        } catch (ex: InterruptedException) {
            throw IOException("Interrupted while waiting for NFC socket", ex)
        }

    }

    @Throws(IOException::class)
    internal fun readInternal(b: ByteArray, off: Int, len: Int): Int {
        var resultCode: Int = -1
        val subscriber = object : SocketResponseSubscriber() {
            override fun onResponse(response: SocketResponse) {
                if(response !is RecvResponse) {
                    Timber.e("recv() returned different type: ${response::class}")
                    return
                }
                if (!response.isSuccess) {
                    Timber.e("recv() failed: ${response.res}")
                    return
                }
                Timber.d("Recv received " + response.res + " bytes")
                System.arraycopy(response.data, 0, b, off, response.res)
                resultCode = response.res
            }
        }
        provider.socketRequest(Recv(remoteFd, len), subscriber)
        subscriber.awaitCompletion()
        return resultCode
    }

    @Throws(IOException::class)
    internal fun writeInternal(b: ByteArray, off: Int, len: Int) {
        var numWrites = len / Send.MAX_DATA_SIZE_PER_WRITE
        if (len % Send.MAX_DATA_SIZE_PER_WRITE != 0) {
            numWrites += 1
        }
        Timber.d("Attempting to send $len bytes of data in $numWrites writes")
        for (i in 0 until numWrites) {
            val packetOffset = off + i * Send.MAX_DATA_SIZE_PER_WRITE
            val packetLength: Int = if (i == numWrites - 1) { // last one
                if (len % Send.MAX_DATA_SIZE_PER_WRITE == 0) {
                    Send.MAX_DATA_SIZE_PER_WRITE
                } else {
                    len % Send.MAX_DATA_SIZE_PER_WRITE
                }
            } else {
                Send.MAX_DATA_SIZE_PER_WRITE
            }

            Timber.d("Sending packet $i containing $packetLength bytes of data")

            val subscriber = object : SocketResponseSubscriber() {
                override fun onResponse(response: SocketResponse) {
                    if(response !is RecvResponse) {
                        Timber.e("send() returned different type: ${response::class}")
                        return
                    }
                    if (!response.isSuccess) {
                        Timber.e("send() failed: ${response.res}")
                        return
                    }
                   Timber.d("Send sent " + response.res + " bytes")
                    System.arraycopy(response.data, 0, b, off, response.res)
                }
            }
            provider.socketRequest(Send(remoteFd, b, packetOffset, packetLength), subscriber)
            subscriber.awaitCompletion()
        }
    }

    @Throws(IOException::class)
    override fun close() {
        if (remoteFd == illegalFd) {
            Log.w(TAG, "Socket already closed")
            return
        }

        val subscriber = object : SocketResponseSubscriber() {
            override fun onResponse(response: SocketResponse) {
                if(response !is RecvResponse) {
                    Timber.e("close() returned different type: ${response::class}")
                    return
                }
                if (!response.isSuccess) {
                    Timber.e("close() failed: ${response.res}")
                    return
                }
                Timber.d("Closed socket with remoteFd: $remoteFd")
                remoteFd = illegalFd
            }
        }
        provider.socketRequest(Close(remoteFd), subscriber)
        subscriber.awaitCompletion()
    }

    @Throws(IOException::class)
    override fun bind(bindpoint: SocketAddress) {
        throw IllegalStateException("Not implemented")
    }

    override fun getInetAddress(): InetAddress? {
        return if (socketAddress == null) {
            null
        } else socketAddress!!.address
    }

    override fun getLocalAddress(): InetAddress? {
        return null // TODO
    }

    override fun getPort(): Int {
        return if (socketAddress == null) {
            0
        } else socketAddress!!.port
    }

    override fun getLocalPort(): Int {
        throw IllegalStateException("Not implemented")
    }

    override fun getRemoteSocketAddress(): SocketAddress? {
        return socketAddress
    }

    override fun getLocalSocketAddress(): SocketAddress {
        throw IllegalStateException("Not implemented")
    }

    override fun getChannel(): SocketChannel {
        throw IllegalStateException("Not implemented")
    }

    @Throws(IOException::class)
    override fun getInputStream(): InputStream? {
        return `in`
    }

    @Throws(IOException::class)
    override fun getOutputStream(): OutputStream? {
        return out
    }

    @Throws(SocketException::class)
    override fun setTcpNoDelay(on: Boolean) {
    }

    @Throws(SocketException::class)
    override fun getTcpNoDelay(): Boolean {
        return false // TODO
    }

    @Throws(SocketException::class)
    override fun setSoLinger(on: Boolean, linger: Int) {
    }

    @Throws(SocketException::class)
    override fun getSoLinger(): Int {
        return -1
    }

    @Throws(IOException::class)
    override fun sendUrgentData(data: Int) {
        throw IllegalStateException("Not implemented")
    }

    @Throws(SocketException::class)
    override fun setOOBInline(on: Boolean) {
    }

    @Throws(SocketException::class)
    override fun getOOBInline(): Boolean {
        return false
    }

    @Synchronized
    @Throws(SocketException::class)
    override fun setSoTimeout(timeout: Int) {
        Timber.e("Timeouts are not implemented, ignoring setSoTimeout: $timeout")
    }

    @Synchronized
    @Throws(SocketException::class)
    override fun getSoTimeout(): Int {
        return 0
    }

    @Synchronized
    @Throws(SocketException::class)
    override fun setSendBufferSize(size: Int) {
    }

    @Synchronized
    @Throws(SocketException::class)
    override fun getSendBufferSize(): Int {
        return 2048 // TODO
    }

    @Synchronized
    @Throws(SocketException::class)
    override fun setReceiveBufferSize(size: Int) {
    }

    @Synchronized
    @Throws(SocketException::class)
    override fun getReceiveBufferSize(): Int {
        return 2048 // TODO
    }

    @Throws(SocketException::class)
    override fun setKeepAlive(on: Boolean) {
    }

    @Throws(SocketException::class)
    override fun getKeepAlive(): Boolean {
        return true
    }

    @Throws(SocketException::class)
    override fun setTrafficClass(tc: Int) {
    }

    @Throws(SocketException::class)
    override fun getTrafficClass(): Int {
        return 0x2 // IP_TOS_LOWCOST
    }

    @Throws(SocketException::class)
    override fun setReuseAddress(on: Boolean) {
    }

    @Throws(SocketException::class)
    override fun getReuseAddress(): Boolean {
        return false
    }

    @Throws(IOException::class)
    override fun shutdownInput() {
    }

    @Throws(IOException::class)
    override fun shutdownOutput() {
    }

    override fun toString(): String {
        val sb = StringBuilder("NFCSocket{")
        sb.append("remoteFd=").append(remoteFd)
        sb.append('}')
        return sb.toString()
    }

    override fun isConnected(): Boolean {
        return remoteFd != illegalFd
    }

    override fun isBound(): Boolean {
        throw IllegalStateException("Not implemented")
    }

    override fun isClosed(): Boolean {
        return remoteFd == illegalFd
    }

    override fun isInputShutdown(): Boolean {
        return false
    }

    override fun isOutputShutdown(): Boolean {
        return false
    }

    override fun setPerformancePreferences(connectionTime: Int, latency: Int, bandwidth: Int) {}
}
