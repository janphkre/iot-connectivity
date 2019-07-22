package de.zweidenker.p2p.model

import android.net.wifi.p2p.WifiP2pDevice
import android.os.Parcel
import android.os.Parcelable
import de.zweidenker.p2p.P2PModule
import de.zweidenker.p2p.core.IdGenerator
import de.zweidenker.p2p.model.bluetooth.BluetoothDetails
import de.zweidenker.p2p.model.wifi.WifiDetails

data class Device(
    val id: Long,
    val userIdentifier: String,
    val connectionStatus: ConnectionStatus,
    val wifiDetails: WifiDetails,
    val bluetoothDetails: BluetoothDetails,
    var connectionTime: Long
) : Parcelable {

    constructor(parcel: Parcel) : this(
        parcel.readLong(),
        parcel.readString() ?: "",
        ConnectionStatus.values()[parcel.readInt()],
        parcel.readParcelable<WifiDetails>(WifiDetails::class.java.classLoader) ?: throw IllegalArgumentException("WifiDetails was read as null!"),
        parcel.readParcelable<BluetoothDetails>(BluetoothDetails::class.java.classLoader) ?: throw IllegalArgumentException("BluetoothDetails was read as null!"),
        parcel.readLong()
    )

    constructor(p2pDevice: WifiP2pDevice, txtRecordMap: Map<String, String>): this(
        // Calculate a id from the macAddress, since the macAddress is a 48-Bit field.
        IdGenerator.getId(p2pDevice.deviceAddress),
        txtRecordMap[P2PModule.KEY_IDENTIFIER] ?: p2pDevice.deviceName,
        when (txtRecordMap[P2PModule.KEY_CONNECTION]?.toUpperCase()) {
            ConnectionStatus.COMPLETED.name -> ConnectionStatus.COMPLETED
            ConnectionStatus.DISCONNECTED.name -> ConnectionStatus.DISCONNECTED
            ConnectionStatus.PROBLEM.name -> ConnectionStatus.PROBLEM
            else -> ConnectionStatus.UNKNOWN
        },
        WifiDetails(p2pDevice, txtRecordMap),
        BluetoothDetails(txtRecordMap),
        System.currentTimeMillis()
    )

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeLong(id)
        parcel.writeString(userIdentifier)
        parcel.writeInt(connectionStatus.ordinal)
        parcel.writeParcelable(wifiDetails, 0)
        parcel.writeParcelable(bluetoothDetails, 0)
        parcel.writeLong(connectionTime)
    }

    override fun describeContents(): Int {
        return 0
    }

    override fun equals(other: Any?): Boolean {
        if (other !is Device) {
            return false
        }
        return id == other.id
    }

    fun contentEquals(other: Any?): Boolean {
        if (other !is Device) {
            return false
        }
        return userIdentifier == other.userIdentifier &&
            connectionStatus == other.connectionStatus &&
            wifiDetails.contentEquals(other.wifiDetails) &&
            bluetoothDetails.contentEquals(other.bluetoothDetails)
    }

    override fun hashCode(): Int {
        return id.hashCode()
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