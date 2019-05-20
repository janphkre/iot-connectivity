package de.zweidenker.p2p.connection

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.NetworkInfo
import android.net.wifi.p2p.WifiP2pManager
import timber.log.Timber

class Broadcasts(private val connected: () -> Unit) : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent?) {
        when (intent?.action) {
            WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION -> {
                val networkInfo: NetworkInfo? = intent.getParcelableExtra(WifiP2pManager.EXTRA_NETWORK_INFO) as NetworkInfo
                if (networkInfo?.isConnected == true) {
                    connected.invoke()
                } else {
                    Timber.e("connectionChanged:" + networkInfo?.detailedState?.name + " " + networkInfo?.extraInfo)
                }
            }
        }
    }
}