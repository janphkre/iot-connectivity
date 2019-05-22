package de.zweidenker.p2p.beacon

import android.content.Context
import android.net.wifi.p2p.WifiP2pDevice
import de.zweidenker.p2p.P2PModule

internal class BeaconProviderImpl(context: Context) : AbstractBeaconProvider(context, P2PModule.NAME_BEACON_THREAD) {
    override fun isValidResult(fullDomainName: String, wifiP2pDevice: WifiP2pDevice): Boolean {
        return fullDomainName.endsWith(P2PModule.TYPE_SERVICE, true)
    }
}