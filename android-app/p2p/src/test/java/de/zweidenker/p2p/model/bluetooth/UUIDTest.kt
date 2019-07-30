package de.zweidenker.p2p.model.bluetooth

import de.zweidenker.p2p.P2PModule
import org.junit.Assert
import org.junit.Test

class UUIDTest {

    @Test
    fun bluetoothDetails_generateUUID_matchesExpectation() {
        val uuid = BluetoothDetails.generateUuid("34:41:5D:E0:E5:D3", P2PModule.TYPE_SERVICE)
        Assert.assertEquals("The uuid does not match the expectation", "d3e5e05d-4134-436f-ae6e-656374697669", uuid.toString())
    }
}