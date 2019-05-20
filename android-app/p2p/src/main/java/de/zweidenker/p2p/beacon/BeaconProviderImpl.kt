package de.zweidenker.p2p.beacon

import android.content.Context
import android.net.wifi.p2p.WifiP2pManager
import android.net.wifi.p2p.nsd.WifiP2pDnsSdServiceRequest
import android.os.Handler
import de.zweidenker.p2p.P2PModule
import de.zweidenker.p2p.core.AbstractWifiProvider
import de.zweidenker.p2p.core.WifiP2PException
import de.zweidenker.p2p.model.ConnectionStatus
import de.zweidenker.p2p.model.Device
import rx.Observable
import rx.Subscriber
import timber.log.Timber

internal class BeaconProviderImpl(context: Context) : BeaconProvider, AbstractWifiProvider(context, P2PModule.NAME_BEACON_THREAD) {

    private val discoverHandler = Handler()
    private var request = WifiP2pDnsSdServiceRequest.newInstance()

    private fun String.isValidType(): Boolean {
        return endsWith(P2PModule.TYPE_SERVICE, true)
    }

    private fun cycleAddService(subscriber: Subscriber<in Device>) {
        // Internal filtering does not seem to work correctly. We will filter by ourselves.
        wifiManager?.addServiceRequest(wifiChannel, request, object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                wifiManager?.setDnsSdResponseListeners(wifiChannel,
                    { _, _, _ -> }, { fullDomainName, txtRecordMap, wifiP2pDevice ->
                    if (fullDomainName.isValidType()) {
                        try {
                            subscriber.onNext(Device(wifiP2pDevice, txtRecordMap))
                        } catch (e: Exception) {
                            Timber.e(e)
                            // TODO: DOES RX UNSUBSCRIBE IN ONERROR?
                            // subscriber.onError(e)
                        }
                    }
                })
                discoverHandler.post { cycleDiscoverServices(subscriber) }
            }

            override fun onFailure(errorCode: Int) {
                val throwable = WifiP2PException("Failed to add a service request!", errorCode)
                subscriber.onError(throwable)
            }
        })
    }

    private fun cycleDiscoverServices(subscriber: Subscriber<in Device>) {
        wifiManager?.discoverServices(wifiChannel, object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                discoverHandler.postDelayed({
                    cycleRemoveService(subscriber)
                }, P2PModule.DISCOVER_INTERVAL_MS)
            }

            override fun onFailure(errorCode: Int) {
                discoverHandler.postDelayed({
                    cycleRemoveService(subscriber)
                }, P2PModule.ERROR_RETRY_INTERVAL_MS)
            }
        })
    }

    private fun cycleRemoveService(subscriber: Subscriber<in Device>) {
        wifiManager?.removeServiceRequest(wifiChannel, request, object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                discoverHandler.post {
                    cycleAddService(subscriber)
                }
            }

            override fun onFailure(errorCode: Int) {
                discoverHandler.post {
                    cycleAddService(subscriber)
                }
            }
        })
    }

    @Throws(Exception::class)
    override fun getBeacons(): Observable<Device> = Observable.create<Device> { subscriber ->
        if (wifiManager == null || wifiChannel == null) {
            val throwable = WifiP2PException("System does not support Wifi Direct!", WifiP2pManager.P2P_UNSUPPORTED)
            subscriber.onError(throwable)
            return@create
        }

        subscriber.onNext(Device(0L, "MockDevice", "MockAddress", ConnectionStatus.UNKNOWN, 0, "Mock-IP", System.currentTimeMillis()))

        discoverHandler.post { cycleAddService(subscriber) }
    }.doOnUnsubscribe {
        discoverHandler.removeCallbacksAndMessages(null)
        wifiManager?.removeServiceRequest(wifiChannel, request, null)
    }

    override fun destroy() {
        discoverHandler.removeCallbacksAndMessages(null)
        wifiManager?.clearServiceRequests(wifiChannel, null)
        destroyProvider()
    }
}