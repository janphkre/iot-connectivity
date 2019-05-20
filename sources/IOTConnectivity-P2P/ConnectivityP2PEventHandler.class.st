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
ConnectivityP2PEventHandler >> CTRL_EVENT_DISCONNECTED: anEvent [
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
	((anEvent parameters at: 4) allButFirst: 10) asInteger >= 0
	ifTrue: [ 
		UIManager default inform: 'Requesting the peer to become GO'.
		service p2pConnectPbc: (anEvent parameter: 2).
		^ self ].
	UIManager default inform: 'Inviting the peer to our group'.
	service p2pInvite: (anEvent parameter: 2).
]

{ #category : #events }
ConnectivityP2PEventHandler >> P2P_GO_NEG_SUCCESS: anEvent [

]

{ #category : #events }
ConnectivityP2PEventHandler >> P2P_GROUP_FORMATION_FAILURE: anEvent [
	"This usually indicates that the group formation with a peer has failed. Problem is, that this Event crashes the wpa_supplicant, therefor we have to restart it and this image afterwards."
	UIManager default inform: 'Group formation failure. wpa_supplicant has probably crashed!'.
]

{ #category : #events }
ConnectivityP2PEventHandler >> P2P_GROUP_FORMATION_SUCCESS: anEvent [
]

{ #category : #events }
ConnectivityP2PEventHandler >> P2P_GROUP_REMOVED: anEvent [
	"Indicates that a p2p group was removed. The reason will most likely be 'IDLE'."
]

{ #category : #events }
ConnectivityP2PEventHandler >> P2P_GROUP_STARTED: anEvent [
  "<3>P2P-GROUP-STARTED p2p-wlan0-3 GO ssid=DIRECT-Sx freq=5180 passphrase=922JFxeQ go_dev_addr=ba:27:eb:23:9c:d0
	<3>P2P-GROUP-STARTED p2p-wlan0-0 client ssid=""DIRECT-VBSM-G935F"" freq=5180 psk=0f8dc58cc5e97c9565bf0cae5b94e1b3d471f89340d271a70d6196c3c12e7ef8 go_dev_addr=ae:5f:3e:2b:3b:4f ip_addr=192.168.49.200 ip_mask=255.255.255.0 go_ip_addr=192.168.49.1"
  anEvent parameters size < 7
	ifTrue: [ ^ self ].
	anEvent parameters size < 9
	ifTrue: [ 
		service groupStarted: (anEvent parameter: 2).
		^ self. ].
	service groupStarted: (anEvent parameter: 2) on: ((anEvent parameter: 9) allButFirst: 11).
	
]

{ #category : #events }
ConnectivityP2PEventHandler >> P2P_INVITATION_RECEIVED: anEvent [
	"Received an invitation to join a group. This crashes the wpa_supplicant, therefor we have to restart it and this image afterwards."
	UIManager default inform: 'Received a p2p invitation. wpa_supplicant has probably crashed! ', anEvent parameters asString.
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
