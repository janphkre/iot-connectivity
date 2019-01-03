"
I represent a bonjour service which is the a P2PService based on DNS Service Discovery.
In the android project i am mostly represented by
https://android.googlesource.com/platform/frameworks/base/+/56a2301/wifi/java/android/net/wifi/p2p/nsd/WifiP2pDnsSdServiceResponse.java
https://android.googlesource.com/platform/frameworks/base/+/56a2301/wifi/java/android/net/wifi/p2p/nsd/WifiP2pDnsSdServiceInfo.java

Since I did not get access to the WiFi Direct Specification, We have to stick with the android code.
According to that the structure is as follows for responses:
 ________________________________________________
 |  encoded and compressed dns name (variable)  |
 ________________________________________________
 |       dnstype(2byte)      |  version(1byte)  |
 ________________________________________________
 |              RDATA (variable)                |
"
Class {
	#name : #LWpaBonjourService,
	#superclass : #LWpaP2PService,
	#instVars : [
		'serviceValues',
		'instanceName',
		'serviceType'
	],
	#category : #'LibWpa-Commands'
}

{ #category : #'instance creation' }
LWpaBonjourService class >> new: aInstanceString as: aTypeString with: aDictionary [
	^ self new
	instanceName: aInstanceString;
	serviceType: aTypeString;
	serviceValues: aDictionary;
	yourself.
]

{ #category : #building }
LWpaBonjourService >> compressName: aString [
	| resultString data workString i stream |
	resultString := ''.
	workString := aString asLowercase.
	[ true ] whileTrue: [
		data := self class svmPacket at: workString ifAbsent: nil.
		data isNotNil
		ifTrue: [ ^ resultString, data ].
		i := workString indexOf: $. ifAbsent: 0.
		i = 0
		ifTrue: [ 
			workString length > 0
			ifTrue: [ resultString := resultString, (self hexDump: workString) ].
			^ resultString, '00' ].
		stream := workString readStream.
		"Portion before the dot."
		data := stream upToPosition: i - 1.
		"Skip the dot."
		stream skip: 1.
		"Unprocessed remains."
		workString := stream upToEnd.
		resultString := resultString, (self hexDump: data) ].

]

{ #category : #building }
LWpaBonjourService >> idDump [
	"Last 3 bytes are type(2B) = txt = 16 = 0x0010 and version(1B) = 0x01"
	^ (self compressName: (instanceName, '.', serviceType, '.local.')), '001001'.
]

{ #category : #accessing }
LWpaBonjourService >> instanceName: aString [
	instanceName := aString
]

{ #category : #building }
LWpaBonjourService >> serviceDump [
	"Dumps the key value map for the service."
	| valuesCollection index |
	serviceValues isEmptyOrNil
		ifTrue: [ ^ '00' ].
	valuesCollection := Array new: (serviceValues size).
	index := 1.
	serviceValues keysAndValuesDo: [ :key :value |
		self validate: key value: value.
		value isNil
			ifTrue: [ valuesCollection at: index put: (self hexDump: key) ]
			ifFalse: [ valuesCollection at: index put: (self hexDump: (key, '=', value)) ].
		index := index + 1 ].
	^ valuesCollection fold: [ :a :b | a, b ]
]

{ #category : #accessing }
LWpaBonjourService >> serviceType: aString [
	serviceType := aString
]

{ #category : #accessing }
LWpaBonjourService >> serviceValues [
	^ serviceValues.
]

{ #category : #accessing }
LWpaBonjourService >> serviceValues: aDictionary [
	serviceValues := aDictionary.
]

{ #category : #accessing }
LWpaBonjourService >> type [
	^ 'bonjour'
]

{ #category : #building }
LWpaBonjourService >> validate: aKey value: aValue [
	"Validates a key value pair wether they can be used in the bonjour service for a DNS txt record."
	aKey isAsciiString
			ifFalse: [ LWpaFormatError signal: 'key ', aKey, ' is not a ascii string!' ].
	(aKey anySatisfy: [ :char | char = $=])
		ifTrue: [ LWpaFormatError signal: 'key ', aKey, ' contains a = sign!' ].
	
	((aValue isNil
		ifTrue: [ 0 ]
		ifFalse: [ aValue size ] ) + aKey size) * 2 >= 255
		ifTrue: [ LWpaHexTooBigError signal: 'key ', aKey, 'combined with it`s value are too long!' ]
		
]
