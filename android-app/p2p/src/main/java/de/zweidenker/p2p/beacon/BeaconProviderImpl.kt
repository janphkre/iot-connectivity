package de.zweidenker.p2p.beacon

import android.content.Context
import android.net.wifi.p2p.WifiP2pManager
import android.net.wifi.p2p.nsd.WifiP2pDnsSdServiceRequest
import de.zweidenker.p2p.P2PModule
import de.zweidenker.p2p.core.AbstractWifiProvider
import de.zweidenker.p2p.model.Device
import de.zweidenker.p2p.core.WifiP2PException
import rx.Observable
import rx.Subscription
import rx.schedulers.Schedulers
import rx.subjects.ReplaySubject

internal class BeaconProviderImpl(context: Context): BeaconProvider, AbstractWifiProvider(context, P2PModule.NAME_BEACON_THREAD) {

    private val observable = Observable.create<Device> { subscriber ->
        if(wifiManager == null || wifiChannel == null) {
            val throwable = WifiP2PException("System does not support Wifi Direct!", WifiP2pManager.P2P_UNSUPPORTED)
            subscriber.onError(throwable)
            return@create
        }

        //Internal filtering does not seem to work correctly. We will filter by ourselves.
        val request = WifiP2pDnsSdServiceRequest.newInstance()
        wifiManager.addServiceRequest(wifiChannel, request, object: WifiP2pManager.ActionListener {
            override fun onSuccess() {
                wifiManager.setDnsSdResponseListeners(wifiChannel,
                    { _, _, _ -> }, { fullDomainName, txtRecordMap, wifiP2pDevice ->
                    if(fullDomainName.isValidType()) {
                        try {
                            subscriber.onNext(Device(wifiP2pDevice, txtRecordMap))
                        } catch(e: Exception) {
                            subscriber.onError(e)
                        }
                    }
                })
                wifiManager.discoverServices(wifiChannel, object: WifiP2pManager.ActionListener {
                    override fun onSuccess() { }

                    override fun onFailure(errorCode: Int) {
                        val throwable = WifiP2PException("Failed to discover services!", errorCode)//TODO: MAY FAIL SOMETIMES; RETRY AFTER A MOMENT?
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
    private var subscription: Subscription? = null
    private var deviceSubject = ReplaySubject.create<Device>()

    private fun String.isValidType(): Boolean {
        return endsWith(P2PModule.TYPE_SERVICE, true)
    }

    @Throws(Exception::class)
    override fun getBeacons(): Observable<Device> {
        if(subscription == null) {
            subscription = observable
                .subscribeOn(Schedulers.io())
                .subscribe(deviceSubject)
        }
        return deviceSubject.doOnUnsubscribe {
            deviceSubject = ReplaySubject.create()
        }
    }

    override fun destroy() {
        subscription?.unsubscribe()
        subscription = null
        wifiManager?.clearServiceRequests(wifiChannel, null)
        destroyProvider()
    }
}