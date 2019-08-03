package de.zweidenker.p2p.connection.http.internal

import okhttp3.Interceptor
import okhttp3.Response
import okhttp3.internal.http.HttpCodec
import okhttp3.internal.http.HttpMethod
import okhttp3.internal.http.RealInterceptorChain
import okio.Okio
import java.net.ProtocolException

class SimpleServerInterceptor(
    private val httpCodec: HttpCodec
) : Interceptor {

    override fun intercept(chain: Interceptor.Chain): Response {
        val realInterceptorChain = chain as RealInterceptorChain
        val request = realInterceptorChain.request()
        val sentRequestMillis = System.currentTimeMillis()
        httpCodec.writeRequestHeaders(request)

        var responseBuilder: Response.Builder? = null
        if (HttpMethod.permitsRequestBody(request.method()) && request.body() != null) {
            // If there's a "Expect: 100-continue" header on the request, wait for a "HTTP/1.1 100
            // Continue" response before transmitting the request body. If we don't get that, return what
            // we did get (such as a 4xx response) without ever transmitting the request body.
            if ("100-continue".equals(request.header("Expect"), ignoreCase = true)) {
                httpCodec.flushRequest()
                responseBuilder = httpCodec.readResponseHeaders(true)
            }

            if (responseBuilder == null) {
                // Write the request body if the "Expect: 100-continue" expectation was met.
                val requestBodyOut = httpCodec.createRequestBody(request, request.body()!!.contentLength())
                val bufferedRequestBody = Okio.buffer(requestBodyOut)
                request.body()!!.writeTo(bufferedRequestBody)
                bufferedRequestBody.close()
            }
        }

        httpCodec.finishRequest()

        if (responseBuilder == null) {
            responseBuilder = httpCodec.readResponseHeaders(false)
        }

        var response = responseBuilder!!
            .request(request)
//            .handshake(streamAllocation.connection().handshake())
            .sentRequestAtMillis(sentRequestMillis)
            .receivedResponseAtMillis(System.currentTimeMillis())
            .build()

        val code = response.code()
//        if (forWebSocket && code == 101) {
//            // Connection is upgrading, but we need to ensure interceptors see a non-null response body.
//            response = response.newBuilder()
//                .body(Util.EMPTY_RESPONSE)
//                .build()
//        } else {
            response = response.newBuilder()
                .body(httpCodec.openResponseBody(response))
                .build()
//        }

//        if ("close".equals(response.request().header("Connection"), ignoreCase = true) || "close".equals(response.header("Connection")!!, ignoreCase = true)) {
//            streamAllocation.noNewStreams()
//        }

        if ((code == 204 || code == 205) && response.body()!!.contentLength() > 0) {
            throw ProtocolException(
                "HTTP " + code + " had non-zero Content-Length: " + response.body()!!.contentLength())
        }

        return response
    }
}