package de.zweidenker.connectivity.config

import android.app.Dialog
import android.os.Bundle
import android.support.v4.app.DialogFragment
import android.support.v7.app.AlertDialog
import android.view.LayoutInflater
import android.view.View
import android.widget.Toast
import de.zweidenker.connectivity.R
import de.zweidenker.p2p.model.Network
import de.zweidenker.p2p.model.NetworkConfig
import de.zweidenker.p2p.model.NetworkConfigProposal
import de.zweidenker.p2p.model.NetworkConfigUpdate
import kotlinx.android.synthetic.main.dialog_network_config.view.*
import org.koin.android.ext.android.inject
import rx.Observer
import rx.Subscription
import rx.android.schedulers.AndroidSchedulers
import rx.schedulers.Schedulers

class DeviceNetworkDialogFragment : DialogFragment(), Observer<NetworkConfig> {
    private val viewModel by inject<DeviceConfigViewModel>()

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val view = LayoutInflater.from(requireContext()).inflate(R.layout.dialog_network_config, null, false)
        view.network_connect.setOnClickListener {
            val networkPair = viewModel.network
            val interfaceId = viewModel.interfaceId
            if (interfaceId == null || networkPair == null) {
                Toast.makeText(it.context, R.string.network_viewmodel_error, Toast.LENGTH_SHORT).show()
                close()
                return@setOnClickListener
            }
            if (networkPair.second != null) {
                updateNetworkClick(networkPair.second!!, interfaceId)
            } else {
                addNetworkClick(networkPair.first!!, interfaceId)
            }
        }
        view.network_cancel.setOnClickListener {
            dialog?.dismiss()
        }
        return AlertDialog.Builder(requireContext(), R.style.AlertDialogStyle)
            .setTitle(viewModel.getNetworkSsid())
            .setView(view)
            .setCancelable(true)
            .create().apply {
                setCanceledOnTouchOutside(true)
            }
    }

    private fun updateNetworkClick(existingConfig: NetworkConfig, interfaceId: String) {
        startLoading()
        val password = view?.password_input?.text
        val passwordString = if (password?.isNotBlank() != true) {
            null
        } else {
            password.toString()
        }
        val networkConfig = NetworkConfigUpdate(existingConfig.ssid, passwordString, disabled = false, selected = true)
        viewModel.updateNetworkConfig(interfaceId, existingConfig.networkId.toString(), networkConfig)
            .subscribeOn(Schedulers.computation())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(this)
            .store()
    }

    private fun addNetworkClick(network: Network, interfaceId: String) {
        val password = view?.password_input?.text
        if (password?.isNotBlank() != true) {
            view?.let {
                Toast.makeText(it.context, R.string.network_password_blank, Toast.LENGTH_SHORT).show()
            }
            return
        }
        startLoading()

        val networkConfig = NetworkConfigProposal(network.ssid, password.toString(), network.security.first())
        viewModel.addNetworkConfig(interfaceId, networkConfig)
            .subscribeOn(Schedulers.computation())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(this)
            .store()
    }

    private fun startLoading() {
        view?.loading_view?.visibility = View.VISIBLE
        dialog?.setCancelable(false)
        dialog?.setCanceledOnTouchOutside(false)
    }

    private fun stopLoading() {
        view?.loading_view?.visibility = View.GONE
        dialog?.setCancelable(true)
        dialog?.setCanceledOnTouchOutside(true)
    }

    private fun close() {
        dismissAllowingStateLoss()
        activity?.finish()
    }

    private fun Subscription.store() {
        viewModel.store(this)
    }

    override fun onError(e: Throwable?) {
        stopLoading()
        context?.let {
            Toast.makeText(it, e?.localizedMessage ?: "", Toast.LENGTH_SHORT).show()
        }
    }

    override fun onNext(configuration: NetworkConfig?) {
        // TODO: MAYBE PROVIDE SOME FEEDBACK TO THE USER
        context?.let {
            Toast.makeText(it, R.string.network_success, Toast.LENGTH_SHORT).show()
        }
        close()
    }

    override fun onCompleted() { }
}