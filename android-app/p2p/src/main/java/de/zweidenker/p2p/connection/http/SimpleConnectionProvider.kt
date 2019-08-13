package de.zweidenker.p2p.connection.http

import android.content.Context
import de.zweidenker.p2p.client.DeviceConfigurationProvider
import de.zweidenker.p2p.connection.DeviceConnectionProvider
import de.zweidenker.p2p.model.Device
import rx.Observable

abstract class SimpleConnectionProvider(private val deviceHost: String) : DeviceConnectionProvider {

    override fun connectTo(device: Device): Observable<DeviceConfigurationProvider> {
        return Observable.unsafeCreate<DeviceConfigurationProvider> { subscriber ->
            val simpleHttpWrapper = SimpleHttpWrapper.Builder()
                .setHttpStream(httpStreamFor(device))
                .build()
            subscriber.onNext(DeviceConfigurationProvider.getInstance(simpleHttpWrapper, device, deviceHost))
            subscriber.onCompleted()
        }
    }

    override fun destroy(context: Context) { }

    abstract fun httpStreamFor(device: Device): ConnectionStream
}