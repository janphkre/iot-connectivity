package de.zweidenker.p2p.client

import com.google.gson.Gson
import de.zweidenker.p2p.model.Device
import de.zweidenker.p2p.model.Interface
import de.zweidenker.p2p.model.Network
import de.zweidenker.p2p.model.NetworkConfig
import okhttp3.HttpUrl
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.adapter.rxjava.RxJavaCallAdapterFactory
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.PUT
import retrofit2.http.Path
import retrofit2.http.Query
import rx.Observable
import java.util.concurrent.TimeUnit

interface DeviceConfigurationProvider {

    @GET("/interfaces")
    fun getInterfaces(): Observable<List<Interface>>

    @GET("/interfaces/{interfaceId}/networks")
    fun getAvailableNetworks(@Path("interfaceId") interfaceId: String): Observable<List<Network>>

    @POST("/interfaces/{interfaceId}/configs")
    fun addNetworkConfig(@Path("interfaceId") interfaceId: String, @Body network: NetworkConfig): Observable<String>

    @GET("/interfaces/{interfaceId}/configs")
    fun getNetworkConfigs(@Path("interfaceId") interfaceId: String): Observable<List<NetworkConfig>>

    @PUT("/interfaces/{interfaceId}/networks")
    fun selectNetworkConfig(@Path("interfaceId") interfaceId: String, @Query("selectedNetwork") networkId: String): Observable<Unit>

    @GET("/interfaces/{interfaceId}/log")
    fun getLog(@Path("interfaceId") interfaceId: String): Observable<List<String>>

    companion object {

        private val TIMEOUT = 30L

        fun getInstance(device: Device, deviceIpAddress: String): DeviceConfigurationProvider {
            val clientBuilder = OkHttpClient.Builder()
                .connectTimeout(TIMEOUT, TimeUnit.SECONDS)
                .readTimeout(TIMEOUT, TimeUnit.SECONDS)
                .writeTimeout(TIMEOUT, TimeUnit.SECONDS)
            val httpClient = clientBuilder.build()
            val gson = Gson()
            val httpUrl = HttpUrl.Builder()
                .host(deviceIpAddress)
                .port(device.port)
                .scheme("http")
                .build()
            val RETROFIT = Retrofit.Builder()
                .client(httpClient)
                .addConverterFactory(GsonConverterFactory.create(gson))
                .addCallAdapterFactory(RxJavaCallAdapterFactory.create())
                .baseUrl(httpUrl)
                .build()
            return RETROFIT.create(DeviceConfigurationProvider::class.java)
        }
    }
}