package de.zweidenker.p2p

import de.zweidenker.p2p.beacon.BeaconProvider
import de.zweidenker.p2p.beacon.BeaconProviderImpl
import de.zweidenker.p2p.connection.DeviceConnectionProvider
import de.zweidenker.p2p.connection.DeviceConnectionProviderImpl
import org.koin.android.ext.koin.androidContext
import org.koin.core.KoinContext
import org.koin.dsl.context.ModuleDefinition
import org.koin.dsl.module.Module
import org.koin.dsl.module.module

object P2PModule: Module {
    internal const val TYPE_SERVICE = "connectivity.pharo._tcp.local."

    internal const val NAME_BEACON_THREAD = "BeaconBackgroundThread"
    internal const val NAME_CONFIG_THREAD ="ConfigurationBackgroundThread"

    internal const val KEY_IDENTIFIER = "identifier"
    internal const val KEY_CONNECTION = "connection"
    internal const val KEY_PORT = "port"

    internal const val TIMEOUT_SOCKET = 5000

    override fun invoke(koinContext: KoinContext): ModuleDefinition = module {
        single { BeaconProviderImpl(androidContext()) as BeaconProvider }
        factory { DeviceConnectionProviderImpl(androidContext()) as DeviceConnectionProvider }
    }(koinContext)
}