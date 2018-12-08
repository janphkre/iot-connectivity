package de.zweidenker.connectivity.util

import android.app.Activity
import android.support.annotation.StringRes
import android.support.v4.app.ActivityCompat
import android.support.v7.app.AlertDialog
import de.zweidenker.connectivity.R
import permissions.dispatcher.PermissionUtils
import java.util.concurrent.atomic.AtomicInteger

object PermissionHandler {

    private var permissionCallbackMap: HashMap<Int, (Boolean) -> Unit> = HashMap()
    private val requestCodeInteger = AtomicInteger(100)

    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray) {
        synchronized(permissionCallbackMap) {
            permissionCallbackMap.remove(requestCode)
        }?.invoke(PermissionUtils.verifyPermissions(*grantResults))
    }

    internal fun getUniqueRequestCode(): Int {
        return requestCodeInteger.incrementAndGet()
    }

    internal fun putRequestCallback(requestCode: Int, callback: (Boolean) -> Unit) {
        synchronized(permissionCallbackMap) {
            permissionCallbackMap.put(requestCode, callback)
        }
    }
}

fun Activity.withPermissions(vararg permissions: String, @StringRes permissionRationalRes: Int? = null, callback: (Boolean) -> Unit) {
    if (PermissionUtils.hasSelfPermissions(this ?: return, *permissions)) {
        callback(true)
    } else {
        if (PermissionUtils.shouldShowRequestPermissionRationale(this, *permissions)) {
            if (permissionRationalRes != null) {
                AlertDialog.Builder(this).apply {
                    setTitle(R.string.permission_rationale_title)
                            .setMessage(permissionRationalRes)
                            .setPositiveButton(R.string.ok, null)
                            .setOnDismissListener {
                                requestPermissions(permissions, callback)
                            }
                            .create().show()
                    return
                }
            }
        }
        requestPermissions(permissions, callback)
    }
}

private fun Activity.requestPermissions(permissions: Array<out String>, callback: (Boolean) -> Unit) {
    val requestCode = PermissionHandler.getUniqueRequestCode()
    PermissionHandler.putRequestCallback(requestCode, callback)
    ActivityCompat.requestPermissions(this, permissions, requestCode)
}