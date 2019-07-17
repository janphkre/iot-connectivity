package de.zweidenker.p2p.connection.http.internal

import de.zweidenker.p2p.connection.http.HttpWrapper
import okhttp3.Call
import okhttp3.Callback
import okhttp3.Request
import okhttp3.Response

class SimpleCall(
    private val wrapper: HttpWrapper,
    private val request: Request
) : Call {

    private var executed: Boolean = false
    private var canceled: Boolean = false

    override fun enqueue(responseCallback: Callback) {
        wrapper.dispatcher().enqueue(this, responseCallback)
    }

    override fun isExecuted(): Boolean {
        return executed
    }

    override fun clone(): Call {
        return SimpleCall(wrapper, request)
    }

    override fun isCanceled(): Boolean {
        return canceled
    }

    override fun cancel() {
        canceled = true
        wrapper.dispatcher().cancel(this)
    }

    override fun request(): Request {
        return request
    }

    override fun execute(): Response {
        return wrapper.dispatcher().execute(this)
    }
}
