package de.zweidenker.connectivity.config

import android.support.v4.app.Fragment
import org.koin.android.ext.android.inject
import rx.Subscription

abstract class DeviceFragment: Fragment() {

    protected val viewModel by inject<DeviceConfigViewModel>()
    protected val configurationProvider get() = viewModel.configurationProvider

    protected fun Subscription.store() {
        viewModel.store(this)
    }

    protected fun stopLoading() {
        if(viewModel.isLoading) {
            (activity as? LoadingDisplay)?.stopLoading()
            viewModel.isLoading = false
        }
    }
}