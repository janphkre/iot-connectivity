Class {
	#name : #IOTConnectivityInterfaceLogCall,
	#superclass : #IOTConnectivityCall,
	#category : #'IOTConnectivity-REST-Calls'
}

{ #category : #accessing }
IOTConnectivityInterfaceLogCall class >> description [
	^ 'The log of a device may contain further information for the user as of why the device is in its current status.'
]

{ #category : #accessing }
IOTConnectivityInterfaceLogCall class >> path [
	^ '/log'
]

{ #category : #accessing }
IOTConnectivityInterfaceLogCall class >> summary [
	^ 'A call to acquire the log of a device.'
]

{ #category : #public }
IOTConnectivityInterfaceLogCall >> get [
	response := ZnResponse ok: (ZnEntity
		with: (NeoJSONWriter toString: 'This is a string.')
		type: ZnMimeType applicationJson setCharSetUTF8)
]
