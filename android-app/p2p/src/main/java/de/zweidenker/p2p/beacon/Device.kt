package de.zweidenker.p2p.beacon

import android.os.Parcel
import android.os.Parcelable
import de.zweidenker.p2p.core.IdGenerator

class Device(
    val id: Long,
    val userIdentifier: String,
    val domainName: String,
    val connectionStatus: ConnectionStatus) : Parcelable {

    enum class ConnectionStatus {
        UNKNOWN, UP, DOWN, PROBLEM
    }

    constructor(parcel: Parcel) : this(
        parcel.readLong(),
        parcel.readString() ?: "",
        parcel.readString() ?: "",
        ConnectionStatus.values()[parcel.readInt()]) {
    }

    /*TODO: DO WE REALLY NEED THE DOMAIN NAME WHEN WE HAVE THE FILTER ON THE DOMAIN NAME ALREADY?*/
    constructor(macAddress: String, domainName: String, txtRecordMap: Map<String, String>): this (
        //Calculate a id from the macAddress, since the macAddress is a 48-Bit field.
        IdGenerator.getId(macAddress),
        txtRecordMap[KEY_IDENTIFIER] ?: macAddress,
        domainName,
        when(txtRecordMap[KEY_CONNECTION]?.toUpperCase()) {
            ConnectionStatus.UP.name -> ConnectionStatus.UP
            ConnectionStatus.DOWN.name -> ConnectionStatus.DOWN
            ConnectionStatus.PROBLEM.name -> ConnectionStatus.PROBLEM
            else -> ConnectionStatus.UNKNOWN
        }
    )

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeLong(id)
        parcel.writeString(userIdentifier)
        parcel.writeString(domainName)
        parcel.writeInt(connectionStatus.ordinal)
    }

    override fun describeContents(): Int {
        return 0
    }

    companion object CREATOR : Parcelable.Creator<Device> {
        private const val KEY_IDENTIFIER = "identifier"
        private const val KEY_CONNECTION = "connection"

        override fun createFromParcel(parcel: Parcel): Device {
            return Device(parcel)
        }

        override fun newArray(size: Int): Array<Device?> {
            return arrayOfNulls(size)
        }
    }

}