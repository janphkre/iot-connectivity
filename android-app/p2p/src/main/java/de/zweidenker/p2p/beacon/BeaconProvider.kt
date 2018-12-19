package de.zweidenker.p2p.beacon

import de.zweidenker.p2p.core.Device
import rx.Observable

interface BeaconProvider {
    @Throws(Exception::class)
    fun getBeacons(): Observable<Device>
    fun destroy()
}