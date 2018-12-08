package de.zweidenker.p2p.beacon

import android.content.Context
import android.net.wifi.p2p.WifiP2pManager
import android.net.wifi.p2p.nsd.WifiP2pDnsSdServiceRequest
import de.zweidenker.p2p.core.AbstractWifiProvider
import de.zweidenker.p2p.core.WifiP2PException
import rx.Observable

internal class BeaconProviderImpl(context: Context): BeaconProvider, AbstractWifiProvider(context) {

    @Throws(Exception::class)
    override fun getBeacons(context: Context): Observable<Device> {
        val channel = getChannel(context)
        return Observable.create<Device> { subscriber ->
            if(wifiManager == null) {
                val throwable = WifiP2PException("System does not support Wifi Direct!", WifiP2pManager.P2P_UNSUPPORTED)
                subscriber.onError(throwable)
                return@create
            }

            val request = WifiP2pDnsSdServiceRequest.newInstance()
            // TODO: SPECIFY FILTER FOR REQUEST
            wifiManager.addServiceRequest(channel, request, object: WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    wifiManager.setDnsSdResponseListeners(channel, { fullDomainName, type, wifiP2pDevice ->
                        subscriber.onNext(Device(wifiP2pDevice.deviceAddress, fullDomainName, type))
                    }, { fullDomainName, txtRecordMap, wifiP2pDevice -> /* TODO? */ })
                    wifiManager.discoverServices(channel, object: WifiP2pManager.ActionListener {
                        override fun onSuccess() { }

                        override fun onFailure(errorCode: Int) {
                            val throwable = WifiP2PException("Failed to discover services!", errorCode)
                            subscriber.onError(throwable)
                        }
                    })
                }

                override fun onFailure(errorCode: Int) {
                    val throwable = WifiP2PException("Failed to add a service request!", errorCode)
                    subscriber.onError(throwable)
                }
            })
        }
    }
}