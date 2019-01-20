package de.zweidenker.p2p.client

import de.zweidenker.p2p.model.Device
import de.zweidenker.p2p.model.Interface
import de.zweidenker.p2p.model.Network
import rx.Observable

class DeviceConfigurationProviderImpl(device: Device): DeviceConfigurationProvider {

    override fun getInterfaces(): Observable<List<Interface>> {
        TODO("not implemented")
    }

    override fun getInterface(interfaceId: String): Observable<Interface> {
        TODO("not implemented")
    }

    override fun addNetwork(interfaceId: String, network: Network): Observable<String> {
        TODO("not implemented")
    }

    override fun getAvailableNetworks(interfaceId: String): Observable<List<Network>> {
        TODO("not implemented")
    }

    override fun getConfiguredNetworks(interfaceId: String): Observable<List<Network>> {
        TODO("not implemented")
    }

    override fun selectNetwork(interfaceId: String, networkId: String): Observable<Unit> {
        TODO("not implemented")
    }

    override fun getLog(interfaceId: String): Observable<String> {
        TODO("not implemented")
    }
}