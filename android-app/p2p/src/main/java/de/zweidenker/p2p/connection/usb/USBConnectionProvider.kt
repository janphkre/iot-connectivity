package de.zweidenker.p2p.connection.usb

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbAccessory
import android.hardware.usb.UsbManager
import android.os.ParcelFileDescriptor
import android.util.Log
import de.zweidenker.p2p.P2PModule
import de.zweidenker.p2p.connection.http.ConnectionStream
import de.zweidenker.p2p.connection.http.SimpleConnectionProvider
import de.zweidenker.p2p.model.Device
import rx.subjects.PublishSubject
import java.io.IOException

class USBConnectionProvider(
    context: Context
): SimpleConnectionProvider("usb") {

    private val permissionSubject = PublishSubject.create<Boolean>()
    private val broadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if(intent == null) return
            if(intent.action == P2PModule.USB_BROADCAST_ACTION) {
                permissionSubject.onNext(intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false))
            }
        }
    }
    private val pendingIntent = PendingIntent.getBroadcast(
        context,
        P2PModule.USB_BROADCAST_CODE,
        Intent().apply { action = P2PModule.USB_BROADCAST_ACTION },
        0)
    private val usbManager: UsbManager? = context.getSystemService(Context.USB_SERVICE) as? UsbManager
    private var fileDescriptor: ParcelFileDescriptor? = null

    init {
        context.registerReceiver(broadcastReceiver, IntentFilter(P2PModule.USB_BROADCAST_ACTION))
    }

    override fun httpStreamFor(device: Device): ConnectionStream {
        /*if(PackageManager.FEATURE_USB_ACCESSORY) {

        }*/
        if(usbManager == null) {
            throw IOException("No usb manager available!")
        }
        val accessory: UsbAccessory = usbManager.accessoryList.firstOrNull() ?: throw IOException("No usb device connected!")
        fileDescriptor = if(usbManager.hasPermission(accessory)) {
            usbManager.openAccessory(accessory)
        } else {
            requestPermission(accessory)
        }
        return USBConnectionStream(fileDescriptor ?: throw IOException("Failed to open link to device!"))
    }

    override fun destroy(context: Context) {
        try {
            context.unregisterReceiver(broadcastReceiver)
        } catch(e: IllegalArgumentException) {
            e.printStackTrace()
        }
        pendingIntent.cancel()
        fileDescriptor?.close()
        fileDescriptor = null
        super.destroy(context)
    }

    private fun requestPermission(accessory: UsbAccessory): ParcelFileDescriptor? {
        Log.e("UsbConnectionProvider","Requesting permission")
        usbManager?.requestPermission(accessory, pendingIntent)
        return if(permissionSubject.toBlocking().first()) {
            usbManager!!.openAccessory(accessory)
        } else {
            null
        }
    }
}