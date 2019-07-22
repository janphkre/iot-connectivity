package de.zweidenker.p2p.model.wifi

import android.net.wifi.WpsInfo
import android.net.wifi.p2p.WifiP2pConfig
import android.net.wifi.p2p.WifiP2pDevice
import android.os.Parcel
import android.os.Parcelable
import de.zweidenker.p2p.P2PModule

data class WifiDetails(
    val address: String,
    val port: Int,
    val ip: String
) : Parcelable {

    constructor(parcel: Parcel) : this(
        parcel.readString() ?: "",
        parcel.readInt(),
        parcel.readString() ?: "") {
    }

    constructor(p2pDevice: WifiP2pDevice, txtRecordMap: Map<String, String>) : this(
        p2pDevice.deviceAddress,
        txtRecordMap[P2PModule.KEY_PORT]?.toIntOrNull() ?: throw IllegalArgumentException("Missing Port!"),
        txtRecordMap[P2PModule.KEY_IP] ?: ""
    )

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeString(address)
        parcel.writeInt(port)
        parcel.writeString(ip)
    }

    override fun describeContents(): Int {
        return 0
    }

    companion object CREATOR : Parcelable.Creator<WifiDetails> {
        override fun createFromParcel(parcel: Parcel): WifiDetails {
            return WifiDetails(parcel)
        }

        override fun newArray(size: Int): Array<WifiDetails?> {
            return arrayOfNulls(size)
        }
    }

    fun asConfig(): WifiP2pConfig {
        return WifiP2pConfig().apply {
            this.deviceAddress = this@WifiDetails.address
            this.groupOwnerIntent = 10
            this.wps.setup = WpsInfo.PBC
        }
    }

    fun contentEquals(other: Any?): Boolean {
        if (other !is WifiDetails) {
            return false
        }
        return port == other.port &&
            ip == other.ip
    }
}