Class {
	#name : #ICNetwork,
	#superclass : #ICData,
	#instVars : [
		'mac',
		'ssid',
		'signalStrength',
		'security'
	],
	#category : #'IOTConnectivity-REST-Data'
}

{ #category : #parsing }
ICNetwork class >> arrayToInstance: anArray [
  ^ self new
		mac: (anArray at: 1);
		signalStrength: (Integer readFrom: (anArray at: 3));
		security: (self parseFlags: (anArray at: 4));
		ssid: (anArray at: 5);
		yourself
]

{ #category : #accessing }
ICNetwork class >> dataCollection: aLibInterface [
  ^ (ICNetworkScan on: aLibInterface) scan
]

{ #category : #'instance creation' }
ICNetwork class >> instance: anItem [
  ^ self arrayToInstance: (anItem splitOn: [ :char | char = (Character tab) ])
]

{ #category : #accessing }
ICNetwork class >> neoJsonMapping: mapper [
	mapper for: self do: [ :mapping |
		mapping mapInstVars: #( mac ssid signalStrength security) ]
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
ICNetwork >> security [
	^ security
]

{ #category : #accessing }
ICNetwork >> security: anArray [
	security := anArray
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
