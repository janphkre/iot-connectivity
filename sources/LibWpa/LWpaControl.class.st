"
I am a facade to interact with this library through a control communication channel.
You can open multiple channels at the same time, which is also recommended,
to split up events from command results.

	LWpaControl onAny
is equivalent to 
	LWpaControl on: nil path: 'var/run/wpa_supplicant'
A specific interface can be specified at creation as well:
	| control |
	control:= LWpaControl on: 'wlan0'
All the commands will then be sent to that interface. If no interface is specified the first one returned from wpacontrol will be chosen.
The Control can then be used to send and receives messages:
	control interfaces.
	control 
"
Class {
	#name : #LWpaControl,
	#superclass : #Object,
	#traits : 'TLWpaFFITrait',
	#classTraits : 'TLWpaFFITrait classTrait',
	#instVars : [
		'interface',
		'path',
		'handle'
	],
	#category : #'LibWpa-FFI-Handling'
}

{ #category : #'instance creation' }
LWpaControl class >> on: aString [
 | instance |
	instance := self new.
	instance interface: aString.
	instance start.
	self flag: 'TODO: instance registry'.
	^ instance.
]

{ #category : #'instance creation' }
LWpaControl class >> on: interfaceString path: pathString [
 | instance |
	instance := self new.
	instance path: pathString.
	instance interface: interfaceString.
	instance start.
	self flag: 'TODO: instance registry'.
	^ instance.
]

{ #category : #'instance creation' }
LWpaControl class >> onAny [
	| instance |
	instance := self new.
	instance start.
	self flag: 'TODO: instance registry'.
	^ instance.
]

{ #category : #commands }
LWpaControl >> command: aString [
	^ self ffiLibraryInstance libwpa_request: handle command: aString
]

{ #category : #deleting }
LWpaControl >> destroy [
	self stop.
	self flag: 'TODO instance registry.'
]

{ #category : #accessing }
LWpaControl >> interface [ 
	^ interface.
]

{ #category : #accessing }
LWpaControl >> interface: aString [
	interface := aString
]

{ #category : #commands }
LWpaControl >> interfaces [
	"List all available interfaces."
	^ (self command: 'interface').
]

{ #category : #accessing }
LWpaControl >> path [
	^ path
]

{ #category : #accessing }
LWpaControl >> path: aString [
	"path to unix sockets"
	path := aString
]

{ #category : #private }
LWpaControl >> start [
	| controlPath |
	controlPath := path ifNil: [ '/var/run/wpa_supplicant' ].
	handle := handle ifNil: [ self ffiLibraryInstance libwpa_open: controlPath ].
	^ handle isNil
]

{ #category : #private }
LWpaControl >> stop [ 
	[ handle ifNotNil: [ :delete |
			(self ffiLibraryInstance) libwpa_detach: handle;
			libwpa_close: handle ] ]
	ensure: [ handle := nil ]
]
