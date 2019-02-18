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
ConnectivityP2PEventHandler >> P2P_GO_NEG_REQUEST: anEvent [
  "<3>P2P-GO-NEG-REQUEST 94:65:2d:d6:65:72 dev_passwd_id=4 go_intent=0"
  	anEvent parameters size < 4
	ifTrue: [ ^ self ].
	service p2pInvite: (anEvent parameter: 2).
]

{ #category : #events }
ConnectivityP2PEventHandler >> P2P_GROUP_STARTED: anEvent [
 self flag: #TODO.
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
