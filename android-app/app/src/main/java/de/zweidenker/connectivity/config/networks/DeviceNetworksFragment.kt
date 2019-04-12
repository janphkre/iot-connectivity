package de.zweidenker.connectivity.config.networks

import android.support.v7.widget.LinearLayoutManager
import android.widget.Toast
import de.zweidenker.connectivity.R
import de.zweidenker.connectivity.config.DeviceFragment
import de.zweidenker.connectivity.config.GenericConfigAdapter
import de.zweidenker.p2p.model.Network
import kotlinx.android.synthetic.main.fragment_list.*
import rx.Observer
import rx.android.schedulers.AndroidSchedulers
import rx.schedulers.Schedulers
import timber.log.Timber

class DeviceNetworksFragment: DeviceFragment(), Observer<List<Network>> {

    private lateinit var recyclerAdapter: GenericConfigAdapter<Network>

    override fun getTitle(): String {
        return "${viewModel.device.userIdentifier} - ${viewModel.interfaceId}"
    }

    override fun loadData() {
        val interfaceId = viewModel.interfaceId ?: return //TODO: SHOW AN ERROR?
        configurationProvider.getAvailableNetworks(interfaceId)
            .subscribeOn(Schedulers.computation())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(this)
            .store()
    }

    override fun setupView() {
        view_recycler.apply {
            layoutManager = LinearLayoutManager(context, LinearLayoutManager.VERTICAL, false)
            recyclerAdapter = GenericConfigAdapter(context, R.layout.item_network, ::selectNetwork) { network, view ->
                TODO("BIND network to view!")
            }
            adapter = recyclerAdapter
        }
    }

    override fun onError(e: Throwable) {
        Timber.e(e)
        Toast.makeText(context, "Could not obtain a list of networks on the interface!", Toast.LENGTH_SHORT).show()
        //TODO??
    }

    override fun onNext(networks: List<Network>) {
        recyclerAdapter.setItems(networks)
        stopLoading()
        //TODO: ADD A PERIODIC RELOAD OF AVAILABLE NETWORKS
    }

    override fun onCompleted() { }

    private fun selectNetwork(network: Network) {
        TODO("SELECT NETWORK!")
    }
}