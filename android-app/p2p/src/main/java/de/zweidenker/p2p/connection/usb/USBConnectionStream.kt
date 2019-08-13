package de.zweidenker.p2p.connection.usb

import android.os.ParcelFileDescriptor
import de.zweidenker.p2p.connection.http.ConnectionStream
import de.zweidenker.p2p.connection.http.HttpWrapper
import de.zweidenker.p2p.connection.http.SimpleHttp1Codec
import okhttp3.internal.http.HttpCodec
import okio.Okio
import java.io.FileInputStream
import java.io.FileOutputStream

internal class USBConnectionStream(
    private val fileDescriptor: ParcelFileDescriptor
) : ConnectionStream {

    override fun newCodec(httpWrapper: HttpWrapper): HttpCodec {
        val usbFile = fileDescriptor.fileDescriptor
        val usbInputSream = DetachableInputStream(FileInputStream(usbFile))
        val usbOutputSream = DetachableOutputStream(FileOutputStream(usbFile))

        val usbSource = Okio.buffer(Okio.source(usbInputSream))
        val usbSink = Okio.buffer(Okio.sink(usbOutputSream))
        return SimpleHttp1Codec(httpWrapper, usbSource, usbSink)
    }
}