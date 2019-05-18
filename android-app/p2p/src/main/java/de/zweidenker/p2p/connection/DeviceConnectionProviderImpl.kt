package de.zweidenker.p2p.connection

import android.content.Context
import android.content.IntentFilter
import android.net.wifi.p2p.WifiP2pManager
import android.util.Log
import de.zweidenker.p2p.P2PModule
import de.zweidenker.p2p.client.DeviceConfigurationProvider
import de.zweidenker.p2p.core.AbstractWifiProvider
import de.zweidenker.p2p.core.WifiP2PException
import de.zweidenker.p2p.model.Device
import rx.Observable
import rx.subjects.ReplaySubject
import java.io.IOException
import java.net.InetAddress
import java.net.InetSocketAddress
import java.net.Socket

internal class DeviceConnectionProviderImpl(context: Context) : DeviceConnectionProvider, AbstractWifiProvider(context, P2PModule.NAME_CONFIG_THREAD) {

    private val ipRecieverServer = IpRecieverServer()
    private val groupOwnerObservable = ReplaySubject.create<String>(1)
    private val broadcastReceiver = Broadcasts {
        Log.e("TEST", "GOT INTENT")
        wifiManager?.requestConnectionInfo(wifiChannel) { info ->
            Log.e("TEST", "info: $info")
            if (info.groupFormed) {
                if (info.isGroupOwner) {
                    ipRecieverServer.recieve(groupOwnerObservable)

                } else {
                    groupOwnerObservable.onNext(info.groupOwnerAddress.hostAddress)
                    groupOwnerObservable.onCompleted()
                }
            }
        }
    }

    init {
        context.registerReceiver(broadcastReceiver, IntentFilter(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION))
        Log.e("TEST", "Registered broadcast receiver")
    }

    override fun connectTo(device: Device): Observable<DeviceConfigurationProvider> {
        return Observable.create<Unit> { subscriber ->
            if (wifiManager == null || wifiChannel == null) {
                val throwable = WifiP2PException("System does not support Wifi Direct!", WifiP2pManager.P2P_UNSUPPORTED)
                subscriber.onError(throwable)
                return@create
            }
            wifiManager.connect(wifiChannel, device.asConfig(), object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    Log.e("TEST", "CONNECT SUCCESS")
                    subscriber.onNext(Unit)
                    subscriber.onCompleted()
                }

                override fun onFailure(reason: Int) {
                    val throwable = WifiP2PException("Failed to connect to the device!", reason)
                    subscriber.onError(throwable)
                }
            })
        }.zipWith<String, DeviceConfigurationProvider>(groupOwnerObservable) { _, hostAddress ->
            DeviceConfigurationProvider.getInstance(device, hostAddress)
        }
    }

    override fun destroy(context: Context) {
        try {
            context.unregisterReceiver(broadcastReceiver)
        } catch (ignored: IllegalArgumentException) { }
    }

    private fun socketConnect(host: InetAddress, port: Int) {
        val socket = Socket()
        try {
            Log.d("TEST", "Opening client socket - host: $host port: $port")
            socket.bind(null)
            socket.connect(InetSocketAddress(host, port), P2PModule.SOCKET_TIMEOUT_MS)
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