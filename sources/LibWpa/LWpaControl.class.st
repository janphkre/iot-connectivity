"
I am a facade to interact with this library through a control communication channel.
You can open multiple channels at the same time, which is also recommended,
to split up events from command results.
Instead of using this class consider using LWpaP2PDevice.

	LWpaControl onAny.
A specific interface can be specified at creation as well:
	| control |
	control:= LWpaControl on: ('/var/run/wpa_supplicant/wlan0' asFileReference).
	
All the commands will then be sent to that interface. If no interface is specified the first one returned from wpacontrol will be chosen.
The Control can then be used to send and receives messages:
	control ping.
	control command: 'INTERFACES'.
	
Event messages can be recieved by:
	control attach: [ :eventString | eventString inspect. ].
Once you don't want to recieve events anymore simply call:
	control detach.
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
		'attachedBlock',
		'process',
		'isRecording',
		'recording',
		'dynamicRecording'
	],
	#classInstVars : [
		'socketPath',
		'registry'
	],
	#category : #'LibWpa-FFI-Handling'
}

{ #category : #accessing }
LWpaControl class >> anyDevice [
	^ self socketPath entries anyOne.
]

{ #category : #accessing }
LWpaControl class >> anyNonP2PDevice [
	^ (self socketPath entries reject: [ :entry |
		entry basename beginsWith: 'p2p-' ]) anyOne.
]

{ #category : #accessing }
LWpaControl class >> anyP2PDevice [
	^ (self socketPath entries select: [ :entry |
		entry basename beginsWith: 'p2p-dev' ]) anyOne.
]

{ #category : #'class initialization' }
LWpaControl class >> initialize [
	registry := WeakRegistry new.
	Smalltalk addToStartUpList: self; addToShutDownList: self.
	
]

{ #category : #'instance creation' }
LWpaControl class >> on: aString [
 ^ self onFile: (self resolve: aString).
]

{ #category : #'instance creation' }
LWpaControl class >> on: interfaceString path: pathReference [
 ^ self onFile: (pathReference resolveString: interfaceString)
]

{ #category : #'instance creation' }
LWpaControl class >> onAny [
	"Creates a control interface on any interface it can find."
	^ self onFile: self anyDevice.
]

{ #category : #'instance creation' }
LWpaControl class >> onAnyNonP2P [
	"Creates a control interface on any interface it can find."
	^ self onFile: self anyNonP2PDevice.
]

{ #category : #'instance creation' }
LWpaControl class >> onAnyP2P [
	"Creates a control interface on any p2p interface it can find."
	^ self onFile: self anyP2PDevice.
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
	registry finalizeValues.
	registry add: aLWpaControl.
]

{ #category : #accessing }
LWpaControl class >> registry [ 
	^ registry
]

{ #category : #accessing }
LWpaControl class >> registry: aRegistry [
	registry := aRegistry
]

{ #category : #accessing }
LWpaControl class >> resolve: interfaceString [
	^ self socketPath resolveString: interfaceString.
]

{ #category : #registry }
LWpaControl class >> restoreRegistry [
registry finalizeValues.
	registry do: [ :aLWpaControl |
		aLWpaControl restoreForSystem. ]
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
		aWlpaControl teardownForSystem ].
	registry finalizeValues.
]

{ #category : #events }
LWpaControl >> attach: aBlock [
	self attachInternal: aBlock.
	(self ffiLibraryInstance libwpa_attach: handle) >= -1
		ifTrue: [ ^ self ].
	self detachInternal.
	LWpaError signal: 'Failed to attach handle.'
]

{ #category : #events }
LWpaControl >> attachInternal: aBlock [
	| delay |
	self isAttached
		ifTrue: [ self detachInternal ].
	attachedBlock := aBlock.
	delay := Delay forMilliseconds: 200.
	process := [ [
			self listenLoop.
			delay wait.
			] repeat ]
		forkAt: Processor userSchedulingPriority 
		named: self processName.
]

{ #category : #accessing }
LWpaControl >> buffer [
	^ buffer
]

{ #category : #private }
LWpaControl >> close [ 
	handle isNull ifTrue: [ ^ self ].
	self ffiLibraryInstance libwpa_close: handle.
]

{ #category : #commands }
LWpaControl >> command: aString [
	isStarted = true ifFalse: [ LWpaError signal: 'This Control has not been started! Maybe the interface does not exist anymore?' ].
	isRecording = true ifTrue: [ self record: aString ].
	^ self commandInternal: aString.
]

{ #category : #private }
LWpaControl >> commandInternal: aString [
	| resultCode |
	bufferSize value: buffer size.
	resultCode := self ffiLibraryInstance
		libwpa_request: handle
		command: aString
		commandLength: (aString size)
		reply: buffer
		replyLength: bufferSize
		callback: LWpaMessageCallback null.
"	resultCode = -1
		ifTrue: [ LWpaError signal: 'Error for performing request!' ]."
	resultCode = -2
		ifTrue: [ LWpaTimeoutError signal: 'Performing the request timed out.' ].
	^ buffer asString: bufferSize value.
]

{ #category : #deleting }
LWpaControl >> destroy [
	self stop.
]

{ #category : #events }
LWpaControl >> detach [
	self 	detachInternal.
	handle isNull ifTrue: [ ^ 0 ].
	^ self ffiLibraryInstance libwpa_detach: handle.
]

{ #category : #events }
LWpaControl >> detachForSystem [
	self isAttached ifTrue: [ 
		process terminate. 
		process := nil ].
	handle isNull ifTrue: [ ^ self ].
	self ffiLibraryInstance libwpa_detach: handle.
]

{ #category : #events }
LWpaControl >> detachInternal [
	attachedBlock := nil.
	self isAttached ifFalse: [ ^ self ].
	process terminate. 
	process := nil.
	
]

{ #category : #accessing }
LWpaControl >> dynamicRecording: aBlock [
	dynamicRecording := aBlock.
]

{ #category : #finalization }
LWpaControl >> finalize [
	[ self stop. ] on: LWpaError do: [ :err | "We ignore this error because we are finalizing this object anyway." ]
]

{ #category : #accessing }
LWpaControl >> flush [
	handle isNull ifTrue: [ ^ self ].
	self command: 'P2P_SERVICE_FLUSH';
	command: 'P2P_FLUSH'
]

{ #category : #configuration }
LWpaControl >> forgetRecording [
	"Clear the recording which is run on restart of this control."
	recording := nil.
	isRecording := nil.
	dynamicRecording := nil.
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

{ #category : #accessing }
LWpaControl >> isAttached [
	^ process isNotNil
]

{ #category : #events }
LWpaControl >> listenLoop [
	[ (self ffiLibraryInstance libwpa_pending: handle) = 1 ]
	whileTrue: [ attachedBlock value: self receive ].
]

{ #category : #commands }
LWpaControl >> ping [
	"Will reply with pong. This is a very simple command to check if everything is set up correctly."
	^ self command: 'PING'
]

{ #category : #private }
LWpaControl >> processName [
	^ String streamContents: [ :stream |
		 stream nextPutAll: self class name; nextPutAll: ' interface '; nextPutAll: self interface basename ]
]

{ #category : #events }
LWpaControl >> receive [
	| resultCode result |
	bufferSize value: buffer size.
	resultCode := (self ffiLibraryInstance libwpa_receive: handle reply: buffer replyLength: bufferSize).
	resultCode = -1
		ifTrue: [ LWpaError signal: 'Error while receiving event!' ].
	result := buffer asString: bufferSize value.
	^ result.
]

{ #category : #configuration }
LWpaControl >> record: aString [
	(recording ifNil: [ recording := LinkedList new ])
		addLast: aString
]

{ #category : #configuration }
LWpaControl >> replay [
	recording ifNotNil: [ :it |
		it do: [ :record | 
			self commandInternal: record ] ].
	self replayDynamic.
]

{ #category : #configuration }
LWpaControl >> replayDynamic [
  dynamicRecording ifNotNil: [ :it |
		it value. ]
  
]

{ #category : #accessing }
LWpaControl >> restoreForSystem [
	isStarted = true
		ifFalse: [ ^ self ].
	[ self startInternal. ]
	on: LWpaError
	do: [
		isStarted := nil.
		^ self ].
	attachedBlock isNil
		ifFalse: [ self attach: attachedBlock ].
	self replay.
]

{ #category : #private }
LWpaControl >> start [
	isStarted = true
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
	buffer := LWpaStringBuffer new: 2048.
	bufferSize := LWpaReadWriteSizeT new: buffer size.
	isStarted := true
]

{ #category : #configuration }
LWpaControl >> startRecording [
	isRecording := true
]

{ #category : #private }
LWpaControl >> stop [ 
	[ self teardownForSystem ]
	ensure: [
		isStarted := nil.
		attachedBlock := nil ]
]

{ #category : #configuration }
LWpaControl >> stopRecording [
	isRecording := nil
]

{ #category : #private }
LWpaControl >> teardownForSystem [
	self flush.
	[ handle isNull ifFalse: [
			self isAttached
				ifTrue: [ self detachForSystem ].
			self close ] ]
	ensure: [
		handle free.
		buffer free.
		handle := nil.
		buffer := nil.
		bufferSize := nil ]
]
