package de.zweidenker.connectivity

import de.zweidenker.connectivity.config.DeviceConfigViewModel
import org.koin.core.KoinContext
import org.koin.dsl.context.ModuleDefinition
import org.koin.dsl.module.Module
import org.koin.dsl.module.module

object ApplicationModule: Module {

    const val DEVICE_CONFIG_SCOPE = "DeviceConfigScope"

    override fun invoke(koinContext: KoinContext) = module {
        scope(DEVICE_CONFIG_SCOPE) {
            factory { DeviceConfigViewModel(get()) }
        }
    }(koinContext)
}