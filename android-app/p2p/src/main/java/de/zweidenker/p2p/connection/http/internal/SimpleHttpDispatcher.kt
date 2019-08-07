package de.zweidenker.p2p.connection.http.internal

import de.zweidenker.p2p.connection.http.HttpWrapper
import okhttp3.Call
import okhttp3.Callback
import okhttp3.Interceptor
import okhttp3.Response
import okhttp3.internal.Util
import okhttp3.internal.cache.CacheInterceptor
import okhttp3.internal.http.BridgeInterceptor
import okhttp3.internal.http.RealInterceptorChain
import java.io.IOException
import java.util.ArrayDeque
import java.util.ArrayList
import java.util.concurrent.SynchronousQueue
import java.util.concurrent.ThreadPoolExecutor
import java.util.concurrent.TimeUnit

class SimpleHttpDispatcher(
    private val wrapper: HttpWrapper
) : HttpDispatcher, Runnable {

    /** Executes calls. Created lazily.  */
    private val executorService by lazy {
        ThreadPoolExecutor(0, Integer.MAX_VALUE, 60, TimeUnit.SECONDS,
            SynchronousQueue(), Util.threadFactory("OkHttp Dispatcher", false))
    }

    /** Ready async calls in the order they'll be run.  */
    private val readyAsyncCalls = ArrayDeque<Pair<Call, Callback>>()

    /** Running asynchronous calls. Includes canceled calls that haven't finished yet.  */
//    private var runningCall: Pair<Call, Callback>? = null

    override fun enqueue(call: Call, responseCallback: Callback) {
        val callPair = Pair(call, responseCallback)
        synchronized(this) {
            readyAsyncCalls.addLast(callPair)
            if (readyAsyncCalls.size == 1) {
                executorService.execute(this)
            }
        }
    }

    override fun execute(call: Call): Response {
        val callback = SyncResponseCallback()
        val callPair = Pair(call, callback)
        synchronized(this) {
            readyAsyncCalls.addFirst(callPair)
            if (readyAsyncCalls.size == 1) {
                executorService.execute(this)
            }
        }
        return callback.awaitComplete()
    }

    override fun cancel(call: Call) {
        synchronized(this) {
            readyAsyncCalls.removeAll { it.first === call }
        }
    }

    override fun run() {
        val oldName = Thread.currentThread().name
        try {
            unsafeRun()
        } finally {
            Thread.currentThread().name = oldName
        }
    }

    private fun unsafeRun() {
        while (true) {
            val callPair = synchronized(this) {
                if (readyAsyncCalls.isNotEmpty())
                    readyAsyncCalls.removeFirst()
                else return@unsafeRun
            }
            Thread.currentThread().name = "IoT Http ${callPair.first.request().url().redact()}"
            try {
                val response = unsafeExecute(callPair.first)
                callPair.second.onResponse(callPair.first, response)
            } catch (e: IOException) {
                callPair.second.onFailure(callPair.first, e)
            }
        }
    }

    private fun unsafeExecute(call: Call): Response {
        call.ensureCanceled()
        // Build a full stack of interceptors.
        val interceptors = ArrayList<Interceptor>()
        interceptors.addAll(wrapper.interceptors())
        interceptors.add(BridgeInterceptor(wrapper.cookieJar()))
        interceptors.add(CacheInterceptor(wrapper.internalCache()))
        interceptors.addAll(wrapper.networkInterceptors())
        interceptors.add(SimpleServerInterceptor(wrapper.httpCodec()))

        val chain = RealInterceptorChain(interceptors, null, null, null, 0,
            call.request(), call, null, wrapper.connectTimeoutMillis(),
            wrapper.readTimeoutMillis(), wrapper.writeTimeoutMillis())
        return chain.proceed(call.request()).also {
            call.ensureCanceled()
        }
    }

    private fun Call.ensureCanceled() {
        if (isCanceled) {
            throw IOException("canceled")
        }
    }
}