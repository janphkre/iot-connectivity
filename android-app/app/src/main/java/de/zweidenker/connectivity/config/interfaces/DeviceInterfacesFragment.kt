package de.zweidenker.connectivity.config.interfaces

import android.support.v7.widget.LinearLayoutManager
import android.widget.Toast
import de.zweidenker.connectivity.R
import de.zweidenker.connectivity.config.DeviceFragment
import de.zweidenker.connectivity.config.GenericConfigAdapter
import de.zweidenker.p2p.model.Interface
import kotlinx.android.synthetic.main.fragment_list.*
import rx.Observer
import rx.android.schedulers.AndroidSchedulers
import rx.schedulers.Schedulers
import timber.log.Timber

class DeviceInterfacesFragment: DeviceFragment(), Observer<List<Interface>> {

    private lateinit var recyclerAdapter: GenericConfigAdapter<Interface>

    override fun getTitle(): String {
        return viewModel.device.userIdentifier
    }

    override fun loadData() {
        configurationProvider.getInterfaces()
            .subscribeOn(Schedulers.computation())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(this)
            .store()
    }

    override fun setupView() {
        view_recycler.apply {
            layoutManager = LinearLayoutManager(context, LinearLayoutManager.VERTICAL, false)
            recyclerAdapter = GenericConfigAdapter(context, R.layout.item_interface, ::selectInterface) { iface, view ->
                TODO("BIND!")
            }
            adapter = recyclerAdapter
        }
    }

    override fun onError(e: Throwable) {
        Timber.e(e)
        Toast.makeText(context, "Could not obtain a list of interfaces on the device!", Toast.LENGTH_SHORT).show()
        //TODO??
    }

    override fun onNext(interfaces: List<Interface>) {
        when(interfaces.size) {
            0 -> {
                recyclerAdapter.setItems(emptyList())
                stopLoading()
            }
            1 -> {
                selectInterface(interfaces.first())
            }
            else -> {
                recyclerAdapter.setItems(interfaces)
                stopLoading()
            }
        }
    }

    override fun onCompleted() { }

    private fun selectInterface(iface: Interface) {
        //TODO!
    }
}