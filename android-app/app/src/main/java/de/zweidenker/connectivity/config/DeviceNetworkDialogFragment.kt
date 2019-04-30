package de.zweidenker.connectivity.config

import android.app.Dialog
import android.os.Bundle
import android.support.v4.app.DialogFragment
import android.support.v7.app.AlertDialog
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import de.zweidenker.connectivity.R
import org.koin.android.ext.android.inject

class DeviceNetworkDialogFragment: DialogFragment() {

    private val viewModel by inject<DeviceConfigViewModel>()

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val builder = AlertDialog.Builder(requireContext(), 0)
        return builder.create()
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.dialog_network_config, container, false)
    }
}