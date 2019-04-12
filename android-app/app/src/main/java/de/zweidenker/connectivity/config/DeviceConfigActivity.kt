package de.zweidenker.connectivity.config

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.view.View
import android.widget.Toast
import de.zweidenker.connectivity.ApplicationModule
import de.zweidenker.connectivity.R
import de.zweidenker.connectivity.config.interfaces.DeviceInterfacesFragment
import de.zweidenker.connectivity.config.networks.DeviceNetworksFragment
import de.zweidenker.p2p.client.DeviceConfigurationProvider
import de.zweidenker.p2p.model.Device
import kotlinx.android.synthetic.main.activity_device_config.*
import org.koin.android.ext.android.getKoin
import org.koin.android.ext.android.inject
import rx.Observer
import rx.Subscription
import rx.android.schedulers.AndroidSchedulers
import rx.schedulers.Schedulers
import timber.log.Timber

class DeviceConfigActivity: AppCompatActivity(), LoadingDisplay, Observer<DeviceConfigurationProvider> {

    //TODO: SETUP STATE RETENTION

    //This view model is tied to the device config scope
    private val viewModel by inject<DeviceConfigViewModel>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        getKoin().createScope(ApplicationModule.DEVICE_CONFIG_SCOPE)
        val device = intent.getParcelableExtra<Device>(KEY_DEVICE)
        if(device == null) {
            finish()
            return
        }
        viewModel.device = device
        createView(device)
        viewModel.connectTo(device)
            .subscribeOn(Schedulers.computation())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(this)
            .store()
    }

    override fun onDestroy() {
        viewModel.destroy(this)
        getKoin().detachScope(ApplicationModule.DEVICE_CONFIG_SCOPE)
        super.onDestroy()
    }

    private fun createView(device: Device) {
        setContentView(R.layout.activity_device_config)
        setTitle(device.userIdentifier)
        setSupportActionBar(toolbar)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.setDisplayShowHomeEnabled(true)
    }

    override fun onSupportNavigateUp(): Boolean {
        onBackPressed()
        return true
    }

    private fun Subscription.store() {
        viewModel.store(this)
    }

    override fun startLoading() {
        loading_view
            .animate()
            .setDuration(DURATION_LOADING_FADING)
            .alpha(1.0f)
            .withStartAction {
                loading_view.visibility = View.VISIBLE
            }
            .start()
    }

    override fun stopLoading() {
        loading_view
            .animate()
            .setDuration(DURATION_LOADING_FADING)
            .alpha(0.0f)
            .withEndAction {
                loading_view.visibility = View.GONE
            }
            .start()
    }

    override fun onError(e: Throwable) {
        Timber.e(e)
        Toast.makeText(this@DeviceConfigActivity, "Failed to connect to the device!", Toast.LENGTH_SHORT).show()
        stopLoading()
    }

    override fun onNext(configurationProvider: DeviceConfigurationProvider) {
        Timber.e("Got DeviceConfigurationProvider")
        switchToInterfaces()
    }

    fun switchToInterfaces() {
        supportFragmentManager.beginTransaction()
            .add(R.id.fragment_container, DeviceInterfacesFragment())
            .disallowAddToBackStack()
            .commitNowAllowingStateLoss()
    }

    fun switchToNetworks() {
        supportFragmentManager.beginTransaction()
            .add(R.id.fragment_container, DeviceNetworksFragment())
            .disallowAddToBackStack()
            .commitNowAllowingStateLoss()
    }

    override fun setTitle(title: String) {
        toolbar.title = title
    }

    override fun onCompleted() { }

    companion object {
        private const val KEY_DEVICE = "config.device"
        private const val DURATION_LOADING_FADING = 1500L

        fun startActivity(context: Context, device: Device) {
            val intent = Intent(context, DeviceConfigActivity::class.java)
            intent.putExtra(KEY_DEVICE, device)
            context.startActivity(intent)
        }
    }
}