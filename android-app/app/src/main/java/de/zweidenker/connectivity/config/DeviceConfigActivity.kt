package de.zweidenker.connectivity.config

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import de.zweidenker.p2p.beacon.Device

class DeviceConfigActivity: AppCompatActivity() {

    private var device: Device? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        device = intent.getParcelableExtra(KEY_DEVICE)
        if(device == null) {
            finish()
            return
        }
        //TODO: CONNECT P2P to device
    }

    companion object {
        private val KEY_DEVICE = "config.device"

        fun startActivity(context: Context, device: Device) {
            val intent = Intent(context, this::class.java)
            intent.putExtra(KEY_DEVICE, device)
        }
    }
}