package de.zweidenker.p2p.connection.bluetooth

import de.zweidenker.p2p.connection.http.SimpleConnectionProvider
import de.zweidenker.p2p.model.Device
import javax.net.SocketFactory

class BluetoothConnectionProvider : SimpleConnectionProvider() {

    override fun socketFactoryFor(device: Device): SocketFactory {
        return BluetoothSocketFactory(device)
    }
}