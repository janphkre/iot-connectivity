package de.zweidenker.p2p.connection.bluetooth

import de.zweidenker.p2p.connection.http.ConnectionStream
import de.zweidenker.p2p.connection.http.SimpleConnectionProvider
import de.zweidenker.p2p.model.Device

class BluetoothConnectionProvider : SimpleConnectionProvider("bluetooth") {

    override fun httpStreamFor(device: Device): ConnectionStream {
        return BluetoothConnectionStream(device)
    }
}