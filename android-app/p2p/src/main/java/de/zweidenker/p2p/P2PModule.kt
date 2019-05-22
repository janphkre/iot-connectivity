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

object P2PModule : Module {
    internal const val TYPE_SERVICE = "connectivity.pharo._tcp.local."
    internal const val TYPE_IP_SERVICE = "ip.pharo._tcp.local."

    internal const val NAME_IP_RECEIVER_THREAD = "IpReceiverBackgroundThread"
    internal const val NAME_BEACON_THREAD = "BeaconBackgroundThread"
    internal const val NAME_CONFIG_THREAD = "ConfigurationBackgroundThread"

    internal const val KEY_IDENTIFIER = "identifier"
    internal const val KEY_CONNECTION = "connection"
    internal const val KEY_PORT = "port"
    internal const val KEY_IP = "ip"

    internal const val SOCKET_TIMEOUT_MS = 60000
    internal const val PING_PORT = 8890

    internal const val ERROR_RETRY_INTERVAL_MS = 5000L
    internal const val DISCOVER_INTERVAL_MS = 15000L

    override fun invoke(koinContext: KoinContext): ModuleDefinition = module {
        single { BeaconProviderImpl(androidContext()) as BeaconProvider }
        factory { DeviceConnectionProviderImpl(androidContext()) as DeviceConnectionProvider }
    }(koinContext)
}