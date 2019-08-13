package de.zweidenker.p2p.connection.bluetooth

import android.bluetooth.BluetoothSocket
import java.io.InputStream
import java.io.OutputStream
import java.net.InetAddress
import java.net.SocketAddress
import java.net.SocketImpl

class WrappingBluetoothSocketImpl(
    private val bluetoothSocket: BluetoothSocket
) : SocketImpl() {

    override fun listen(backlog: Int) {
        throw UnsupportedOperationException("Listen is not supported on a BluetoothSocket!")
    }

    override fun getOption(optID: Int): Any? {
        // throw UnsupportedOperationException("GetOption is not supported on a BluetoothSocket!")
        return null
    }

    override fun create(stream: Boolean) { }

    override fun setOption(optID: Int, value: Any?) {
        // throw UnsupportedOperationException("SetOption is not supported on a BluetoothSocket!")
    }

    override fun connect(host: String?, port: Int) {
        bluetoothSocket.connect()
    }

    override fun connect(address: InetAddress?, port: Int) {
        bluetoothSocket.connect()
    }

    override fun connect(address: SocketAddress?, timeout: Int) {
        bluetoothSocket.connect()
    }

    override fun bind(host: InetAddress?, port: Int) {
        throw UnsupportedOperationException("Bind is not supported on a BluetoothSocket!")
    }

    override fun accept(s: SocketImpl?) {
        throw UnsupportedOperationException("Accept is not supported on a BluetoothSocket!")
    }

    override fun getOutputStream(): OutputStream {
        return bluetoothSocket.outputStream
    }

    override fun available(): Int {
        return 0
    }

    override fun sendUrgentData(data: Int) {
        throw UnsupportedOperationException("SendUrgentData is not supported on a BluetoothSocket!")
    }

    override fun getInputStream(): InputStream {
        return bluetoothSocket.inputStream
    }

    override fun close() {
        return bluetoothSocket.close()
    }
}