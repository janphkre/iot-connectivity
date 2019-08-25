package com.classycode.nfcsockets

import android.content.Context
import android.content.Intent
import android.nfc.cardemulation.HostApduService
import android.os.Build
import android.os.Bundle
import android.os.Vibrator
import android.support.annotation.RequiresApi
import android.support.v4.content.LocalBroadcastManager
import android.util.Log
import com.classycode.nfcsockets.messages.KeepAliveMessage
import com.classycode.nfcsockets.messages.LinkTerminateMessage
import com.classycode.nfcsockets.messages.Message
import com.classycode.nfcsockets.messages.SocketResponse
import org.koin.android.ext.android.inject
import java.io.IOException
import java.util.Arrays

/**
 * @author Alex Suzuki, Classy Code GmbH, 2017
 */
@RequiresApi(Build.VERSION_CODES.KITKAT)
class NFCSocketApduService : HostApduService() {

    private val provider by inject<NFCMessageProvider>()

    private var isProcessing: Boolean = false

    override fun onCreate() {
        super.onCreate()

        isProcessing = false
    }

    override fun processCommandApdu(commandApdu: ByteArray, extras: Bundle): ByteArray {
        if (!isProcessing) { // new connection
            Log.i(TAG, "Link activated")
            isProcessing = true
        }

        if (Arrays.equals(SELECT_AID_COMMAND, commandApdu)) { // NFC Terminal selected us
            notifyLinkEstablished()
            return SELECT_RESPONSE_OK
        } else {
            val message: Message
            try {
                message = Message.parseMessage(commandApdu)
            } catch (e: IOException) {
                Log.e(TAG, "Failed to parse inbound message", e)
                return LinkTerminateMessage().toApdu()
            }

            return when (message) {
                is KeepAliveMessage -> provider.nextMessage()
                is LinkTerminateMessage -> LinkTerminateMessage().toApdu()
                is SocketResponse -> {
                    Log.d(TAG, "Received socket response: $message")
                    provider.getSubscriber(message.inReplyTo)?.respondWith(message)
                    provider.nextMessage()
                }
                else -> throw IllegalStateException("Unknown message received")
            }
        }
    }

    override fun onDeactivated(reason: Int) {
        Log.i(TAG, "Link deactivated: $reason")

        provider.clear()//TODO: MAYBE THIS HAS TO BE REMOVED

        isProcessing = false
        notifyLinkDeactivated(reason)
    }

    private fun notifyLinkEstablished() {
        val v = applicationContext.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        v.vibrate(200)//TOD: REQUIRES PERMISSION!!!

        LocalBroadcastManager.getInstance(applicationContext).sendBroadcast(Intent(BROADCAST_INTENT_LINK_ESTABLISHED))
    }

    private fun notifyLinkDeactivated(reason: Int) {
        val intent = Intent(BROADCAST_INTENT_LINK_DEACTIVATED)
        intent.putExtra("reason", reason)
        LocalBroadcastManager.getInstance(applicationContext).sendBroadcast(intent)
    }

    companion object {

        const val MAX_APDU_PAYLOAD_SIZE = 255

        const val BROADCAST_INTENT_LINK_ESTABLISHED = "LINK_ESTABLISHED"
        const val BROADCAST_INTENT_LINK_DEACTIVATED = "LINK_DEACTIVATED"

        private const val TAG = Constants.LOG_TAG

        // the SELECT AID APDU issued by the terminal
        // our AID is 0xF0ABCDFF0000
        private val SELECT_AID_COMMAND = byteArrayOf(0x00.toByte(), // Class
            0xA4.toByte(), // Instruction
            0x04.toByte(), // Parameter 1
            0x00.toByte(), // Parameter 2
            0x06.toByte(), // length
            0xF0.toByte(), 0xAB.toByte(), 0xCD.toByte(), 0xFF.toByte(), 0x00.toByte(), 0x00.toByte())

        // OK status sent in response to SELECT AID command (0x9000)
        private val SELECT_RESPONSE_OK = byteArrayOf(0x90.toByte(), 0x00.toByte())
    }

}
