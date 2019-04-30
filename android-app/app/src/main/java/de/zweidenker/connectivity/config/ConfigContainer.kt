package de.zweidenker.connectivity.config

import android.support.v4.app.DialogFragment

interface ConfigContainer {
    fun stopLoading()
    fun startLoading()
    fun setTitle(title: String)
    fun switchToInterfaces()
    fun switchToNetworks()
    fun showDialog(dialog: DialogFragment)
}