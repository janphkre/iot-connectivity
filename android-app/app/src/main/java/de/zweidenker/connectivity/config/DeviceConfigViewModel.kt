package de.zweidenker.connectivity.config

import android.arch.lifecycle.ViewModel
import android.content.Context
import de.zweidenker.p2p.client.DeviceConfigurationProvider
import de.zweidenker.p2p.connection.DeviceConnectionProvider
import de.zweidenker.p2p.model.Device
import de.zweidenker.p2p.model.Network
import de.zweidenker.p2p.model.NetworkConfig
import rx.Observable
import rx.Subscription
import rx.subscriptions.CompositeSubscription

class DeviceConfigViewModel(private val connectionProvider: DeviceConnectionProvider): ViewModel(), DeviceConnectionProvider {

    private var subscriptions: CompositeSubscription? = null
    lateinit var device: Device
    lateinit var configurationProvider: DeviceConfigurationProvider
    private set
    var interfaceId: String? = null
    var network: Network? = null

    var isLoading = true

    override fun connectTo(device: Device): Observable<DeviceConfigurationProvider> {
        return connectionProvider.connectTo(device).doOnNext {
            configurationProvider = it
        }
    }

    fun addNetworkConfig(interfaceId: String, network: NetworkConfig): Observable<String> {
        return configurationProvider.addNetworkConfig(interfaceId, network)
    }

    override fun destroy(context: Context) {
        unsubscribeAll()
        connectionProvider.destroy(context)
    }

    fun store(subscription: Subscription) {
        if(subscriptions == null) {
            subscriptions = CompositeSubscription()
        }
        subscriptions?.add(subscription)
    }

    fun unsubscribeAll() {
        subscriptions?.unsubscribe()
        subscriptions = null
    }
}
