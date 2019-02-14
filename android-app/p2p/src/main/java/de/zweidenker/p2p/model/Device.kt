package de.zweidenker.p2p.model

import android.net.wifi.WpsInfo
import android.net.wifi.p2p.WifiP2pConfig
import android.net.wifi.p2p.WifiP2pDevice
import android.os.Parcel
import android.os.Parcelable
import de.zweidenker.p2p.P2PModule
import de.zweidenker.p2p.core.IdGenerator

class Device(
    val id: Long,
    val userIdentifier: String,
    val address: String,
    val connectionStatus: ConnectionStatus,
    val port: Int) : Parcelable {

    enum class ConnectionStatus {
        UNKNOWN, UP, DOWN, PROBLEM
    }

    constructor(parcel: Parcel) : this(
        parcel.readLong(),
        parcel.readString() ?: "",
        parcel.readString() ?: "",
        ConnectionStatus.values()[parcel.readInt()],
        parcel.readInt()
    )

    constructor(p2pDevice: WifiP2pDevice, txtRecordMap: Map<String, String>): this (
        //Calculate a id from the macAddress, since the macAddress is a 48-Bit field.
        IdGenerator.getId(p2pDevice.deviceAddress),
        txtRecordMap[P2PModule.KEY_IDENTIFIER] ?: p2pDevice.deviceName,
        p2pDevice.deviceAddress,
        when(txtRecordMap[P2PModule.KEY_CONNECTION]?.toUpperCase()) {
            ConnectionStatus.UP.name -> ConnectionStatus.UP
            ConnectionStatus.DOWN.name -> ConnectionStatus.DOWN
            ConnectionStatus.PROBLEM.name -> ConnectionStatus.PROBLEM
            else -> ConnectionStatus.UNKNOWN
        },
        txtRecordMap[P2PModule.KEY_PORT]?.toIntOrNull() ?: throw IllegalArgumentException("Missing Port!")
    )

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeLong(id)
        parcel.writeString(userIdentifier)
        parcel.writeString(address)
        parcel.writeInt(connectionStatus.ordinal)
        parcel.writeInt(port)
    }

    override fun describeContents(): Int {
        return 0
    }

    override fun equals(other: Any?): Boolean {
        if(other !is Device) {
            return false
        }
        return id == other.id &&
            userIdentifier == other.userIdentifier &&
            address == other.address &&
            connectionStatus == other.connectionStatus &&
            port == other.port
    }

    override fun hashCode(): Int {
        var result = id.hashCode()
        result = 31 * result + userIdentifier.hashCode()
        result = 31 * result + address.hashCode()
        result = 31 * result + connectionStatus.hashCode()
        result = 31 * result + port
        return result
    }

    fun asConfig(): WifiP2pConfig {
        return WifiP2pConfig().apply {
            this.deviceAddress = this@Device.address
            this.groupOwnerIntent = 0
            this.wps.setup = WpsInfo.PBC
        }
    }
    companion object CREATOR : Parcelable.Creator<Device> {

        override fun createFromParcel(parcel: Parcel): Device {
            return Device(parcel)
        }

        override fun newArray(size: Int): Array<Device?> {
            return arrayOfNulls(size)
        }
    }

}