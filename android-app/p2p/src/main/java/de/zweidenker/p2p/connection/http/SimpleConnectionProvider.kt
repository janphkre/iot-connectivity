package de.zweidenker.p2p.connection.http

import android.content.Context
import de.zweidenker.p2p.P2PModule
import de.zweidenker.p2p.client.DeviceConfigurationProvider
import de.zweidenker.p2p.connection.DeviceConnectionProvider
import de.zweidenker.p2p.model.Device
import okhttp3.OkHttpClient
import rx.Observable
import java.util.concurrent.TimeUnit
import javax.net.SocketFactory

abstract class SimpleConnectionProvider : DeviceConnectionProvider {

    override fun connectTo(device: Device): Observable<DeviceConfigurationProvider> {
        return Observable.unsafeCreate<DeviceConfigurationProvider> { subscriber ->
            subscriber.onNext(DeviceConfigurationProvider.getInstance(getHttpClient(device), device, "localhost"))
            subscriber.onCompleted()
        }
    }

    private fun getHttpClient(device: Device): OkHttpClient {
        val clientBuilder = OkHttpClient.Builder()
            .socketFactory(socketFactoryFor(device))
            .connectTimeout(P2PModule.CONNECTION_TIMEOUT_S, TimeUnit.SECONDS)
            .readTimeout(P2PModule.CONNECTION_TIMEOUT_S, TimeUnit.SECONDS)
            .writeTimeout(P2PModule.CONNECTION_TIMEOUT_S, TimeUnit.SECONDS)
        return clientBuilder.build()
    }

    override fun destroy(context: Context) { }

    abstract fun socketFactoryFor(device: Device): SocketFactory
}