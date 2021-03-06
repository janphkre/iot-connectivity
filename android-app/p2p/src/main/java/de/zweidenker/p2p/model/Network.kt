package de.zweidenker.p2p.model

import android.os.Parcel
import android.os.Parcelable

class Network(
    var mac: String,
    var ssid: String,
    var signalStrength: Int,
    var security: List<String>
) : Parcelable {
    constructor(parcel: Parcel) : this(
        parcel.readString() ?: "",
        parcel.readString() ?: "",
        parcel.readInt(),
        mutableListOf<String>().apply {
            parcel.readStringList(this)
        })

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeString(mac)
        parcel.writeString(ssid)
        parcel.writeInt(signalStrength)
        parcel.writeStringList(security)
    }

    override fun describeContents(): Int {
        return 0
    }

    override fun equals(other: Any?): Boolean {
        if (other !is Network) {
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

    companion object CREATOR : Parcelable.Creator<Network> {
        override fun createFromParcel(parcel: Parcel): Network {
            return Network(parcel)
        }

        override fun newArray(size: Int): Array<Network?> {
            return arrayOfNulls(size)
        }
    }
}