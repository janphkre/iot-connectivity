package de.zweidenker.connectivity.config

interface LoadingDisplay {
    fun stopLoading()
    fun startLoading()
    fun setTitle(title: String)
}