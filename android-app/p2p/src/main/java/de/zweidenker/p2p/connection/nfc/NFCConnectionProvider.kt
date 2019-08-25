package de.zweidenker.p2p.connection.nfc

import com.classycode.nfcsockets.sockets.NFCSocketFactory
import de.zweidenker.p2p.connection.http.SimpleConnectionProvider
import de.zweidenker.p2p.model.Device
import javax.net.SocketFactory

class NFCConnectionProvider : SimpleConnectionProvider() {

    override fun socketFactoryFor(device: Device): SocketFactory {
        return NFCSocketFactory()
    }
}