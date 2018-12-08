package de.zweidenker.connectivity

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.support.v7.app.AppCompatActivity
import de.zweidenker.connectivity.list.DeviceListActivity

class LaunchActivity: AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_launch)
        Handler().postDelayed ({
            startActivity(Intent(this, DeviceListActivity::class.java))
            //TODO: override pending Transition
            finish()
        }, 1500)
    }
}