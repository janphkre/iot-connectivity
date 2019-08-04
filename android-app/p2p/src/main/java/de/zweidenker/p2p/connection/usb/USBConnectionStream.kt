package de.zweidenker.p2p.connection.usb

import de.zweidenker.p2p.connection.http.ConnectionStream
import de.zweidenker.p2p.connection.http.HttpWrapper
import de.zweidenker.p2p.connection.http.SimpleHttp1Codec
import okhttp3.internal.http.HttpCodec
import okio.Okio
import java.io.IOException
import java.net.Socket

internal class USBConnectionStream: ConnectionStream {

    override fun newCodec(httpWrapper: HttpWrapper): HttpCodec {
        val socket = try {
            connect()
        } catch (e: Exception) {
            throw IOException(e)
        }

        val usbSource = Okio.buffer(Okio.source(socket.inputStream))
        val usbSink = Okio.buffer(Okio.sink(socket.outputStream))
        return SimpleHttp1Codec(httpWrapper, usbSource, usbSink)
    }

    private fun connect(): Socket {
        TODO()
    }
}