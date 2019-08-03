package de.zweidenker.p2p.connection.http.internal

import okhttp3.Call
import okhttp3.Callback
import okhttp3.Response
import java.io.IOException
import java.util.concurrent.Semaphore

class SyncResponseCallback : Callback {

    private val semaphore = Semaphore(0)
    private var exception: Exception? = null
    private var response: Response? = null

    override fun onFailure(call: Call, e: IOException) {
        this.exception = e
        complete()
    }

    override fun onResponse(call: Call, response: Response) {
        this.response = response
        complete()
    }

    private fun isSuccess(): Boolean {
        return exception == null && response != null
    }

    private fun complete() {
        semaphore.release()
    }

    fun awaitComplete(): Response {
        semaphore.acquire()
        if (isSuccess()) {
            return response!!
        } else {
            throw exception ?: IllegalStateException("Call completed but no response or exception received")
        }
    }
}