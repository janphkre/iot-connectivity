Trait {
	#name : #TConnectivityEventHandler,
	#instVars : [
		'device'
	],
	#category : #'IOTConnectivity-P2P'
}

{ #category : #abstract }
TConnectivityEventHandler >> CTRL_EVENT_CONNECTED: anEvent [
	device note: 'Something.'
]

{ #category : #abstract }
TConnectivityEventHandler >> CTRL_EVENT_DISCONNECTED: anEvent [
	^ SubclassResponsibility
]

{ #category : #abstract }
TConnectivityEventHandler >> P2P_PROV_DISC_PBBC_REQ: anEvent [
	^ SubclassResponsibility
]
