Class {
	#name : #IOTConnectivityDeviceCollectionCall,
	#superclass : #IOTConnectivityCall,
	#category : #'IOTConnectivity-REST-Calls'
}

{ #category : #accessing }
IOTConnectivityDeviceCollectionCall class >> description [ 
	^ 'Returns a collection of available network devices. A device can be used to configure its network settings and query it`s log.'
]

{ #category : #accessing }
IOTConnectivityDeviceCollectionCall class >> path [ 
	^ '/devices'
]

{ #category : #accessing }
IOTConnectivityDeviceCollectionCall class >> summary [ 
	^ 'A call to aquire a list of available network devices.'
]

{ #category : #public }
IOTConnectivityDeviceCollectionCall >> get [
	| deviceList |
	deviceList := targetDevice interfacesNonP2P.
	response := ZnResponse ok: (ZnEntity 
		with: (NeoJSONWriter toString: Device instances)
		type: ZnMimeType  applicationJson setCharSetUTF8).
]
