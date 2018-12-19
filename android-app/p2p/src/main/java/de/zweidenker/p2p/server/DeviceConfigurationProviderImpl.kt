package de.zweidenker.p2p.server

import android.content.Context
import android.net.wifi.p2p.WifiP2pManager
import android.util.Log
import de.zweidenker.p2p.core.AbstractWifiProvider
import de.zweidenker.p2p.core.Device
import de.zweidenker.p2p.core.P2PConstants
import de.zweidenker.p2p.core.WifiP2PException
import rx.Observable
import java.io.IOException
import java.net.InetSocketAddress
import java.net.Socket


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
                    socketConnect(device.address, device.port)
                    subscriber.onCompleted()
                }

                override fun onFailure(reason: Int) {
                    val throwable = WifiP2PException("Failed to connect to the device!", reason)
                    subscriber.onError(throwable)
                }

            })
        }
    }

    private fun socketConnect(host: String, port: Int) {
        val socket = Socket()
        try {
            Log.d("TEST", "Opening client socket - ")
            socket.bind(null)
            socket.connect(InetSocketAddress(host, port), P2PConstants.TIMEOUT_SOCKET)
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