package de.zweidenker.p2p.client

import android.content.Context
import de.zweidenker.p2p.core.Device
import rx.Observable

interface DeviceConfigurationProvider {
    fun connectTo(device: Device): Observable<Unit>
    fun destroy(context: Context)
}