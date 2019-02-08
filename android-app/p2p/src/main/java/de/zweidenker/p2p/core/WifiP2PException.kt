package de.zweidenker.p2p.core

class WifiP2PException(message: String, val errorCode: Int): Exception(message + " $errorCode")