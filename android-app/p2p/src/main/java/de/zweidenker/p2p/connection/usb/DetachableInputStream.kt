package de.zweidenker.p2p.connection.usb

import android.util.Log
import java.io.IOException
import java.io.InputStream

class DetachableInputStream(
    private var attachedInputStream: InputStream?
) : InputStream() {

    override fun close() {
        Log.e("TESTINPUT", "Closing InputStream!")
        attachedInputStream = null
        super.close()
    }

    override fun read(): Int {
        return attachedInputStream?.read()?.also { Log.e("TESTINPUT", "$it") } ?: throw IOException("closed")
    }
}