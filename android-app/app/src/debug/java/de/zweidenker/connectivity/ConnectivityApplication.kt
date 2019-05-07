package de.zweidenker.connectivity

import android.app.Application
import de.zweidenker.p2p.P2PModule
import org.koin.android.ext.android.startKoin
import org.koin.dsl.module.Module
import org.koin.log.Logger
import timber.log.Timber

class ConnectivityApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        val koinLogger = setupLogging()
        startKoin(this, getKoinModules(), logger = koinLogger)
    }

    private fun getKoinModules(): List<Module> = listOf(
        P2PModule,
        ApplicationModule
    )

    private fun setupLogging(): Logger {
        Timber.plant(Timber.DebugTree())

        return object : Logger {
            override fun err(msg: String) {
                Timber.e(msg)
            }
            override fun info(msg: String) {
                Timber.i(msg)
            }
            override fun debug(msg: String) {
                Timber.d(msg)
            }
        }
    }
}