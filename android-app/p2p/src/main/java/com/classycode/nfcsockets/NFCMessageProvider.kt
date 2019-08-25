package com.classycode.nfcsockets

import android.util.Log
import android.util.SparseArray
import com.classycode.nfcsockets.messages.KeepAliveMessage
import com.classycode.nfcsockets.messages.SocketRequest
import com.classycode.nfcsockets.util.SocketResponseSubscriber
import java.lang.ref.WeakReference
import java.util.concurrent.ConcurrentLinkedQueue

class NFCMessageProvider {
    private var pending = SparseArray<WeakReference<SocketResponseSubscriber>>()
    private var outboundQueue = ConcurrentLinkedQueue<SocketRequest>()

    fun socketRequest(socketRequest: SocketRequest, socketSubscriber: SocketResponseSubscriber) {
        pending.put(socketRequest.requestId, WeakReference(socketSubscriber))
        outboundQueue.add(socketRequest)
        Log.d(Constants.LOG_TAG, "Queued outbound message: $socketRequest")
    }

    fun clear() {
        pending.clear()
    }

    fun getSubscriber(requestId: Int): SocketResponseSubscriber? {
        val subscriber = pending.get(requestId) ?: return null
        return subscriber.get().also {
            if (it == null) {
                pending.remove(requestId)
            }
        }
    }

    fun nextMessage(): ByteArray {
        return (outboundQueue.poll() ?: KeepAliveMessage()).toApdu()
    }
}