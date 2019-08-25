package com.classycode.nfcsockets.sockets

import android.util.Log

import com.classycode.nfcsockets.Constants

import java.io.IOException
import java.io.OutputStream

/**
 * @author Alex Suzuki, Classy Code GmbH, 2017
 */
internal class NFCSocketOutputStream(private val nfcSocket: NFCSocket) : OutputStream() {
    private var isClosed: Boolean = false

    init {
        isClosed = false
    }

    @Throws(IOException::class)
    override fun write(b: Int) {
        ensureNotClosed()
        val wrappedByte = byteArrayOf(b.toByte())
        nfcSocket.writeInternal(wrappedByte, 0, wrappedByte.size)
    }

    @Throws(IOException::class)
    override fun write(b: ByteArray) {
        ensureNotClosed()
        nfcSocket.writeInternal(b, 0, b.size)
    }

    @Throws(IOException::class)
    override fun write(b: ByteArray, off: Int, len: Int) {
        ensureNotClosed()
        nfcSocket.writeInternal(b, off, len)
    }

    @Throws(IOException::class)
    override fun flush() {
        ensureNotClosed()
        Log.d(TAG, "NFCSocketOutputStream.flush() is a no-op")
    }

    @Throws(IOException::class)
    override fun close() {
        if (!isClosed) {
            isClosed = true

            // according to Socket.getOutputStream documentation, closing the OutputStream
            // should close the socket
            nfcSocket.close()
        } else {
            Log.w(TAG, "Stream already closed")
        }
    }

    private fun ensureNotClosed() {
        if (isClosed) {
            throw IllegalStateException("OutputStream is closed")
        }
    }

    companion object {

        private val TAG = Constants.LOG_TAG
    }
}