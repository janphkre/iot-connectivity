package de.zweidenker.p2p.connection

import de.zweidenker.p2p.P2PModule
import rx.Observable
import rx.Subscription
import rx.schedulers.Schedulers
import rx.subjects.Subject
import timber.log.Timber
import java.net.ServerSocket


class IpReceiverServer {

    private var subscription: Subscription? = null

    fun receive(resultObservable: Subject<String, String>) {
        subscription = Observable.unsafeCreate<Unit> {
            awaitOnSocket(resultObservable)
            resultObservable.onCompleted()
            it.onCompleted()
        }.subscribeOn(Schedulers.io()).subscribe()
    }

    fun unsubscribe() {
        subscription?.unsubscribe()
        subscription = null
    }

    private fun awaitOnSocket(resultObservable: Subject<String, String>) {
        Timber.e("Awaiting Ping on ${P2PModule.PING_PORT}")
        try {
            val targetAddress = ServerSocket(P2PModule.PING_PORT).use { serverSocket ->
                serverSocket.soTimeout = P2PModule.SOCKET_TIMEOUT_MS
                serverSocket.accept().use { clientSocket ->
                    clientSocket.inetAddress.toString()
                }
            }
            resultObservable.onNext(targetAddress)
        } catch(e: Exception) {
            resultObservable.onError(e)
        }
    }
}