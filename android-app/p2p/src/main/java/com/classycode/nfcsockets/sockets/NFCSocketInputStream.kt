package com.classycode.nfcsockets.sockets

import android.util.Log

import com.classycode.nfcsockets.Constants

import java.io.IOException
import java.io.InputStream

/**
 * @author Alex Suzuki, Classy Code GmbH, 2017
 */
internal class NFCSocketInputStream(private val nfcSocket: NFCSocket) : InputStream() {
    private var isClosed: Boolean = false

    init {
        this.isClosed = false
    }

    @Throws(IOException::class)
    override fun read(b: ByteArray): Int {
        ensureNotClosed()
        return nfcSocket.readInternal(b, 0, b.size)
    }

    @Throws(IOException::class)
    override fun read(b: ByteArray, off: Int, len: Int): Int {
        ensureNotClosed()
        return nfcSocket.readInternal(b, off, len)
    }

    @Throws(IOException::class)
    override fun read(): Int {
        ensureNotClosed()
        val ar = ByteArray(1)
        val res = nfcSocket.readInternal(ar, 0, 1)
        return if (res > 0) {
            ar[0].toInt()
        } else {
            -1
        }
    }

    @Throws(IOException::class)
    override fun skip(n: Long): Long {
        throw IllegalStateException("skip not implemented")
    }

    @Throws(IOException::class)
    override fun available(): Int {
        Log.d(TAG, "NFCSocketInputStream.available()")
        return 0
    }

    @Throws(IOException::class)
    override fun close() {
        if (!isClosed) {
            isClosed = true

            // according to Socket.getInputStream documentation, closing the OutputStream
            // should close the socket
            nfcSocket.close()
        } else {
            Log.w(TAG, "Stream already closed")
        }
    }

    @Synchronized
    override fun mark(readlimit: Int) {
        throw IllegalStateException("mark not supported")
    }

    @Synchronized
    @Throws(IOException::class)
    override fun reset() {
        throw IOException("mark not supported")
    }

    override fun markSupported(): Boolean {
        return false
    }

    private fun ensureNotClosed() {
        if (isClosed) {
            throw IllegalStateException("OutputStream is closed")
        }
    }

    companion object {

        private val TAG = Constants.LOG_TAG
    }
}