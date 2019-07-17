package de.zweidenker.p2p.connection.http

import de.zweidenker.p2p.connection.http.internal.HttpDispatcher
import de.zweidenker.p2p.connection.http.internal.SimpleCall
import de.zweidenker.p2p.connection.http.internal.SimpleHttpDispatcher
import okhttp3.Call
import okhttp3.CookieJar
import okhttp3.Interceptor
import okhttp3.Request
import okhttp3.internal.Util
import okhttp3.internal.cache.InternalCache
import java.util.LinkedList
import java.util.concurrent.TimeUnit

class SimpleHttpWrapper(
    private val interceptors: LinkedList<Interceptor>,
    private val networkInterceptors: LinkedList<Interceptor>,
    private val internalCache: InternalCache?,
    private val connectTimeout: Int,
    private val writeTimeout: Int,
    private val readTimeout: Int,
    private val httpStream: Interceptor
): HttpWrapper {

    private val cookieJar = CookieJar.NO_COOKIES
    private val httpDispatcher = SimpleHttpDispatcher(this)

    override fun interceptors(): Collection<Interceptor> = interceptors

    override fun networkInterceptors(): Collection<Interceptor> = networkInterceptors

    override fun cookieJar(): CookieJar = cookieJar

    override fun internalCache(): InternalCache? = internalCache

    override fun readTimeoutMillis(): Int = readTimeout

    override fun writeTimeoutMillis(): Int = writeTimeout

    override fun connectTimeoutMillis(): Int = connectTimeout

    override fun dispatcher(): HttpDispatcher = httpDispatcher

    override fun httpStream(): Interceptor = httpStream

    override fun newCall(request: Request): Call {
        return SimpleCall(this, request)
    }

    class Builder {
        private var interceptors = LinkedList<Interceptor>()
        private var networkInterceptors = LinkedList<Interceptor>()
        private var internalCache: InternalCache? = null
        private var connectTimeout: Int = 10000
        private var writeTimeout: Int = 10000
        private var readTimeout: Int = 10000
        private var httpStream: Interceptor? = null

        fun readTimeout(timeout: Long, unit: TimeUnit): Builder {
            readTimeout = Util.checkDuration("timeout", timeout, unit)
            return this
        }

        fun writeTimeout(timeout: Long, unit: TimeUnit): Builder {
            writeTimeout = Util.checkDuration("timeout", timeout, unit)
            return this
        }

        fun connectTimeout(timeout: Long, unit: TimeUnit): Builder {
            connectTimeout = Util.checkDuration("timeout", timeout, unit)
            return this
        }

        fun addInterceptor(interceptor: Interceptor): Builder {
            interceptors.add(interceptor)
            return this
        }

        fun addNetworkInterceptor(interceptor: Interceptor): Builder {
            networkInterceptors.add(interceptor)
            return this
        }

        /** Sets the response cache to be used to read and write cached responses.  */
        fun setInternalCache(internalCache: InternalCache?) {
            this.internalCache = internalCache
        }

        fun setHttpStream(httpStream: Interceptor) {
            this.httpStream = httpStream
        }

        fun build(): HttpWrapper {
            return SimpleHttpWrapper(
                interceptors,
                networkInterceptors,
                internalCache,
                connectTimeout,
                writeTimeout,
                readTimeout,
                httpStream ?: throw IllegalArgumentException("You must set a output http stream")
            )
        }

    }
}