package de.zweidenker.connectivity.config

import android.arch.lifecycle.ViewModel
import android.content.Context
import de.zweidenker.p2p.client.DeviceConfigurationProvider
import de.zweidenker.p2p.connection.DeviceConnectionProvider
import de.zweidenker.p2p.model.Device
import rx.Observable
import rx.Subscription
import rx.subscriptions.CompositeSubscription

class DeviceConfigViewModel(private val connectionProvider: DeviceConnectionProvider): ViewModel(), DeviceConnectionProvider {

    private var subscriptions: CompositeSubscription? = null
    lateinit var device: Device
    lateinit var configurationProvider: DeviceConfigurationProvider
    private set
    var isLoading = true

    override fun connectTo(device: Device): Observable<DeviceConfigurationProvider> {
        return connectionProvider.connectTo(device).doOnNext {
            configurationProvider = it
        }
    }

    override fun destroy(context: Context) {
        subscriptions?.unsubscribe()
        subscriptions = null
        connectionProvider.destroy(context)
    }

    fun store(subscription: Subscription) {
        if(subscriptions == null) {
            subscriptions = CompositeSubscription()
        }
        subscriptions?.add(subscription)
    }
}
