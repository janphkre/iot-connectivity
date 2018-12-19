package de.zweidenker.p2p.core

import android.os.Parcel
import android.os.Parcelable

class Device(
    val id: Long,
    val userIdentifier: String,
    val domainName: String,
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
        parcel.readInt()) {
    }

    /*TODO: DO WE REALLY NEED THE DOMAIN NAME WHEN WE HAVE THE FILTER ON THE DOMAIN NAME ALREADY?*/
    constructor(macAddress: String, domainName: String, txtRecordMap: Map<String, String>): this (
        //Calculate a id from the macAddress, since the macAddress is a 48-Bit field.
        IdGenerator.getId(macAddress),
        txtRecordMap[P2PConstants.KEY_IDENTIFIER] ?: macAddress,
        domainName,
        when(txtRecordMap[P2PConstants.KEY_CONNECTION]?.toUpperCase()) {
            ConnectionStatus.UP.name -> ConnectionStatus.UP
            ConnectionStatus.DOWN.name -> ConnectionStatus.DOWN
            ConnectionStatus.PROBLEM.name -> ConnectionStatus.PROBLEM
            else -> ConnectionStatus.UNKNOWN
        },
        txtRecordMap[P2PConstants.KEY_PORT]?.toIntOrNull() ?: throw IllegalArgumentException("Missing Port!")
    )

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeLong(id)
        parcel.writeString(userIdentifier)
        parcel.writeString(domainName)
        parcel.writeInt(connectionStatus.ordinal)
        parcel.writeInt(port)
    }

    override fun describeContents(): Int {
        return 0
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