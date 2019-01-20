package de.zweidenker.p2p.client

import de.zweidenker.p2p.model.Interface
import de.zweidenker.p2p.model.Network
import rx.Observable

interface DeviceConfigurationProvider {
    fun getInterfaces(): Observable<List<Interface>>
    fun getInterface(interfaceId: String): Observable<Interface>
    fun addNetwork(interfaceId: String, network: Network): Observable<String>
    fun getAvailableNetworks(interfaceId: String): Observable<List<Network>>
    fun getConfiguredNetworks(interfaceId: String): Observable<List<Network>>
    fun selectNetwork(interfaceId: String, networkId: String): Observable<Unit>
    fun getLog(interfaceId: String): Observable<String>
}