package de.zweidenker.p2p.connection.bluetooth

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothSocket
import android.content.Context
import de.zweidenker.p2p.client.DeviceConfigurationProvider
import de.zweidenker.p2p.connection.DeviceConnectionProvider
import de.zweidenker.p2p.connection.http.SimpleConnectionStream
import de.zweidenker.p2p.connection.http.SimpleHttpWrapper
import de.zweidenker.p2p.model.Device
import okio.Okio
import rx.Observable

class BluetoothConnectionProvider: DeviceConnectionProvider {

    private var bluetoothConnection: SimpleConnectionStream? = null
    private var bluetoothSocket: BluetoothSocket? = null

    override fun connectTo(device: Device): Observable<DeviceConfigurationProvider> {
        return Observable.unsafeCreate<DeviceConfigurationProvider> { subscriber ->
            val socket = try {
                connect(device)
            } catch(e: Exception) {
                subscriber.onError(e)
                return@unsafeCreate
            }
            bluetoothSocket = socket

            val httpStream = SimpleConnectionStream(
                Okio.source(socket.inputStream),
                Okio.sink(socket.outputStream)
            )
                val simpleHttpWrapper = SimpleHttpWrapper.Builder()
                    .setHttpStream(httpStream)
                    .build()
                subscriber.onNext(DeviceConfigurationProvider.getInstance(simpleHttpWrapper, device, "bluetooth"))
                subscriber.onCompleted()

        }
    }

    private fun connect(beaconDevice: Device): BluetoothSocket {
        val bluetoothAdapter: BluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
            ?: throw UnsupportedOperationException("Device does not support Bluetooth")

        bluetoothAdapter.enable()

        val bluetoothDevice = bluetoothAdapter.bondedDevices?.firstOrNull { device ->
            device.address == beaconDevice.bluetoothDetails.mac
        } ?: bluetoothAdapter.getRemoteDevice(beaconDevice.bluetoothDetails.mac)

        //bluetoothDevice.setPairingConfirmation(false)
        val socket = bluetoothDevice.createRfcommSocketToServiceRecord(beaconDevice.bluetoothDetails.uuid)
        bluetoothAdapter.cancelDiscovery()
        socket.connect()
        return socket
    }

    override fun destroy(context: Context) {
        bluetoothConnection = null
        bluetoothSocket?.close()
        bluetoothSocket = null
    }
}