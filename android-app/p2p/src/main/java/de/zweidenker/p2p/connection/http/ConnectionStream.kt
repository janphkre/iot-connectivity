package de.zweidenker.p2p.connection.http

import okhttp3.internal.http.HttpCodec

interface ConnectionStream {
    fun newCodec(httpWrapper: HttpWrapper): HttpCodec
}