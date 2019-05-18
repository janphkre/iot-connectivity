Class {
	#name : #ICNetwork,
	#superclass : #Object,
	#instVars : [
		'mac',
		'ssid',
		'signalStrength'
	],
	#category : #'IOTConnectivity-REST-Data'
}

{ #category : #public }
ICNetwork class >> allInstancesOrError: interfaceName [
  | libInterface |
	libInterface := LWpaInterface onName: interfaceName.
	^ (ICNetworkScan on: libInterface) scan collect: [ :aNetwork | self instanceOrError: aNetwork ]
  
]

{ #category : #'instance creation' }
ICNetwork class >> arrayToInstance: anArray [
  ^ self new
		mac: (anArray at: 1);
		ssid: (anArray at: 5);
		signalStrength: (Integer readFrom: (anArray at: 3));
		yourself
]

{ #category : #accessing }
ICNetwork class >> instance: aNetworkScanResult [
  ^ self arrayToInstance: (aNetworkScanResult splitOn: [ :char | char = (Character tab) ])
]

{ #category : #'instance creation' }
ICNetwork class >> instanceOrError: aNetworkScanResult [
  ^ ([ self instance: aNetworkScanResult ] on: Error do: [ :error | error ]) value
]

{ #category : #accessing }
ICNetwork class >> neoJsonMapping: mapper [
	mapper for: self do: [ :mapping |
		mapping mapInstVars: #( mac ssid signalStrength ) ]
]

{ #category : #accessing }
ICNetwork >> mac [
  ^ mac
]

{ #category : #accessing }
ICNetwork >> mac: aString [
  mac := aString
]

{ #category : #accessing }
ICNetwork >> signalStrength [
  ^ signalStrength
]

{ #category : #accessing }
ICNetwork >> signalStrength: anInteger [
  signalStrength := anInteger
]

{ #category : #accessing }
ICNetwork >> ssid [
  ^ ssid
]

{ #category : #accessing }
ICNetwork >> ssid: aString [
  ssid := aString
]
