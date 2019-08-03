package de.zweidenker.p2p.connection.http

import de.zweidenker.p2p.connection.http.internal.SimpleHttp1Codec
import okhttp3.internal.http.HttpCodec
import okio.Okio
import okio.Sink
import okio.Source

class SimpleConnectionStream(
    source: Source,
    sink: Sink
) {

    private val bufferedSink = Okio.buffer(sink)
    private val bufferedSource = Okio.buffer(source)

    internal lateinit var wrapper: HttpWrapper

    fun newCodec(): HttpCodec {

        return SimpleHttp1Codec(wrapper, bufferedSource, bufferedSink)
    }
}