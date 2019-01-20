package de.zweidenker.p2p.connection

import android.content.Context
import de.zweidenker.p2p.client.DeviceConfigurationProvider
import de.zweidenker.p2p.model.Device
import rx.Observable

interface DeviceConnectionProvider {
    fun connectTo(device: Device): Observable<DeviceConfigurationProvider>
    fun destroy(context: Context)
}