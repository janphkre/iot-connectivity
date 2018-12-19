package de.zweidenker.p2p.core

import android.content.Context
import android.net.wifi.p2p.WifiP2pManager
import android.os.Build
import android.os.HandlerThread
import android.os.Looper

internal abstract class AbstractWifiProvider(context: Context, backgroundThreadName: String) {

    protected var backgroundLooper: Looper
    protected val wifiManager: WifiP2pManager?
    protected var wifiChannel: WifiP2pManager.Channel? = null

    init {
        val backgroundHandlerThread = HandlerThread(backgroundThreadName)
        backgroundHandlerThread.start()
        backgroundLooper = backgroundHandlerThread.looper

        wifiManager = context.getSystemService(Context.WIFI_P2P_SERVICE) as? WifiP2pManager

        wifiChannel = (wifiManager?.initialize(context, backgroundLooper) {
            wifiChannel = null
        }).also { result ->
            wifiChannel = result
        }
    }

    protected fun destroyProvider() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            wifiChannel?.close()
        }
        wifiChannel = null
    }
}