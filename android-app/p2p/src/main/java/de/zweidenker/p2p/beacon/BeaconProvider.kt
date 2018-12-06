package de.zweidenker.p2p.beacon

import android.content.Context
import rx.Observable

interface BeaconProvider {
    @Throws(Exception::class)
    fun getBeacons(context: Context): Observable<Device>
}