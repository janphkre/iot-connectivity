Class {
	#name : #ICConfig,
	#superclass : #ICData,
	#instVars : [
		'ssid',
		'password',
		'networkId',
		'disabled',
		'selected'
	],
	#category : #'IOTConnectivity-REST-Data'
}

{ #category : #parsing }
ICConfig class >> arrayToInstance: anArray [
	| flags |
	flags := self parseFlags: (anArray at: 4).
  ^ self new
		networkId: (anArray at: 1);
		ssid: (anArray at: 2);
		disabled: (flags anySatisfy: [ :item | item = #DISABLED ]);
		selected: (flags anySatisfy: [ :item | item = #CURRENT ]);
		obscure;
		yourself
]

{ #category : #accessing }
ICConfig class >> dataCollection: aLibInterface [
	^ aLibInterface listNetworks.
]

{ #category : #accessing }
ICConfig class >> instance: anItem [
	^ self arrayToInstance: (anItem splitOn: [ :char | char = (Character tab) ])
]

{ #category : #accessing }
ICConfig class >> neoJsonMapping: mapper [
	mapper for: self do: [ :mapping |
		mapping mapInstVars: #( networkId ssid password disabled selected) ]
]

{ #category : #public }
ICConfig >> createOn: interfaceName [
| libInterface |
	libInterface := LWpaInterface onName: interfaceName.
	networkId := libInterface createNetwork.
	[ self writeTo: libInterface. ] on: Error do: [ :error |
		libInterface removeNetwork: networkId.
		error signal. ].
	disabled := true.
	self obscure.
	^ self
]

{ #category : #public }
ICConfig >> createOrErrorOn: interfaceName [
	([ ^ self createOn: interfaceName
  ] on: Error do: [ :error | ^ error ]) value
]

{ #category : #accessing }
ICConfig >> disabled [
	^ disabled
]

{ #category : #accessing }
ICConfig >> disabled: aBoolean [
	disabled := aBoolean
]

{ #category : #writing }
ICConfig >> enableNetworkOn: aLibInterface [
	disabled ifNotNil: [ :data |
		data ifFalse: [ aLibInterface enableNetwork: networkId. ]
		ifTrue: [ aLibInterface disableNetwork: networkId. ]. ].
]

{ #category : #accessing }
ICConfig >> networkId [
	^ networkId
]

{ #category : #accessing }
ICConfig >> networkId: anInteger [
	networkId := anInteger
]

{ #category : #accessing }
ICConfig >> obscure [
	password := '****'
]

{ #category : #accessing }
ICConfig >> password [
	^ password
]

{ #category : #accessing }
ICConfig >> password: aString [
	password := aString
]

{ #category : #writing }
ICConfig >> selectNetworkOn: aLibInterface [
	selected ifNotNil: [ :data |
		data ifTrue: [ aLibInterface selectNetwork: networkId. ] ].
]

{ #category : #accessing }
ICConfig >> selected [
	^ selected.
]

{ #category : #accessing }
ICConfig >> selected: aBoolean [
	selected := aBoolean.
]

{ #category : #accessing }
ICConfig >> ssid [
	^ ssid
]

{ #category : #accessing }
ICConfig >> ssid: aString [
		ssid := aString.
]

{ #category : #public }
ICConfig >> updateOn: interfaceName [
	self writeTo: (LWpaInterface onName: interfaceName).
	self obscure.
	^ self.
]

{ #category : #writing }
ICConfig >> writePasswordTo: aLibInterface [
	password ifNotNil: [ :data | aLibInterface setNetwork: #'psk' data: data on: networkId ].
	
]

{ #category : #writing }
ICConfig >> writeSsidTo: aLibInterface [
 ssid ifNotNil: [ :data | aLibInterface setNetwork: #'ssid' data: data on: networkId ].
	
]

{ #category : #writing }
ICConfig >> writeTo: aLibInterface [
	self writeSsidTo: aLibInterface.
	self writePasswordTo: aLibInterface.
	"self writeTypeTo: aLibInterface."
	self enableNetworkOn: aLibInterface.
	self selectNetworkOn: aLibInterface.
	aLibInterface saveConfig.
]

{ #category : #writing }
ICConfig >> writeTypeTo: aLibInterface [
	aLibInterface setNetwork: #'key_mgmt' data: 'WPA2-PSK-CCMP' on: networkId
	
]
