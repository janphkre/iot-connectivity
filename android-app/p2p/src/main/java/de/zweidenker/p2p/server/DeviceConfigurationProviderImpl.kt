package de.zweidenker.p2p.server

import android.content.Context
import android.net.wifi.p2p.WifiP2pConfig
import android.net.wifi.p2p.WifiP2pManager
import de.zweidenker.p2p.core.AbstractWifiProvider
import de.zweidenker.p2p.core.Device
import de.zweidenker.p2p.core.P2PConstants
import de.zweidenker.p2p.core.WifiP2PException
import rx.Observable

internal class DeviceConfigurationProviderImpl(context: Context): DeviceConfigurationProvider, AbstractWifiProvider(context, P2PConstants.NAME_CONFIG_THREAD) {

    override fun connectTo(device: Device): Observable<Unit> {
        return Observable.create<Unit> { subscriber ->
            if(wifiManager == null || wifiChannel == null) {
                val throwable = WifiP2PException("System does not support Wifi Direct!", WifiP2pManager.P2P_UNSUPPORTED)
                subscriber.onError(throwable)
                return@create
            }
            wifiManager.connect(wifiChannel, device.asConfig(), object: WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    subscriber.onCompleted()
                }

                override fun onFailure(reason: Int) {
                    val throwable = WifiP2PException("Failed to connect to the device!", reason)
                    subscriber.onError(throwable)
                }

            })
        }
    }
}