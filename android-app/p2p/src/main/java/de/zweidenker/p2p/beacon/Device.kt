package de.zweidenker.p2p.beacon

import de.zweidenker.p2p.core.IdGenerator

data class Device(val macAddress: String, val domainName: String, val type: String) {

    //Calculate a id from the macAddress, since the macAddress is a 48-Bit field.
    val id: Long by lazy { IdGenerator.getId(macAddress) }
}