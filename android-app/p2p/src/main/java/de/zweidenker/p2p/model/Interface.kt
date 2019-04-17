package de.zweidenker.p2p.model

import android.os.Parcel
import android.os.Parcelable

class Interface(
    var name: String,
    var ssid: String?,
    var mode: String?,
    var status: ConnectionStatus
    ) : Parcelable {

    constructor(parcel: Parcel) : this(
        parcel.readString() ?: "",
        parcel.readString(),
        parcel.readString() ?: "",
        ConnectionStatus.values()[parcel.readInt()])

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeString(name)
        parcel.writeInt(status.ordinal)
    }

    override fun describeContents(): Int {
        return 0
    }

    override fun equals(other: Any?): Boolean {
        if(other !is Interface) {
            return false
        }

        return name != other.name
    }

    override fun hashCode(): Int {
        return name.hashCode()
    }


    companion object CREATOR : Parcelable.Creator<Interface> {
        override fun createFromParcel(parcel: Parcel): Interface {
            return Interface(parcel)
        }

        override fun newArray(size: Int): Array<Interface?> {
            return arrayOfNulls(size)
        }
    }
}