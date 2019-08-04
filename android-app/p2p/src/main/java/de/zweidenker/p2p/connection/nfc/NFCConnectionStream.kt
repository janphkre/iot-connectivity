package de.zweidenker.p2p.connection.nfc

import android.bluetooth.BluetoothSocket
import de.zweidenker.p2p.connection.http.ConnectionStream
import de.zweidenker.p2p.connection.http.HttpWrapper
import de.zweidenker.p2p.connection.http.SimpleHttp1Codec
import okhttp3.internal.http.HttpCodec
import okio.Okio
import java.io.IOException

internal class NFCConnectionStream: ConnectionStream {

    override fun newCodec(httpWrapper: HttpWrapper): HttpCodec {
        val socket = try {
            connect()
        } catch (e: Exception) {
            throw IOException(e)
        }

        val nfcSource = Okio.buffer(Okio.source(socket.inputStream))
        val nfcSink = Okio.buffer(Okio.sink(socket.outputStream))
        return SimpleHttp1Codec(httpWrapper, nfcSource, nfcSink)
    }

    //TODO: ADD STORING INPUTSTREAM

    private fun connect(): BluetoothSocket {
        throw NotImplementedError("NFC can not be used for a bidirectional p2p connection. It only supports unidirectional traffic.")
        //The user would be required to remove his phone from the pi and mve it onto it again multiple times,
        // as each ndef tag is only discovered once, therefor it is only handeled once, no matter how long the phone stays near it.
    }
}