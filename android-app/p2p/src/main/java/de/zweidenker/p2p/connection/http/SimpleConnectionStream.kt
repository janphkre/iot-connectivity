package de.zweidenker.p2p.connection.http

import okhttp3.internal.http1.Http1Codec
import okio.Okio
import okio.Sink
import okio.Source

class SimpleConnectionStream(
    sink: Sink,
    source: Source
) {

    private val bufferedSink = Okio.buffer(sink)
    private val bufferedSource = Okio.buffer(source)
    val codec = Http1Codec(null, null, bufferedSource, bufferedSink)

    init {

    }

    fun close() {
        TODO()
    }
}