package de.zweidenker.p2p.connection.nfc

import de.zweidenker.p2p.connection.http.ConnectionStream
import de.zweidenker.p2p.connection.http.DeprecatedSimpleConnectionProvider
import de.zweidenker.p2p.model.Device

class NFCConnectionProvider : DeprecatedSimpleConnectionProvider("nfc") {

    override fun httpStreamFor(device: Device): ConnectionStream {
        return NFCConnectionStream()
    }
}