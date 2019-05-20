package de.zweidenker.connectivity.list

import android.Manifest
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.support.v7.app.AppCompatActivity
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.widget.Toast
import de.zweidenker.connectivity.util.PermissionHandler
import de.zweidenker.connectivity.util.withPermissions
import de.zweidenker.p2p.beacon.BeaconProvider
import de.zweidenker.p2p.model.Device
import kotlinx.android.synthetic.main.activity_device_list.*
import org.koin.android.ext.android.inject
import rx.Observer
import rx.schedulers.Schedulers
import rx.subscriptions.CompositeSubscription
import timber.log.Timber
import java.lang.ref.WeakReference

/**
 * I list all devices that are available through the beacon provider.
 * Every item in my list can be clicked to start the DeviceConfigActivity on it.
 */
class DeviceListActivity : AppCompatActivity() {

    private lateinit var deviceAdapter: DeviceAdapter
    private val beaconProvider by inject<BeaconProvider>()
    private var subscription = CompositeSubscription()

    private val weakReferenceHandler: WeakReference<Handler> = WeakReference(Handler())

    private val cyclicRunnable = object : Runnable {
        override fun run() {
            deviceAdapter.removeOutdatedItems()
            weakReferenceHandler.get()?.postDelayed(this, CYCLIC_INTERVAL)
        }
    }

    private fun scanBeacons() {
        subscription.add(beaconProvider.getBeacons()
            .subscribeOn(Schedulers.io())
            .observeOn(Schedulers.computation())
            .retry()
            .subscribe(getScanBeaconsObserver()))
    }

    private fun getScanBeaconsObserver(): Observer<Device> {
        return object : Observer<Device> {
            override fun onError(e: Throwable?) {
                runOnUiThread {
                    Toast.makeText(baseContext, e?.localizedMessage, Toast.LENGTH_SHORT).show()
                }
                Timber.e(e)
            }

            override fun onNext(device: Device) {
                synchronized(this) {
                    runOnUiThread {
                        deviceAdapter.addItem(device)
                    }
                }
            }

            override fun onCompleted() { }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(de.zweidenker.connectivity.R.layout.activity_device_list)
        setupDeviceList()
        setupHeader()
    }

    private fun setupDeviceList() {
        deviceAdapter = DeviceAdapter(this)
        list_device.layoutManager = LinearLayoutManager(this, RecyclerView.VERTICAL, false)
        list_device.adapter = deviceAdapter
    }

    private fun setupHeader() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
            frame_device.setOnApplyWindowInsetsListener { _, insets ->
                deviceAdapter.setInsets(insets)
                insets
            }
        }
    }

    override fun onResume() {
        super.onResume()

        withPermissions(
            Manifest.permission.INTERNET,
            Manifest.permission.ACCESS_WIFI_STATE,
            Manifest.permission.CHANGE_WIFI_STATE,
            Manifest.permission.ACCESS_COARSE_LOCATION,
            permissionRationalRes = de.zweidenker.connectivity.R.string.permission_rationale_text) { success ->
            if (success) {
                weakReferenceHandler.get()?.post(cyclicRunnable)
                scanBeacons()
            } else {
                Toast.makeText(this, "We require all of the requested permissions in order to find p2p devices!", Toast.LENGTH_SHORT).show()
            }
        }
    }

    override fun onPause() {
        weakReferenceHandler.get()?.removeCallbacks(null)
        subscription.clear()
        super.onPause()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        PermissionHandler.onRequestPermissionsResult(requestCode, grantResults)
    }

    companion object {
        const val CYCLIC_INTERVAL = 45000L
    }
}