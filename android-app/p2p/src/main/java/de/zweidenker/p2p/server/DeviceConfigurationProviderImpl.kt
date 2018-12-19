package de.zweidenker.p2p.server

import android.content.Context
import de.zweidenker.p2p.core.AbstractWifiProvider
import de.zweidenker.p2p.core.Device
import de.zweidenker.p2p.core.P2PConstants
import rx.Observable

internal class DeviceConfigurationProviderImpl(context: Context): DeviceConfigurationProvider, AbstractWifiProvider(context, P2PConstants.NAME_CONFIG_THREAD) {

    override fun connectTo(device: Device): Observable<Unit> {
        return Observable.create<Unit> {

            it.onCompleted()
        }
    }
}