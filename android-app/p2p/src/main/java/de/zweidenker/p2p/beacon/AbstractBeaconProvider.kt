package de.zweidenker.p2p.beacon

import android.content.Context
import android.net.wifi.p2p.WifiP2pDevice
import android.net.wifi.p2p.WifiP2pManager
import android.net.wifi.p2p.nsd.WifiP2pDnsSdServiceRequest
import android.os.Handler
import de.zweidenker.p2p.P2PModule
import de.zweidenker.p2p.core.AbstractWifiProvider
import de.zweidenker.p2p.core.WifiP2PException
import de.zweidenker.p2p.model.ConnectionStatus
import de.zweidenker.p2p.model.Device
import de.zweidenker.p2p.model.bluetooth.BluetoothDetails
import de.zweidenker.p2p.model.wifi.WifiDetails
import rx.Observable
import rx.Subscriber
import timber.log.Timber

internal abstract class AbstractBeaconProvider(context: Context, backgroundThreadName: String) : BeaconProvider, AbstractWifiProvider(context, backgroundThreadName) {

    private val discoverHandler = Handler()
    private var request = WifiP2pDnsSdServiceRequest.newInstance()

    abstract fun isValidResult(fullDomainName: String, wifiP2pDevice: WifiP2pDevice): Boolean

    private fun cycleAddService(subscriber: Subscriber<in Device>) {
        // Internal filtering does not seem to work correctly. We will filter by ourselves.
        wifiManager?.addServiceRequest(wifiChannel, request, object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                wifiManager.setDnsSdResponseListeners(wifiChannel,
                    { _, _, _ -> }, { fullDomainName, txtRecordMap, wifiP2pDevice ->
                    if (isValidResult(fullDomainName, wifiP2pDevice)) {
                        try {
                            val device = Device(wifiP2pDevice, txtRecordMap)
                            subscriber.onNext(device)
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
    override fun getBeacons(): Observable<Device> = Observable.unsafeCreate<Device> { subscriber ->
        subscriber.onNext(Device(
            0L, "MockDevice", ConnectionStatus.UNKNOWN,
            WifiDetails("MockAddress", 1234, "192.168.180.2"),
            BluetoothDetails("MockBluetoothAddress", 1),
            System.currentTimeMillis()))
        if (wifiManager == null || wifiChannel == null) {
            val throwable = WifiP2PException("System does not support Wifi Direct!", WifiP2pManager.P2P_UNSUPPORTED)
            subscriber.onError(throwable)
            return@unsafeCreate
        }

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