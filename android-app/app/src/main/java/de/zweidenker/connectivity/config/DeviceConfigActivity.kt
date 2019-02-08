package de.zweidenker.connectivity.config

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import de.zweidenker.p2p.client.DeviceConfigurationProvider
import de.zweidenker.p2p.model.Device
import de.zweidenker.p2p.connection.DeviceConnectionProvider
import org.koin.android.ext.android.inject
import rx.Observer
import rx.Subscription
import rx.android.schedulers.AndroidSchedulers
import rx.schedulers.Schedulers
import timber.log.Timber

class DeviceConfigActivity: AppCompatActivity(), Observer<DeviceConfigurationProvider> {

    private val configurationProvider by inject<DeviceConnectionProvider>()
    private var subscription: Subscription? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val device = intent.getParcelableExtra<Device>(KEY_DEVICE)
        if(device == null) {
            finish()
            return
        }
        subscription = configurationProvider.connectTo(device)
            .subscribeOn(Schedulers.computation())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(this)
    }

    override fun onDestroy() {
        //TODO: MOVE SUBSCRIPTION TO ONSTART/ONPAUSE
        subscription?.unsubscribe()
        subscription = null
        configurationProvider.destroy(this)
        super.onDestroy()
    }

    override fun onError(e: Throwable?) {
        Timber.e(e)
//        TODO("not implemented")
    }

    override fun onNext(t: DeviceConfigurationProvider)  {
        Timber.e("Got DeviceConfigurationProvider")
        //TODO!
    }

    override fun onCompleted() { }

    companion object {
        private const val KEY_DEVICE = "config.device"

        fun startActivity(context: Context, device: Device) {
            val intent = Intent(context, DeviceConfigActivity::class.java)
            intent.putExtra(KEY_DEVICE, device)
            context.startActivity(intent)
        }
    }
}