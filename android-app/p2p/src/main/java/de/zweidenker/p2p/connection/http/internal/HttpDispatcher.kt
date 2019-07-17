package de.zweidenker.p2p.connection.http.internal

import okhttp3.Call
import okhttp3.Callback
import okhttp3.Response

/**
 * Policy on when async requests are executed.
 *
 * <p>Each dispatcher uses an {@link ExecutorService} to run calls internally.
 * This dispatcher can only handle one request at a time.
 */
interface HttpDispatcher {
    fun enqueue(call: Call, responseCallback: Callback)
    fun execute(call: Call): Response
    fun cancel(call: Call)
}