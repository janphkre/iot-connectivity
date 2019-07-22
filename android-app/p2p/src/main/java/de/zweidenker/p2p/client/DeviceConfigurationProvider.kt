package de.zweidenker.p2p.client

import com.google.gson.Gson
import de.zweidenker.p2p.model.Device
import de.zweidenker.p2p.model.Interface
import de.zweidenker.p2p.model.Network
import de.zweidenker.p2p.model.NetworkConfig
import de.zweidenker.p2p.model.NetworkConfigProposal
import de.zweidenker.p2p.model.NetworkConfigUpdate
import okhttp3.Call.Factory
import okhttp3.HttpUrl
import org.koin.standalone.KoinComponent
import retrofit2.Retrofit
import retrofit2.adapter.rxjava.RxJavaCallAdapterFactory
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.PUT
import retrofit2.http.Path
import rx.Observable

interface DeviceConfigurationProvider {

    @GET("/interfaces")
    fun getInterfaces(): Observable<List<Interface>>

    @GET("/interfaces/{interfaceId}/networks")
    fun getAvailableNetworks(@Path("interfaceId") interfaceId: String): Observable<List<Network>>

    @POST("/interfaces/{interfaceId}/config")
    fun addNetworkConfig(@Path("interfaceId") interfaceId: String, @Body network: NetworkConfigProposal): Observable<NetworkConfig>

    @GET("/interfaces/{interfaceId}/config")
    fun getNetworkConfigs(@Path("interfaceId") interfaceId: String): Observable<List<NetworkConfig>>

    @PUT("/interfaces/{interfaceId}/config/{selectedNetwork}")
    fun updateNetworkConfig(
        @Path("interfaceId") interfaceId: String,
        @Path("selectedNetwork") networkId: String,
        @Body network: NetworkConfigUpdate
    ): Observable<NetworkConfig>

    companion object : KoinComponent {

        fun getInstance(callFactory: Factory, device: Device, deviceHost: String): DeviceConfigurationProvider {
            val gson = Gson()
            val httpUrl = HttpUrl.Builder()
                .host(deviceHost)
                .port(device.wifiDetails.port)
                .scheme("http")
                .build()
            val retrofit = Retrofit.Builder()
                .callFactory(callFactory)
                .addConverterFactory(GsonConverterFactory.create(gson))
                .addCallAdapterFactory(RxJavaCallAdapterFactory.create())
                .baseUrl(httpUrl)
                .build()
            return retrofit.create(DeviceConfigurationProvider::class.java)
        }
    }
}