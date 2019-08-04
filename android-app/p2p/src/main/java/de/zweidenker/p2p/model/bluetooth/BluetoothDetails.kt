package de.zweidenker.p2p.model.bluetooth

import android.os.Parcel
import android.os.Parcelable
import de.zweidenker.p2p.P2PModule
import java.util.UUID

data class BluetoothDetails(
    val mac: String,
    val port: Int
) : Parcelable {

    constructor(parcel: Parcel) : this(
        parcel.readString() ?: "",
        parcel.readInt()
    )

    constructor(txtRecordMap: Map<String, String>): this(
        txtRecordMap[P2PModule.KEY_BLUETOOTH_MAC] ?: throw IllegalArgumentException("Missing Bluetooth mac address!"),
        txtRecordMap[P2PModule.KEY_BLUETOOTH_PORT]?.toIntOrNull() ?: throw IllegalArgumentException("Missing Bluetooth port!")
    )

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeString(mac)
        parcel.writeInt(port)
    }

    override fun describeContents(): Int {
        return 0
    }

    fun contentEquals(other: Any?): Boolean {
        if (other !is BluetoothDetails) {
            return false
        }
        return mac == other.mac && port == other.port
    }

    companion object CREATOR : Parcelable.Creator<BluetoothDetails> {

        override fun createFromParcel(parcel: Parcel): BluetoothDetails {
            return BluetoothDetails(parcel)
        }

        override fun newArray(size: Int): Array<BluetoothDetails?> {
            return arrayOfNulls(size)
        }

        fun generateUuid(mac: String, service: String): UUID {
            var mostSigBits = 0L
            var leastSigBits = 0L

            // Use mac address for first part of uuid:
            val macBytes = mac.split(':')
            assert(macBytes.size == 6)
            macBytes.reversed().forEach {
                mostSigBits = mostSigBits.shl(8) + it.toLong(16)
            }

            // Use service type identifeir for second part of uuid:
            // 2. Adjust certain bits according to RFC 4122 section 4.4.
            // This just means do the following
            // (a) set the high nibble of the 7th byte equal to 4 and
            // (b) set the two most significant bits of the 9th byte to 10'B,
            //     so the high nibble will be one of {8,9,A,B}.
            val serviceBytes = service.substring(0, 11).map { it.toByte() } // Cast to byte to force 16 bit unicode into 8 bits.
            mostSigBits = mostSigBits.shl(8) + (0x40 or (serviceBytes[0].toInt() and 0xf))
            mostSigBits = mostSigBits.shl(8) + serviceBytes[1]
            leastSigBits = leastSigBits.shl(8) + (0x80 or (serviceBytes[2].toInt() and 0x3f))
            for (i in 3 until 10) {
                leastSigBits = leastSigBits.shl(8) + serviceBytes[i]
            }

            return UUID(mostSigBits, leastSigBits)
        }
    }
}