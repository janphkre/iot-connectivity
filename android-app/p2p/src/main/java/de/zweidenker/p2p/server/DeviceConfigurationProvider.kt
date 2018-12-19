package de.zweidenker.p2p.server

import de.zweidenker.p2p.core.Device
import rx.Observable

interface DeviceConfigurationProvider {
    fun connectTo(device: Device): Observable<Unit>
}