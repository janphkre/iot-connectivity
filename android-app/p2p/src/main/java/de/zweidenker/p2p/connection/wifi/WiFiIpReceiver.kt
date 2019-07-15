package de.zweidenker.p2p.connection.wifi

import android.content.Context
import android.net.wifi.p2p.WifiP2pDevice
import de.zweidenker.p2p.P2PModule
import de.zweidenker.p2p.beacon.AbstractBeaconProvider
import rx.Subscription
import rx.schedulers.Schedulers
import rx.subjects.Subject
import timber.log.Timber
import java.net.ServerSocket

internal class WiFiIpReceiver(context: Context): AbstractBeaconProvider(context, P2PModule.NAME_IP_RECEIVER_THREAD) {

    var targetDeviceAddress: String? = null

    override fun isValidResult(fullDomainName: String, wifiP2pDevice: WifiP2pDevice): Boolean {
        val result = fullDomainName.endsWith(P2PModule.TYPE_IP_SERVICE) && (targetDeviceAddress?.equals(wifiP2pDevice.deviceAddress) == true)
        Timber.i("Found $fullDomainName on ${wifiP2pDevice.deviceAddress}: $result")
        return result
    }

    private var subscription: Subscription? = null

    fun receive(resultObservable: Subject<String, String>) {
        subscription = getBeacons().subscribeOn(Schedulers.io())
            .observeOn(Schedulers.computation())
            .subscribe {
                if(it.ip.isNotBlank()) {
                    resultObservable.onNext(it.ip)
                    subscription?.unsubscribe()
                    resultObservable.onCompleted()
                }
            }
    }

    override fun destroy() {
        super.destroy()
        unsubscribe()
    }

    fun unsubscribe() {
        subscription?.unsubscribe()
        subscription = null
    }

    private fun awaitOnSocket(resultObservable: Subject<String, String>) {
        Timber.e("Awaiting Ping on ${P2PModule.PING_PORT}")
        try {
            val targetAddress = ServerSocket(P2PModule.PING_PORT).use { serverSocket ->
                serverSocket.soTimeout = P2PModule.SOCKET_TIMEOUT_MS
                serverSocket.accept().use { clientSocket ->
                    clientSocket.inetAddress.toString()
                }
            }
            resultObservable.onNext(targetAddress)
        } catch(e: Exception) {
            resultObservable.onError(e)
        }
    }
}