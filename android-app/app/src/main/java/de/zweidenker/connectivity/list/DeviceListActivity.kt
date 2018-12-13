package de.zweidenker.connectivity.list

import android.Manifest
import android.os.Build
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.util.Log
import de.zweidenker.connectivity.R
import de.zweidenker.connectivity.util.PermissionHandler
import de.zweidenker.connectivity.util.withPermissions
import de.zweidenker.p2p.beacon.BeaconProvider
import de.zweidenker.p2p.beacon.Device
import kotlinx.android.synthetic.main.activity_device_list.*
import org.koin.android.ext.android.inject
import rx.Observer
import rx.Subscription
import rx.android.schedulers.AndroidSchedulers
import rx.schedulers.Schedulers
import timber.log.Timber

class DeviceListActivity: AppCompatActivity(), Observer<Device> {

    private lateinit var deviceAdapter: DeviceAdapter
    private val beaconProvider by inject<BeaconProvider>()
    private var subscription: Subscription? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_device_list)
        setupDeviceList()
        setupHeader()
        setupBeacons()
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
        //TODO!
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
            frame_device.setOnApplyWindowInsetsListener { v, insets ->
                Log.e("TEST","GOT WINDOW INSETS ${insets.systemWindowInsetTop}")
                deviceAdapter.setInsets(insets)
                insets
            }
        }

    }

    private fun setupBeacons() {
        withPermissions(
                Manifest.permission.INTERNET,
                Manifest.permission.ACCESS_WIFI_STATE,
                Manifest.permission.CHANGE_WIFI_STATE,
                Manifest.permission.ACCESS_COARSE_LOCATION,
                permissionRationalRes = R.string.permission_rationale_text) { success ->
            if(success) {
                beaconProvider.getBeacons(this)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(this)
            } else {
                //TODO NOTIFY: THIS APP WILL NOT WORK WITHOUT THE REQUESTED PERMISSIONS!
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        PermissionHandler.onRequestPermissionsResult(requestCode, grantResults)
    }

    override fun onError(e: Throwable) {
        //TODO? report error to user?
        Timber.e(e)
    }

    override fun onNext(device: Device) {
        deviceAdapter.addItem(device)
    }

    override fun onCompleted() { /* should never be called */ }

    override fun onDestroy() {
        super.onDestroy()
        subscription?.unsubscribe()
        subscription = null
    }
}