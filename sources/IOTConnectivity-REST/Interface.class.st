Class {
	#name : #Interface,
	#superclass : #Object,
	#instVars : [
		'name',
		'ssid',
		'mode',
		'state'
	],
	#category : #'IOTConnectivity-REST-Data'
}

{ #category : #'instance creation' }
Interface class >> allInstancesOrError [
	^ LWpaInterface onAllNonP2P collect: [ :aLibInterface | self instanceOrError: aLibInterface ].
]

{ #category : #private }
Interface class >> arrayToInstance: anArray with: aString [
	| foundSsid foundMode foundState |
	anArray isEmptyOrNil
		ifTrue: [ LWpaError signal: 'Received an empty status array!' ].
	(anArray first beginsWith: 'FAIL')
		ifTrue: [ LWpaError signal: 'Status request failed!' ].
	foundSsid := (anArray
		at: (anArray findFirst: [ :item | item beginsWith: 'ssid' ])
		ifAbsent: [ '' ]) substrings: '='.
	foundSsid := foundSsid size = 2
		ifTrue: [ foundSsid second ]
		ifFalse: [ nil ].
	foundMode := (anArray
		at: (anArray findFirst: [ :item | item beginsWith: 'mode' ])
		ifAbsent: [ '' ]) substrings: '='.
	foundMode := foundMode size = 2
		ifTrue: [ foundMode second ]
		ifFalse: [ nil ].
	foundState := (anArray
		at: (anArray findFirst: [ :item | item beginsWith: 'wpa_state' ])
		ifAbsent: [ '' ]) substrings: '='.
	foundState := foundState size = 2
		ifTrue: [ foundState second ]
		ifFalse: [ nil ].
	^ self new
		name: aString;
		ssid: foundSsid;
		mode: foundMode;
		state: foundState;
		yourself
]

{ #category : #private }
Interface class >> instance: aLibInterface [
	| statusArray |
	aLibInterface isNil ifTrue: [ ^ nil ].
	statusArray := aLibInterface status.
	^ self arrayToInstance: statusArray with: (aLibInterface interface basename).
]

{ #category : #'instance creation' }
Interface class >> instanceOrError: aLibInterface [
	^ ([ self instance: aLibInterface ] on: LWpaError do: [ :error | error ]) value
]

{ #category : #'instance creation' }
Interface class >> instanceOrErrorFromName: aString [
  ^ self instanceOrError: (LWpaInterface onName: aString).
  
]

{ #category : #accessing }
Interface class >> neoJsonMapping: mapper [
	mapper for: self do: [ :mapping |
		mapping mapInstVars: #( name ssid mode state ) ]
]

{ #category : #accessing }
Interface >> mode [
	^ mode
]

{ #category : #accessing }
Interface >> mode: aString [
	mode := aString
]

{ #category : #accessing }
Interface >> name [
	^ name
]

{ #category : #accessing }
Interface >> name: aString [ 
	name := aString
]

{ #category : #accessing }
Interface >> ssid [
	^ ssid
]

{ #category : #accessing }
Interface >> ssid: aString [
	ssid := aString
]

{ #category : #accessing }
Interface >> state [ 
	^ state
]

{ #category : #accessing }
Interface >> state: aString [
	state := aString
]
