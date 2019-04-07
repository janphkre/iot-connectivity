package de.zweidenker.connectivity.config

import android.os.Bundle
import android.support.v4.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import de.zweidenker.connectivity.R
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

    protected fun goBack() {
        activity?.supportFragmentManager?.popBackStack()
    }

    protected abstract fun loadData()
    protected abstract fun setupView()
    protected abstract fun getTitle(): String

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.fragment_list, container, true)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        //TODO: SET TITLE!
        setupView()
        loadData()

    }
}