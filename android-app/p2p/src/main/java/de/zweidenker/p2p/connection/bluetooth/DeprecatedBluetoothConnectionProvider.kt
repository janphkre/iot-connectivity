package de.zweidenker.p2p.connection.bluetooth

import de.zweidenker.p2p.connection.http.ConnectionStream
import de.zweidenker.p2p.connection.http.DeprecatedSimpleConnectionProvider
import de.zweidenker.p2p.model.Device

@Deprecated("Use BluetoothConnectionProvider instead!")
class DeprecatedBluetoothConnectionProvider : DeprecatedSimpleConnectionProvider("bluetooth") {
    override fun httpStreamFor(device: Device): ConnectionStream {
        return BluetoothConnectionStream(device)
    }
}