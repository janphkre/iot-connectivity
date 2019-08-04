package de.zweidenker.p2p.connection.bluetooth

import android.content.Context
import de.zweidenker.p2p.client.DeviceConfigurationProvider
import de.zweidenker.p2p.connection.DeviceConnectionProvider
import de.zweidenker.p2p.connection.http.SimpleHttpWrapper
import de.zweidenker.p2p.model.Device
import rx.Observable

class BluetoothConnectionProvider : DeviceConnectionProvider {

    override fun connectTo(device: Device): Observable<DeviceConfigurationProvider> {
        return Observable.unsafeCreate<DeviceConfigurationProvider> { subscriber ->
            val httpStream = BluetoothConnectionStream(device)
            val simpleHttpWrapper = SimpleHttpWrapper.Builder()
                .setHttpStream(httpStream)
                .build()
            subscriber.onNext(DeviceConfigurationProvider.getInstance(simpleHttpWrapper, device, "bluetooth"))
            subscriber.onCompleted()
        }
    }

    override fun destroy(context: Context) { }
}