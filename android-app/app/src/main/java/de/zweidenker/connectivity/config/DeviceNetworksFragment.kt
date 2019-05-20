package de.zweidenker.connectivity.config

import android.os.Handler
import android.support.annotation.DrawableRes
import android.support.v7.widget.LinearLayoutManager
import android.widget.Toast
import de.zweidenker.connectivity.R
import de.zweidenker.p2p.model.Network
import de.zweidenker.p2p.model.NetworkConfig
import kotlinx.android.synthetic.main.fragment_list.*
import kotlinx.android.synthetic.main.item_card_image.view.*
import rx.Observer
import rx.android.schedulers.AndroidSchedulers
import rx.schedulers.Schedulers
import timber.log.Timber
import java.util.LinkedList

class DeviceNetworksFragment : DeviceFragment(), Observer<List<Pair<Network?, NetworkConfig?>>> {

    private val reloadIntervalMs = 5000L
    private val errorThreshold = 4
    private var errorCount = 0
    private lateinit var recyclerAdapter: GenericConfigAdapter<Pair<Network?, NetworkConfig?>>
    private val handler = Handler()

    override fun getTitle(): String {
        return "${viewModel.device.userIdentifier} - ${viewModel.interfaceId}"
    }

    override fun loadData() {
        val interfaceId = viewModel.interfaceId ?: return // TODO: SHOW AN ERROR?
        configurationProvider.getAvailableNetworks(interfaceId)
            .zipWith(configurationProvider.getNetworkConfigs(interfaceId)) { networks, configs ->
                val undetectedConfigs = configs.toMutableSet()
                val result = networks.mapTo(LinkedList<Pair<Network?, NetworkConfig?>>()) { network ->
                    val config = undetectedConfigs.find { it.ssid == network.ssid }
                    if (config != null) {
                        undetectedConfigs.remove(config)
                    }
                    Pair(network, config)
                }
                undetectedConfigs.forEach { result.add(Pair<Network?, NetworkConfig?>(null, it)) }
                result.sortBy { it.first?.ssid ?: it.second?.ssid }
                result
            }
            .subscribeOn(Schedulers.computation())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(this)
            .store()
    }

    override fun setupView() {
        view_recycler.apply {
            layoutManager = LinearLayoutManager(context, LinearLayoutManager.VERTICAL, false)
            recyclerAdapter = GenericConfigAdapter(R.layout.item_card_image, ::selectNetwork) { networkPair, view ->
                if (networkPair.first != null) {
                    networkPair.first?.let { network ->
                        view.card_title.text = network.ssid
                        view.card_subtitle.text = resources.getString(R.string.config_subtitle, network.connectionStatus.name, network.security.joinToString())
                        if (networkPair.second != null) {
                            view.card_detail.text = resources.getString(R.string.config_saved)
                            if(networkPair.second?.selected == true) {
                                view.card_icon.setColorFilter(resources.getColor(R.color.primary))
                            } else {
                                view.card_icon.clearColorFilter()
                            }
                        } else {
                            view.card_detail.text = ""
                        }
                        view.card_icon.setImageResource(network.signalStrength.toWifiImage())
                    }
                } else {
                    networkPair.second?.let { config ->
                        view.card_title.text = config.ssid
                        view.card_subtitle.text = if (config.disabled) {
                            resources.getString(R.string.config_disabled)
                        } else {
                            resources.getString(R.string.config_enabled)
                        }
                        view.card_detail.text = resources.getString(R.string.config_saved)
                        if(config.selected) {
                            view.card_icon.setImageResource(R.drawable.ic_signal_wifi_off)
                            view.card_icon.setColorFilter(resources.getColor(R.color.primary))
                        } else {
                            view.card_icon.clearColorFilter()
                        }
                    }
                }
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

    override fun onNext(networks: List<Pair<Network?, NetworkConfig?>>) {
        recyclerAdapter.setItems(networks)
        stopLoading()
        errorCount = 0
        handler.postDelayed(::loadData, reloadIntervalMs)
    }

    override fun onCompleted() { }

    private fun selectNetwork(networkPair: Pair<Network?, NetworkConfig?>) {
        viewModel.network = networkPair
        (activity as? ConfigContainer)?.showDialog(DeviceNetworkDialogFragment())
    }
}