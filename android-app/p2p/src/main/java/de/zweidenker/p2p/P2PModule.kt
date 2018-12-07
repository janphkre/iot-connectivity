package de.zweidenker.p2p

import de.zweidenker.p2p.beacon.BeaconProvider
import de.zweidenker.p2p.beacon.BeaconProviderImpl
import de.zweidenker.p2p.server.DeviceConfigurationProvider
import de.zweidenker.p2p.server.DeviceConfigurationProviderImpl
import org.koin.android.ext.koin.androidContext
import org.koin.core.KoinContext
import org.koin.dsl.context.ModuleDefinition
import org.koin.dsl.module.Module
import org.koin.dsl.module.module

object P2PModule: Module {
    override fun invoke(koinContext: KoinContext): ModuleDefinition = module {
        single { BeaconProviderImpl(androidContext()) as BeaconProvider }
        factory { DeviceConfigurationProviderImpl(androidContext()) as DeviceConfigurationProvider }
    }(koinContext)
}