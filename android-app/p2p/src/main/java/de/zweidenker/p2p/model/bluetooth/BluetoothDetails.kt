package de.zweidenker.p2p.model.bluetooth

import android.os.Parcel
import android.os.Parcelable
import de.zweidenker.p2p.P2PModule
import java.util.UUID

data class BluetoothDetails(
    val mac: String,
    val uuid: UUID
) : Parcelable {

    constructor(parcel: Parcel) : this(
        parcel.readString() ?: "",
        parcel.readSerializable() as UUID
    )

    constructor(txtRecordMap: Map<String, String>): this(
        txtRecordMap[P2PModule.KEY_BLUETOOTH_MAC] ?: "",
        UUID.fromString("${P2PModule.TYPE_SERVICE}${txtRecordMap[P2PModule.KEY_BLUETOOTH_MAC]}")
    )

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeString(mac)
        parcel.writeSerializable(uuid)
    }

    override fun describeContents(): Int {
        return 0
    }

    companion object CREATOR : Parcelable.Creator<BluetoothDetails> {
        override fun createFromParcel(parcel: Parcel): BluetoothDetails {
            return BluetoothDetails(parcel)
        }

        override fun newArray(size: Int): Array<BluetoothDetails?> {
            return arrayOfNulls(size)
        }
    }

    fun contentEquals(other: Any?): Boolean {
        if (other !is BluetoothDetails) {
            return false
        }
        return mac == other.mac
    }
}