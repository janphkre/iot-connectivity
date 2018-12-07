Class {
	#name : #IOTConnectivityDeviceLogCall,
	#superclass : #IOTConnectivityCall,
	#instVars : [
		'deviceName'
	],
	#category : 'IOTConnectivity-REST'
}

{ #category : #accessing }
IOTConnectivityDeviceLogCall class >> description [
	^ 'The log of a device may contain further information for the user as of why the device is in its current status.'
]

{ #category : #'as yet unclassified' }
IOTConnectivityDeviceLogCall class >> parameterDeviceName [
	<openApiParameter: #( common )>
	^ OAParameter new
		name: 'deviceName';
		in: #path;
		beString;
		required: true;
		description: 'The name given to the device by the system.'
]

{ #category : #accessing }
IOTConnectivityDeviceLogCall class >> path [
	^ '/devices/{deviceName}/log'
]

{ #category : #accessing }
IOTConnectivityDeviceLogCall class >> summary [
	^ 'A call to acquire the log of a device.'
]

{ #category : #public }
IOTConnectivityDeviceLogCall >> get [
	response := ZnResponse ok: (ZnEntity
		with: (NeoJSONWriter toStringPretty: deviceName)
		type: ZnMimeType applicationJson setCharSetUTF8)
]
