package de.zweidenker.connectivity.list

import android.Manifest
import android.os.Build
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.widget.Toast
import de.zweidenker.connectivity.R
import de.zweidenker.connectivity.util.PermissionHandler
import de.zweidenker.connectivity.util.withPermissions
import de.zweidenker.p2p.beacon.BeaconProvider
import de.zweidenker.p2p.model.Device
import kotlinx.android.synthetic.main.activity_device_list.*
import org.koin.android.ext.android.inject
import rx.Observer
import rx.Subscription
import rx.schedulers.Schedulers
import timber.log.Timber

/**
 * I list all devices that are available through the beacon provider.
 * Every item in my list can be clicked to start the DeviceConfigActivity on it.
 */
class DeviceListActivity : AppCompatActivity(), Observer<Device> {

    private lateinit var deviceAdapter: DeviceAdapter
    private val beaconProvider by inject<BeaconProvider>()
    private var subscription: Subscription? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_device_list)
        setupDeviceList()
        setupHeader()
    }

    private fun setupDeviceList() {
        deviceAdapter = DeviceAdapter(this)
        list_device.layoutManager = LinearLayoutManager(this, RecyclerView.VERTICAL, false)
        list_device.adapter = deviceAdapter
        // TODO: DELETE this comment:
//                .apply {
//            addItem(Device("00:11:12:13:14:15","DOMAIN_NAME","TYPE"))
//            addItem(Device("00:11:12:13:14:16","DOMAIN_NAME","TYPE"))
//            addItem(Device("00:11:12:13:14:17","DOMAIN_NAME","TYPE"))
//            addItem(Device("00:11:12:13:14:19","DOMAIN_NAME","TYPE"))
//            addItem(Device("00:11:12:13:14:1A","DOMAIN_NAME","TYPE"))
//            addItem(Device("00:11:12:13:14:1B","DOMAIN_NAME","TYPE"))
//            addItem(Device("00:11:12:13:14:1C","DOMAIN_NAME","TYPE"))
//            addItem(Device("00:11:12:13:14:1D","DOMAIN_NAME","TYPE"))
//            addItem(Device("00:11:12:13:14:1E","DOMAIN_NAME","TYPE"))
//            addItem(Device("00:11:12:13:14:1F","DOMAIN_NAME","TYPE"))
//        }
    }

    private fun setupHeader() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
            frame_device.setOnApplyWindowInsetsListener { _, insets ->
                deviceAdapter.setInsets(insets)
                insets
            }
        }
    }

    override fun onStart() {
        super.onStart()
        withPermissions(
            Manifest.permission.INTERNET,
            Manifest.permission.ACCESS_WIFI_STATE,
            Manifest.permission.CHANGE_WIFI_STATE,
            Manifest.permission.ACCESS_COARSE_LOCATION,
            permissionRationalRes = R.string.permission_rationale_text) { success ->
            if (success) {
                beaconProvider.getBeacons()
                    .subscribeOn(Schedulers.io())
                    .observeOn(Schedulers.computation())
                    .subscribe(this)
            } else {
                Toast.makeText(this, "We require all of the requested permissions in order to find p2p devices!", Toast.LENGTH_SHORT).show()
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        PermissionHandler.onRequestPermissionsResult(requestCode, grantResults)
    }

    override fun onError(e: Throwable) {
        Toast.makeText(this, e.localizedMessage, Toast.LENGTH_SHORT).show()
        // TODO: JUST RETRY?
        Timber.e(e)
    }

    override fun onNext(device: Device) {
        deviceAdapter.addItem(device)
    }

    override fun onCompleted() { /* should never be called */ }

    override fun onPause() {
        subscription?.unsubscribe()
        subscription = null
        super.onPause()
    }
}