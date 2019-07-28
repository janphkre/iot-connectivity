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
        txtRecordMap.getValue(P2PModule.KEY_BLUETOOTH_MAC),
        generateUuid(txtRecordMap.getValue(P2PModule.KEY_BLUETOOTH_MAC), P2PModule.TYPE_SERVICE)
    )

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeString(mac)
        parcel.writeSerializable(uuid)
    }

    override fun describeContents(): Int {
        return 0
    }

    fun contentEquals(other: Any?): Boolean {
        if (other !is BluetoothDetails) {
            return false
        }
        return mac == other.mac
    }

    companion object CREATOR : Parcelable.Creator<BluetoothDetails> {

        override fun createFromParcel(parcel: Parcel): BluetoothDetails {
            return BluetoothDetails(parcel)
        }

        override fun newArray(size: Int): Array<BluetoothDetails?> {
            return arrayOfNulls(size)
        }

        private fun generateUuid(mac: String, service: String): UUID {
            val macBytes = mac.split(':')
            assert(macBytes.size == 6)
            var mostSigBits = 0L
            var leastSigBits = 0L
            macBytes.forEach {
                mostSigBits = mostSigBits.shl(8) + it.toLong(16)
            }
            for(i in 0 until 8) {
                leastSigBits = leastSigBits.shl(8) + service[i].toByte() //Cast to byte to force 16 bit unicode into 8 bits.
            }
            return UUID(mostSigBits, leastSigBits)
        }
    }
}