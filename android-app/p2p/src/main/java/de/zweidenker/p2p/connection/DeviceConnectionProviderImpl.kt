package de.zweidenker.p2p.connection

import android.content.Context
import android.content.IntentFilter
import android.net.wifi.p2p.WifiP2pManager
import android.util.Log
import de.zweidenker.p2p.P2PModule
import de.zweidenker.p2p.client.DeviceConfigurationProvider
import de.zweidenker.p2p.core.AbstractWifiProvider
import de.zweidenker.p2p.model.Device
import de.zweidenker.p2p.core.WifiP2PException
import rx.Observable
import rx.schedulers.Schedulers
import java.io.IOException
import java.net.InetAddress
import java.net.InetSocketAddress
import java.net.Socket

internal class DeviceConnectionProviderImpl(context: Context): DeviceConnectionProvider, AbstractWifiProvider(context, P2PModule.NAME_CONFIG_THREAD) {

    private val broadcastReceiver = Broadcasts {
        Log.e("TEST", "GOT INTENT")
        wifiManager?.requestConnectionInfo(wifiChannel) { info ->
            Log.e("TEST", "info: " + info.toString())
            if(info.groupFormed) {
                if(info.isGroupOwner) {
                    //TODO: FAIL HERE AND CLOSE CONNECTION?!
                    return@requestConnectionInfo
                } else {
                    Observable.fromCallable {
                        socketConnect(info.groupOwnerAddress, 8889)
                    }.subscribeOn(Schedulers.io()).subscribe()
                }
            }
        }
    }

    init {
        context.registerReceiver(broadcastReceiver, IntentFilter(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION))
    }

    override fun connectTo(device: Device): Observable<DeviceConfigurationProvider> {
        return Observable.create<DeviceConfigurationProvider> { subscriber ->

            if(wifiManager == null || wifiChannel == null) {
                val throwable = WifiP2PException("System does not support Wifi Direct!", WifiP2pManager.P2P_UNSUPPORTED)
                subscriber.onError(throwable)
                return@create
            }
            wifiManager.connect(wifiChannel, device.asConfig(), object: WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    Log.e("TEST","CONNECT SUCCESS")
                    //TODO: REMOVE LOG STATEMENTS
                }

                override fun onFailure(reason: Int) {
                    val throwable = WifiP2PException("Failed to connect to the device!", reason)
                    subscriber.onError(throwable)
                }

            })
            //TODO: DISCONNECT FROM GROUP ONCE DONE!
        }
    }

    override fun destroy(context: Context) {
        context.unregisterReceiver(broadcastReceiver)
    }

    private fun socketConnect(host: InetAddress, port: Int) {
        val socket = Socket()
        try {
            Log.d("TEST", "Opening client socket - host: $host port: $port")
            socket.bind(null)
            socket.connect(InetSocketAddress(host, port), P2PModule.TIMEOUT_SOCKET)
            Log.d("TEST", "Client socket - " + socket.isConnected)

        } catch (e: Exception) {
            Log.e("TEST", e.message)
        } finally {
            if (socket.isConnected) {
                try {
                    socket.close()
                } catch (e: IOException) {
                    // Give up
                    e.printStackTrace()
                }

            }
        }
    }
}