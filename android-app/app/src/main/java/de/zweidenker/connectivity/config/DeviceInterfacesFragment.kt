package de.zweidenker.connectivity.config

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import de.zweidenker.connectivity.R
import de.zweidenker.p2p.model.Interface
import rx.Observer
import rx.android.schedulers.AndroidSchedulers
import rx.schedulers.Schedulers
import timber.log.Timber

class DeviceInterfacesFragment: DeviceFragment(), Observer<List<Interface>> {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        configurationProvider.getInterfaces()
            .subscribeOn(Schedulers.computation())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(this)
            .store()
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.fragment_device_interfaces, container, true)
    }

    override fun onError(e: Throwable) {
        Timber.e(e)
        Toast.makeText(context, "Could not obtain a list of interfaces on the device!", Toast.LENGTH_SHORT).show()
        //TODO??
    }

    override fun onNext(interfaces: List<Interface>) {
        when(interfaces.size) {
            0 -> {
                stopLoading()
                TODO("SHOW EMPTY VIEW")
            }
            1 -> {
                TODO("LOAD NEXT FRAGMENT AND UPDATE TITLE")
            }
            else -> {
                stopLoading()
                //TODO: ADD INTERFACES TO THE FRAGMENT
            }
        }
    }

    override fun onCompleted() { }
}