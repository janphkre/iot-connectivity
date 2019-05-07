package de.zweidenker.connectivity.config

import android.os.Handler
import android.support.annotation.DrawableRes
import android.support.v7.widget.LinearLayoutManager
import android.widget.Toast
import de.zweidenker.connectivity.R
import de.zweidenker.p2p.model.Network
import kotlinx.android.synthetic.main.fragment_list.*
import kotlinx.android.synthetic.main.item_card_image.view.*
import rx.Observer
import rx.android.schedulers.AndroidSchedulers
import rx.schedulers.Schedulers
import timber.log.Timber

class DeviceNetworksFragment : DeviceFragment(), Observer<List<Network>> {

    private val reloadIntervalMs = 5000L
    private val errorThreshold = 4
    private var errorCount = 0
    private lateinit var recyclerAdapter: GenericConfigAdapter<Network>
    private val handler = Handler()

    override fun getTitle(): String {
        return "${viewModel.device.userIdentifier} - ${viewModel.interfaceId}"
    }

    override fun loadData() {
        val interfaceId = viewModel.interfaceId ?: return // TODO: SHOW AN ERROR?
        configurationProvider.getAvailableNetworks(interfaceId)
            .subscribeOn(Schedulers.computation())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(this)
            .store()
    }

    override fun setupView() {
        view_recycler.apply {
            layoutManager = LinearLayoutManager(context, LinearLayoutManager.VERTICAL, false)
            recyclerAdapter = GenericConfigAdapter(context, R.layout.item_card_image, ::selectNetwork) { network, view ->
                view.card_title.text = network.ssid
                view.card_subtitle.text = resources.getString(R.string.config_subtitle, network.connectionStatus.name, network.securityType)
                view.card_detail.text = network.mac
                view.card_icon.setImageResource(network.signalStrength.toWifiImage())
            }
            adapter = recyclerAdapter
        }
    }

    override fun onPause() {
        handler.removeCallbacksAndMessages(null)
        super.onPause()
    }

    /**
     * Converts a db(a) measurement into an icon.
     * The threshold values are taken from testing on an android device.
     */
    @DrawableRes
    private fun Int.toWifiImage(): Int {
        return when {
            this >= 0 -> R.drawable.ic_signal_wifi_off
            this > -65 -> R.drawable.ic_signal_wifi_4_bar
            this > -75 -> R.drawable.ic_signal_wifi_3_bar
            this > -83 -> R.drawable.ic_signal_wifi_2_bar
            this > -91 -> R.drawable.ic_signal_wifi_1_bar
            else -> R.drawable.ic_signal_wifi_0_bar
        }
    }

    override fun onError(e: Throwable) {
        Timber.e(e)
        if (errorCount == 1) {
            Toast.makeText(context, "Could not obtain a list of networks on the interface!", Toast.LENGTH_SHORT).show()
        }
        errorCount = (errorCount + 1) % errorThreshold
        handler.postDelayed(::loadData, reloadIntervalMs)
    }

    override fun onNext(networks: List<Network>) {
        recyclerAdapter.setItems(networks)
        stopLoading()
        errorCount = 0
        handler.postDelayed(::loadData, reloadIntervalMs)
    }

    override fun onCompleted() { }

    private fun selectNetwork(network: Network) {
        viewModel.network = network
        (activity as? ConfigContainer)?.showDialog(DeviceNetworkDialogFragment())
        TODO("SELECT NETWORK!")
    }
}