package de.zweidenker.p2p.connection.usb

import de.zweidenker.p2p.connection.http.ConnectionStream
import de.zweidenker.p2p.connection.http.SimpleConnectionProvider
import de.zweidenker.p2p.model.Device

class USBConnectionProvider: SimpleConnectionProvider("usb") {

    override fun httpStreamFor(device: Device): ConnectionStream {
        return USBConnectionStream()
    }
}