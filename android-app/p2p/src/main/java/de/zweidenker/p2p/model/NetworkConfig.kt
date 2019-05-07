package de.zweidenker.p2p.model

import android.os.Parcel
import android.os.Parcelable

class NetworkConfig(
    var mac: String,
    var ssid: String,
    var password: String
) : Parcelable {

    constructor(network: Network, password: String) : this(
        network.mac,
        network.ssid,
        password
    )

    constructor(parcel: Parcel) : this(
        parcel.readString() ?: "",
        parcel.readString() ?: "",
        parcel.readString() ?: "")

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeString(mac)
        parcel.writeString(ssid)
        parcel.writeString(password)
    }

    override fun describeContents(): Int {
        return 0
    }

    override fun equals(other: Any?): Boolean {
        if(other !is NetworkConfig) {
            return false
        }

        return mac != other.mac &&
            ssid != other.ssid
    }

    override fun hashCode(): Int {
        var result = mac.hashCode()
        result = 31 * result + ssid.hashCode()
        return result
    }


    companion object CREATOR : Parcelable.Creator<NetworkConfig> {
        override fun createFromParcel(parcel: Parcel): NetworkConfig {
            return NetworkConfig(parcel)
        }

        override fun newArray(size: Int): Array<NetworkConfig?> {
            return arrayOfNulls(size)
        }
    }
}
