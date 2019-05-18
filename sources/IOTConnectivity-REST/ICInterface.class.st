Class {
	#name : #ICInterface,
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
ICInterface class >> allInstancesOrError [
	^ LWpaInterface onAllNonP2P collect: [ :aLibInterface | self instanceOrError: aLibInterface ].
]

{ #category : #private }
ICInterface class >> arrayToInstance: anArray with: aString [
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
ICInterface class >> instance: aLibInterface [
	| statusArray |
	aLibInterface isNil ifTrue: [ ^ nil ].
	statusArray := aLibInterface status.
	^ self arrayToInstance: statusArray with: (aLibInterface interface basename).
]

{ #category : #'instance creation' }
ICInterface class >> instanceOrError: aLibInterface [
	^ ([ self instance: aLibInterface ] on: LWpaError do: [ :error | error ]) value
]

{ #category : #'instance creation' }
ICInterface class >> instanceOrErrorFromName: aString [
  ^ ([ self instance: (LWpaInterface onName: aString) ] on: LWpaError do: [ :error | error ]) value
  
]

{ #category : #accessing }
ICInterface class >> neoJsonMapping: mapper [
	mapper for: self do: [ :mapping |
		mapping mapInstVars: #( name ssid mode state ) ]
]

{ #category : #accessing }
ICInterface >> mode [
	^ mode
]

{ #category : #accessing }
ICInterface >> mode: aString [
	mode := aString
]

{ #category : #accessing }
ICInterface >> name [
	^ name
]

{ #category : #accessing }
ICInterface >> name: aString [ 
	name := aString
]

{ #category : #accessing }
ICInterface >> ssid [
	^ ssid
]

{ #category : #accessing }
ICInterface >> ssid: aString [
	ssid := aString
]

{ #category : #accessing }
ICInterface >> state [ 
	^ state
]

{ #category : #accessing }
ICInterface >> state: aString [
	state := aString
]
