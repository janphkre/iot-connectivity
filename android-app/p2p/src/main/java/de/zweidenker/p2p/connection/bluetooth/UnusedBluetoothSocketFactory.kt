package de.zweidenker.p2p.connection.bluetooth

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothSocket
import de.zweidenker.p2p.P2PModule
import de.zweidenker.p2p.model.Device
import java.net.InetAddress
import java.net.Socket
import java.net.SocketImpl
import javax.net.SocketFactory

@Deprecated("Use the BluetoothConnectionStream instead")
class UnusedBluetoothSocketFactory(
    private val device: Device
) : SocketFactory() {

    private class WrappingSocket(socketImpl: SocketImpl) : Socket(socketImpl)

    override fun createSocket(): Socket {
        val bluetoothAdapter: BluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
            ?: throw UnsupportedOperationException("Device does not support Bluetooth")

        if (!bluetoothAdapter.isEnabled) {
            bluetoothAdapter.enable()
            Thread.sleep(P2PModule.BLUETOOTH_ENABLE_SLEEP_MS)
        }

        val bluetoothDevice = bluetoothAdapter.bondedDevices?.firstOrNull { bluetoothDevice ->
            bluetoothDevice.address == device.bluetoothDetails.mac
        } ?: bluetoothAdapter.getRemoteDevice(device.bluetoothDetails.mac)

        bluetoothAdapter.cancelDiscovery()

        val method = bluetoothDevice::class.java.getMethod("createInsecureRfcommSocket", Int::class.javaPrimitiveType)
        val socket = method.invoke(bluetoothDevice, device.bluetoothDetails.port) as BluetoothSocket

        return WrappingSocket(UnusedWrappingBluetoothSocketImpl(socket))
    }

    override fun createSocket(host: String?, port: Int): Socket {
        val socket = createSocket()
        socket.connect(null)
        return socket
    }

    override fun createSocket(host: String?, port: Int, localHost: InetAddress?, localPort: Int): Socket {
        return createSocket(host, port)
    }

    override fun createSocket(host: InetAddress?, port: Int): Socket {
        return createSocket(host, port)
    }

    override fun createSocket(address: InetAddress?, port: Int, localAddress: InetAddress?, localPort: Int): Socket {
        return createSocket(address?.hostName, port)
    }
}