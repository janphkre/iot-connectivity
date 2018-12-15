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
		'handle',
		'buffer',
		'bufferSize',
		'isStarted',
		'isAttached'
	],
	#classInstVars : [
		'socketPath',
		'registry'
	],
	#category : #'LibWpa-FFI-Handling'
}

{ #category : #'class initialization' }
LWpaControl class >> initialize [
	registry := WeakRegistry new.
	Smalltalk addToStartUpList: self; addToShutDownList: self.
	
]

{ #category : #'instance creation' }
LWpaControl class >> on: aString [
 ^ self onFile: (self socketPath resolveString: aString)
]

{ #category : #'instance creation' }
LWpaControl class >> on: interfaceString path: pathReference [
 ^ self onFile: (pathReference resolveString: interfaceString)
]

{ #category : #'instance creation' }
LWpaControl class >> onAny [
	"Creates a control interface on any interface it can find."
	| interface |
	interface := socketPath entries anyOne.
	^ self onFile: interface.
]

{ #category : #'instance creation' }
LWpaControl class >> onFile: aFileReference [
	| instance |
	instance := self new.
	instance interface: aFileReference.
	instance start.
	self register: instance.
	^ instance 
]

{ #category : #registry }
LWpaControl class >> register: aLWpaControl [
	registry add: aLWpaControl
]

{ #category : #accessing }
LWpaControl class >> registry [ 
	^ registry
]

{ #category : #registry }
LWpaControl class >> restoreRegistry [
	registry do: [ :aLWpaControl |
		aLWpaControl restoreForSystem.
		self flag: 'TODO: restore control state (restore selected messages?)' ]
]

{ #category : #'system startup' }
LWpaControl class >> shutDown: quitting [
	quitting ifFalse: [ ^ self ].
	self teardownRegistry.
]

{ #category : #'instance creation' }
LWpaControl class >> socketPath [
	^ socketPath ifNil: [ socketPath := '/var/run/wpa_supplicant' asFileReference ]
]

{ #category : #'instance creation' }
LWpaControl class >> socketPath: aFileReference [
	"Sets the socket path file reference for the default methods to be used. If you do not want to overwrite that value you can also just use #on:path: and specify a path explicitly."
	socketPath := aFileReference 
]

{ #category : #'system startup' }
LWpaControl class >> startUp: isImageStarting [
	isImageStarting ifFalse: [ ^ self ].
	self restoreRegistry.
]

{ #category : #registry }
LWpaControl class >> teardownRegistry [
	registry do: [ :aWlpaControl |
		aWlpaControl teardownForSystem ]
	
]

{ #category : #accessing }
LWpaControl >> buffer [
	^ buffer
]

{ #category : #commands }
LWpaControl >> command: aString [
	| resultCode |
	bufferSize value: buffer size.
	resultCode := self ffiLibraryInstance
		libwpa_request: handle
		command: aString
		commandLength: (aString size)
		reply: buffer
		replyLength: bufferSize
		callback: LWpaMessageCallback null.
	self validate: resultCode.
	^ buffer asString: bufferSize value.
]

{ #category : #deleting }
LWpaControl >> destroy [
	self stop.
	Transcript show: 'DESTROYED ME'.
	self flag: 'TODO instance registry.'
]

{ #category : #accessing }
LWpaControl >> interface [ 
	^ interface.
]

{ #category : #accessing }
LWpaControl >> interface: aFileReference [
	interface := aFileReference
]

{ #category : #commands }
LWpaControl >> interfaces [
	"List all available interfaces."
	^ (self command: 'INTERFACES') lines.
]

{ #category : #commands }
LWpaControl >> ping [
	^ self command: 'PING'
]

{ #category : #accessing }
LWpaControl >> restoreForSystem [
	isStarted = true
		ifFalse: [ ^ self ].
	self startInternal.
	isAttached = true
		ifTrue: [ self flag: 'TODO' ]
]

{ #category : #private }
LWpaControl >> start [
	isStarted
		ifTrue: [ LWpaError signal: 'Control has already been started!' ].
	self startInternal.
]

{ #category : #private }
LWpaControl >> startInternal [
	| result |
	result := self ffiLibraryInstance libwpa_open: interface fullName.
	result isNull
		ifTrue: [ LWpaError signal: 'Failed to open a control handle.' ].
	handle := result.
	buffer := LWpaStringBuffer new: 1024.
	bufferSize := LWpaReadWriteSizeT new: buffer size.
	isStarted := true
]

{ #category : #private }
LWpaControl >> stop [ 
	[ self teardownForSystem ]
	ensure: [
		isStarted := nil.
		isAttached := nil ]
]

{ #category : #private }
LWpaControl >> teardownForSystem [
	[ handle ifNotNil: [ :delete |
			isAttached = true
				ifTrue: [ self ffiLibraryInstance libwpa_detach: handle ].
			self ffiLibraryInstance libwpa_close: handle ] ]
	ensure: [
		handle free.
		buffer free.
		handle := nil.
		buffer := nil.
		bufferSize := nil ]
]

{ #category : #private }
LWpaControl >> validate: resultCode [
	resultCode = -1
		ifTrue: [ LWpaError signal ].
	resultCode = -2
		ifTrue: [ LWpaTimeoutError signal ].
	
]