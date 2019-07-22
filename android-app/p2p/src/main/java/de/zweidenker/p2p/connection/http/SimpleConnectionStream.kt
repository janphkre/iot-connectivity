package de.zweidenker.p2p.connection.http

import okhttp3.internal.http.HttpCodec
import okhttp3.internal.http1.Http1Codec
import okio.Okio
import okio.Sink
import okio.Source

class SimpleConnectionStream(
    source: Source,
    sink: Sink
) {

    private val bufferedSink = Okio.buffer(sink)
    private val bufferedSource = Okio.buffer(source)

    fun newCodec(): HttpCodec {
        return Http1Codec(null, null, bufferedSource, bufferedSink)
    }
}