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
import timber.log.Timber
import java.io.IOException
import java.net.InetAddress
import java.net.InetSocketAddress
import java.net.Socket

internal class DeviceConnectionProviderImpl(context: Context) : DeviceConnectionProvider, AbstractWifiProvider(context, P2PModule.NAME_CONFIG_THREAD) {

    private val ipRecieverServer = IpReceiverServer()
    private val groupOwnerObservable = ReplaySubject.create<String>(1)
    private val broadcastReceiver = Broadcasts {
        Timber.e("GOT INTENT")
        wifiManager?.requestConnectionInfo(wifiChannel) { info ->
            Timber.e("info: $info")
            if (info.groupFormed) {
                if (info.isGroupOwner) {
                    ipRecieverServer.receive(groupOwnerObservable)
                } else {
                    groupOwnerObservable.onNext(info.groupOwnerAddress.hostAddress)
                    groupOwnerObservable.onCompleted()
                }
            }
        }
    }

    init {
        context.registerReceiver(broadcastReceiver, IntentFilter(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION))
        Timber.e("Registered broadcast receiver")
    }

    override fun connectTo(device: Device): Observable<DeviceConfigurationProvider> {
        return Observable.unsafeCreate<Unit> { subscriber ->
            if (wifiManager == null || wifiChannel == null) {
                val throwable = WifiP2PException("System does not support Wifi Direct!", WifiP2pManager.P2P_UNSUPPORTED)
                subscriber.onError(throwable)
                return@unsafeCreate
            }
            wifiManager.connect(wifiChannel, device.asConfig(), object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    Timber.e("CONNECT SUCCESS")
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
        }.doOnUnsubscribe {
            ipRecieverServer.unsubscribe()
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