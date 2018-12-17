package de.zweidenker.connectivity.config

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import de.zweidenker.p2p.beacon.Device
import rx.Observable
import rx.Subscription
import rx.schedulers.Schedulers

class DeviceConfigActivity: AppCompatActivity() {

    private var device: Device? = null
    private var subscription: Subscription? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        device = intent.getParcelableExtra(KEY_DEVICE)
        if(device == null) {
            finish()
            return
        }
        subscription = Observable.create<Unit> {
            //TODO: CONNECT P2P to device
        }.subscribeOn(Schedulers.computation()).subscribe()
    }

    companion object {
        private const val KEY_DEVICE = "config.device"

        fun startActivity(context: Context, device: Device) {
            val intent = Intent(context, this::class.java)
            intent.putExtra(KEY_DEVICE, device)
        }
    }
}