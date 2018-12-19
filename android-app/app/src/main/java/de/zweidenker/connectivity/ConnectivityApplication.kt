package de.zweidenker.connectivity

import android.app.Application
import android.util.Log
import de.zweidenker.p2p.P2PModule
import org.koin.android.ext.android.startKoin
import org.koin.dsl.module.Module
import org.koin.log.Logger
import timber.log.Timber

class ConnectivityApplication: Application() {

    override fun onCreate() {
        super.onCreate()
        val koinLogger = setupLogging()
        startKoin(this, getKoinModules(), logger= koinLogger)
    }

    private fun getKoinModules(): List<Module> = listOf(
        P2PModule
    )

    private fun setupLogging(): Logger {
        Timber.plant(Timber.DebugTree())
//        Timber.plant(object : Timber.Tree() {
//            override fun log(priority: Int, tag: String?, message: String, t: Throwable?) {
//                if (priority == Log.DEBUG) {
//                    return
//                }
//                if (t == null) {
//                    Log.i(tag, message)
//                } else {
//                    Log.e(tag, message, t)
//                }
//            }
//        })

        return object : Logger {
            override fun err(msg: String) {
                Timber.e(msg)
            }
            override fun info(msg: String) {}
            override fun debug(msg: String) {}
        }
    }
}