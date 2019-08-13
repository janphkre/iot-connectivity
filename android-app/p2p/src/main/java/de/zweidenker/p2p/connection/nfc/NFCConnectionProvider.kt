package de.zweidenker.p2p.connection.nfc

import de.zweidenker.p2p.connection.http.ConnectionStream
import de.zweidenker.p2p.connection.http.SimpleConnectionProvider
import de.zweidenker.p2p.model.Device

class NFCConnectionProvider : SimpleConnectionProvider("nfc") {

    override fun httpStreamFor(device: Device): ConnectionStream {
        return NFCConnectionStream()
    }
}