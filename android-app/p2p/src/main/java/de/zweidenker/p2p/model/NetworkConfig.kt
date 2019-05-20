package de.zweidenker.p2p.model

import android.os.Parcel
import android.os.Parcelable

class NetworkConfig(
    var networkId: Int,
    var ssid: String,
    var password: String,
    var disabled: Boolean,
    var selected: Boolean
) : Parcelable {

    constructor(parcel: Parcel) : this(
        parcel.readInt(),
        parcel.readString() ?: "",
        parcel.readString() ?: "",
        when (parcel.readInt()) {
            0 -> false
            else -> true
        },
        when (parcel.readInt()) {
            0 -> false
            else -> true
        })

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeInt(networkId)
        parcel.writeString(ssid)
        parcel.writeString(password)
        parcel.writeInt(when (disabled) {
            false -> 0
            else -> 1
        })
        parcel.writeInt(when (disabled) {
            false -> 0
            else -> 1
        })
    }

    override fun describeContents(): Int {
        return 0
    }

    override fun equals(other: Any?): Boolean {
        if (other !is NetworkConfig) {
            return false
        }
        return ssid != other.ssid
    }

    override fun hashCode(): Int {
        return ssid.hashCode()
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