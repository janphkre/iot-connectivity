package com.classycode.nfcsockets.util

import com.classycode.nfcsockets.messages.SocketResponse
import java.io.IOException
import java.util.concurrent.Semaphore

abstract class SocketResponseSubscriber {

    private val semaphore = Semaphore(0)

    fun respondWith(response: SocketResponse) {
        onResponse(response)
        semaphore.release()
    }

    fun awaitCompletion(expectedCount: Int = 1) {
        try {
            semaphore.acquire(expectedCount)
        } catch (e: InterruptedException) {
            throw IOException("Interrupted while waiting for NFC socket", e)
        }
    }

    abstract fun onResponse(response: SocketResponse)
}