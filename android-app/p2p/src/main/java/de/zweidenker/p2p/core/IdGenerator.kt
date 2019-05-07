package de.zweidenker.p2p.core

import java.util.concurrent.atomic.AtomicLong

object IdGenerator {
    private const val MAC_ADDRESS_BYTES = 6
    private const val BITS_PER_BYTE = 8
    private const val HEXADECIMAL = 16
    private const val idBase: Long = 1L shl (MAC_ADDRESS_BYTES * BITS_PER_BYTE)
    private var idIndex = AtomicLong(0)

    fun getId(): Long {
        return idBase + idIndex.getAndIncrement()
    }

    fun getId(macAddress: String): Long {
        var result = 0L
        for (i in 0 until MAC_ADDRESS_BYTES) {
            val currentIndex = i * 3
            result = (result shl BITS_PER_BYTE) + (Character.digit(macAddress[currentIndex], HEXADECIMAL) shl 4) +
                    Character.digit(macAddress[currentIndex + 1], HEXADECIMAL)
        }
        return result
    }
}