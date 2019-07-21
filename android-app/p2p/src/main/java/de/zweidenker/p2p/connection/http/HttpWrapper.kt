package de.zweidenker.p2p.connection.http

import de.zweidenker.p2p.connection.http.internal.HttpDispatcher
import okhttp3.Call
import okhttp3.CookieJar
import okhttp3.Interceptor
import okhttp3.internal.cache.InternalCache
import okhttp3.internal.http.HttpCodec

interface HttpWrapper: Call.Factory {
    fun interceptors(): Collection<Interceptor>
    fun networkInterceptors(): Collection<Interceptor>

    fun cookieJar(): CookieJar
    fun internalCache(): InternalCache?
    fun httpCodec(): HttpCodec

    fun readTimeoutMillis(): Int
    fun writeTimeoutMillis(): Int
    fun connectTimeoutMillis(): Int
    fun dispatcher(): HttpDispatcher
}