package de.zweidenker.p2p.core

import android.content.Context
import android.net.wifi.p2p.WifiP2pManager
import android.os.HandlerThread
import android.os.Looper

abstract class AbstractWifiProvider(context: Context) {

    private var backgroundLooper: Looper
    protected val wifiManager: WifiP2pManager?
    private var wifiChannel: WifiP2pManager.Channel? = null

    init {
        val backgroundHandlerThread = HandlerThread("BeaconBackgroundThread")
        backgroundHandlerThread.start()
        backgroundLooper = backgroundHandlerThread.looper

        wifiManager = context.getSystemService(Context.WIFI_P2P_SERVICE) as? WifiP2pManager
    }

    @Throws(InstantiationException::class)
    protected fun getChannel(context: Context): WifiP2pManager.Channel {
        return wifiChannel.let {
            if(it == null) {
                (wifiManager?.initialize(context, backgroundLooper) {
                    wifiChannel = null
                }).also { result ->
                    wifiChannel = result
                } ?: throw InstantiationException("Failed to create a Wifi channel!")
            } else {
                it
            }
        }
    }
}