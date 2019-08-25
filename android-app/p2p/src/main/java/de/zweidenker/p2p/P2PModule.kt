package de.zweidenker.p2p

import com.classycode.nfcsockets.NFCMessageProvider
import de.zweidenker.p2p.beacon.BeaconProvider
import de.zweidenker.p2p.beacon.BeaconProviderImpl
import de.zweidenker.p2p.connection.DeviceConnectionProvider
import de.zweidenker.p2p.connection.bluetooth.BluetoothConnectionProvider
import de.zweidenker.p2p.connection.nfc.NFCConnectionProvider
import de.zweidenker.p2p.connection.usb.USBConnectionProvider
import de.zweidenker.p2p.connection.wifi.WiFiConnectionProvider
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
    internal const val KEY_BLUETOOTH_MAC = "bluetooth_mac"
    internal const val KEY_BLUETOOTH_PORT = "bluetooth_port"
    internal const val SOCKET_TIMEOUT_MS = 30000
    internal const val PING_PORT = 8890

    internal const val CONNECTION_TIMEOUT_S = 30L
    internal const val BLUETOOTH_ENABLE_SLEEP_MS = 5000L
    internal const val ERROR_RETRY_INTERVAL_MS = 5000L
    internal const val DISCOVER_INTERVAL_MS = 15000L
    internal const val USB_BROADCAST_CODE = 5000
    internal const val USB_BROADCAST_ACTION = "de.zweidenker.p2p.usb"

    const val wifiDirectScope = "wifi"
    const val bluetoothScope = "bluetooth"
    const val nfcScope = "nfc"
    const val usbScope = "usb"

    override fun invoke(koinContext: KoinContext): ModuleDefinition = module {
        single<BeaconProvider> { BeaconProviderImpl(androidContext()) }
        scope(wifiDirectScope) {
            factory<DeviceConnectionProvider> { WiFiConnectionProvider(get()) }
        }
        scope(bluetoothScope) {
            factory<DeviceConnectionProvider> { BluetoothConnectionProvider() }
        }
        scope(nfcScope) {
            factory<DeviceConnectionProvider> { NFCConnectionProvider() }
            single { NFCMessageProvider() }
        }
        scope(usbScope) {
            factory<DeviceConnectionProvider> { USBConnectionProvider(get()) }
        }
    }(koinContext)
}