package de.zweidenker.p2p.connection.bluetooth

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothSocket
import de.zweidenker.p2p.P2PModule
import de.zweidenker.p2p.connection.http.ConnectionStream
import de.zweidenker.p2p.connection.http.HttpWrapper
import de.zweidenker.p2p.connection.http.SimpleHttp1Codec
import de.zweidenker.p2p.model.Device
import okhttp3.internal.http.HttpCodec
import okio.Okio
import java.io.IOException

class BluetoothConnectionStream(
    private val device: Device
): ConnectionStream {

    private var lastBluetoothSocket: BluetoothSocket? = null

    override fun newCodec(httpWrapper: HttpWrapper): HttpCodec {
        val socket = try {
            connect()
        } catch (e: Exception) {
            throw IOException(e)
        }
        lastBluetoothSocket = socket

        val bluetoothSource = Okio.buffer(Okio.source(socket.inputStream))
        val bluetoothSink = Okio.buffer(Okio.sink(socket.outputStream))
        return SimpleHttp1Codec(httpWrapper, bluetoothSource, bluetoothSink)
    }

    private fun connect(): BluetoothSocket {
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

        //val socket = bluetoothDevice.createInsecureRfcommSocketToServiceRecord(beaconDevice.bluetoothDetails.uuid)
        val method = bluetoothDevice::class.java.getMethod("createInsecureRfcommSocket", Int::class.javaPrimitiveType)
        val socket = method.invoke(bluetoothDevice, 20) as BluetoothSocket

        socket.connect()
        return socket
    }
}