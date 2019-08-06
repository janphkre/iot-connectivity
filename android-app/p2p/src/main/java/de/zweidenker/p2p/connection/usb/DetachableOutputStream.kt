package de.zweidenker.p2p.connection.usb

import android.util.Log
import java.io.IOException
import java.io.OutputStream

class DetachableOutputStream(
    private var attachedOutputStream: OutputStream?
): OutputStream() {

    override fun close() {
        attachedOutputStream = null
        Log.e("TESTOUTPUT","Closing OutputStream!")
        super.close()
    }

    override fun write(b: Int) {
        Log.e("TESTOUTPUT","$b")
        attachedOutputStream?.write(b) ?: throw IOException("closed")
    }
}