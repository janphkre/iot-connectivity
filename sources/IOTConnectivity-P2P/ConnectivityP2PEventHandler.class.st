Class {
	#name : #ConnectivityP2PEventHandler,
	#superclass : #EventHandler,
	#category : #'IOTConnectivity-P2P'
}

{ #category : #'instance creation' }
ConnectivityP2PEventHandler class >> on: aService [
	^ self new service: aService.
]

{ #category : #events }
ConnectivityP2PEventHandler >> AP_STA_CONNECTED: anEvent [
 "Can be ignored"
]

{ #category : #events }
ConnectivityP2PEventHandler >> AP_STA_DISCONNECTED: anEvent [
 "Can be ignored"
]

{ #category : #events }
ConnectivityP2PEventHandler >> P2P_DEVICE_FOUND: anEvent [
  "Signals that a p2p device has been discovered"
]

{ #category : #events }
ConnectivityP2PEventHandler >> P2P_DEVICE_LOST: anEvent [
	"Can be ignored as it indicates that a previously discovered device was not discovered anymore."
]

{ #category : #events }
ConnectivityP2PEventHandler >> P2P_GO_NEG_REQUEST: anEvent [
  "<3>P2P-GO-NEG-REQUEST 94:65:2d:d6:65:72 dev_passwd_id=4 go_intent=0"
  anEvent parameters size < 4
	ifTrue: [ ^ self ].
	service p2pInvite: (anEvent parameter: 2).
]

{ #category : #events }
ConnectivityP2PEventHandler >> P2P_GROUP_FORMATION_FAILURE: anEvent [
	"This usually indicates that the group formation with a peer has failed. Problem is, that this Event crashes the wpa_supplicant, therefor we have to restart it and this image afterwards."
	UIManager default inform: 'Group formation failure. wpa_supplicant has probably crashed!'.
]

{ #category : #events }
ConnectivityP2PEventHandler >> P2P_GROUP_STARTED: anEvent [
  "<3>P2P-GROUP-STARTED p2p-wlan0-3 GO ssid=DIRECT-Sx freq=5180 passphrase=922JFxeQ go_dev_addr=ba:27:eb:23:9c:d0"
  anEvent parameters size < 7
	ifTrue: [ ^ self ].
  service groupStarted: (anEvent parameter: 2).
]

{ #category : #events }
ConnectivityP2PEventHandler >> P2P_INVITATION_RECEIVED: anEvent [
	"Received an invitation to join a group. This crashes the wpa_supplicant, therefor we have to restart it and this image afterwards."
	UIManager default inform: 'Received a p2p invitation. wpa_supplicant has probably crashed!'.
]

{ #category : #events }
ConnectivityP2PEventHandler >> P2P_PROV_DISC_PBC_REQ: anEvent [
	"Request from the peer for us to connect using PBC. The following parameters are included after the event prefix: peer_address. P2P_CONNECT command can be used to accept the request."
]

{ #category : #events }
ConnectivityP2PEventHandler >> P2P_SERV_DISC_REQ: anEvent [
	"Indicate reception of a P2P service discovery request. The following parameters are included after the event prefix: frequency in MHz, source address, dialog token, Service Update Indicator, Service Query TLV(s) as hexdump.
	We ignore this event since we are using internal service discovery of wpa_supplicant."
]
