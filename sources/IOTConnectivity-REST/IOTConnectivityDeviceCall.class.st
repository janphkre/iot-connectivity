Class {
	#name : #IOTConnectivityDeviceCall,
	#superclass : #IOTConnectivityCall,
	#instVars : [
		'deviceName'
	],
	#category : #'IOTConnectivity-REST-Calls'
}

{ #category : #accessing }
IOTConnectivityDeviceCall class >> description [
	^ 'A device may be used to querry its log or update its configuration.'
]

{ #category : #accessing }
IOTConnectivityDeviceCall class >> parameterDeviceName [
	<openApiParameter: #( common )>
	^ OAParameter new
		name: 'deviceName';
		in: #path;
		beString;
		required: true;
		description: 'The name given to the device by the system.'
]

{ #category : #accessing }
IOTConnectivityDeviceCall class >> path [ 
	^ '/devices/{deviceName}'
]

{ #category : #accessing }
IOTConnectivityDeviceCall class >> requestBody [
	^ super requestBody
		description: 'A device containing name and configuration.'
		yourself
]

{ #category : #accessing }
IOTConnectivityDeviceCall class >> requestBodyJson [
	<openApiRequestBody: #( update ) contentType: #( 'application/json' )>
	^ OAMediaTypeObject new
		schema: { 
			#name -> (JSONSchema string).
			 } asJSONSchema 
]

{ #category : #accessing }
IOTConnectivityDeviceCall class >> summary [
	^ 'A call to acquire a device.'
]

{ #category : #accessing }
IOTConnectivityDeviceCall >> get [
	response := (Device instanceWithName: deviceName)
		ifNotNil: [:device |
			ZnResponse  ok: (ZnEntity 
				with: (NeoJSONWriter toStringPretty: device)
				type: ZnMimeType applicationJson setCharSetUTF8) ]
		ifNil: [ ZnResponse notFound: '/devices/',deviceName asString ]
]
