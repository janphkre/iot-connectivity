"
I am P2Pserver, an adaption of the ZnServer for P2PDevices that do not work with sockets and ports.

I do exactly the same as a ZnSingleThreadedServer but by using a P2PDevice for its socket.

	P2Pserver startOn: aP2PDevice.
"
Class {
	#name : #P2PServer,
	#superclass : #Object,
	#instVars : [
		'process',
		'sessionManager',
		'serverSocket',
		'options'
	],
	#classVars : [
		'AlwaysRestart',
		'ManagedServers'
	],
	#category : 'IOTConnectivity-P2P'
}

{ #category : #accessing }
P2PServer class >> alwaysRestart [
	^ AlwaysRestart ifNil: [ AlwaysRestart := true ]
]

{ #category : #accessing }
P2PServer class >> alwaysRestart: boolean [
	"Set if managed servers should always restart on image save, as opposed to only when quiting."

	^ AlwaysRestart := boolean
]

{ #category : #'class initialization' }
P2PServer class >> initialize [
	ManagedServers := IdentitySet new.
	AlwaysRestart := true.
	self environment 
		at: #SessionManager 
		ifPresent: [ :manager | manager default registerNetworkClassNamed: self name ]
		ifAbsent: [ Smalltalk addToStartUpList: self; addToShutDownList: self ]
	
]

{ #category : #accessing }
P2PServer class >> managedServers [
	^ ManagedServers ifNil: [ ManagedServers := IdentitySet new ]
]

{ #category : #'instance creation' }
P2PServer class >> on: aP2PDevice [
	"Instantiate and return a new listener on the given p2pdevice,
	send #start to it to start listening."
	^ self new 
		device: aP2PDevice; 
		yourself
]

{ #category : #accessing }
P2PServer class >> register: server [
	"Arrange for server to be sent start/stop on system startUp/shutDown"
	
	self managedServers add: server
]

{ #category : #'system startup' }
P2PServer class >> shutDown: quiting [
	"Our system shutDown hook: stop all servers we manage"
	
	(quiting or: [ self alwaysRestart ])
		ifTrue: [
			self managedServers do: [ :each | each stop: false ] ]
]

{ #category : #public }
P2PServer class >> startOn: aP2PDevice [
	"Instanciate and return a new listener on a given port and start listening.
	Delegate to the default server class."

	^ (self on: aP2PDevice)
		start;
		yourself.
		
]

{ #category : #'system startup' }
P2PServer class >> startUp: resuming [
	"Our system startUp hook: start all servers we manage.
	We do this using deferred startup actions to allow normal error handling."

	(resuming or: [ self alwaysRestart ])
		ifTrue: [
			self environment 
				at: #SessionManager 
				ifPresent: [ :manager | 
					manager default currentSession addDeferredStartupAction: [ 
						self managedServers do: [ :each | each start ] ] ]
				ifAbsent: [ 
					Smalltalk addDeferredStartupAction: [ 
						self managedServers do: [ :each | each start ] ] ] ]
]

{ #category : #accessing }
P2PServer class >> unregister: server [
	"No longer send server start/stop on system startUp/shutDown"
	
	self managedServers remove: server ifAbsent: [ ]
]

{ #category : #constants }
P2PServer >> acceptWaitTimeout [
	"How many seconds to wait for a server socket listening for an accept ?"
	
	^ 300
]

{ #category : #'request handling' }
P2PServer >> augmentResponse: response forRequest: request [
	"Our handler has produced response for request, manipulate the response before writing it"
	
	(self useGzipCompressionAndChunking and: [ response contentType isBinary not ])
		ifTrue: [ 
			(request acceptsEncodingGzip and: [ response hasContentEncoding not ]) 
				ifTrue: [ response setContentEncodingGzip ].
			response hasTransferEncoding
				ifFalse: [ response setTransferEncodingChunked ] ]
]

{ #category : #'request handling' }
P2PServer >> authenticateAndDelegateRequest: request [
	"Handle request and return a response.
	If we have a delegate, pass the responsability.
	If we have no delegate, we return a page not found.
	Make sure to pass via our authenticator."

	^ self
		authenticateRequest: request
		do: [ 
			self delegate
				ifNil: [ ZnResponse notFound: request uri ]
				ifNotNil: [ :delegate | delegate handleRequest: request ] ]
]

{ #category : #'request handling' }
P2PServer >> authenticateRequest: request do: block [
	"Validate request and execute block.
	When our authenticator is not nil, pass the responsability"

	^ self authenticator
		ifNil: [ block value ]
		ifNotNil: [ :authenticator | authenticator authenticateRequest: request do: block ]
]

{ #category : #options }
P2PServer >> authenticator [
	"Return the optional authenticator,
	the object that will be sent #authenticateRequest:do:
	to authenticate or refuse the requests. 
	When authentication succeeds, the block should be executed,
	when authentication fails, a appropriate response should be returned.
	If there is no authenticator, all requests will pass"
	
	^ self optionAt: #authenticator ifAbsent: [ nil ]
]

{ #category : #options }
P2PServer >> authenticator: object [
	"Set the object that will be sent #authenticateRequest:do:
	to authenticate or refuse the requests. Can be nil.
	When authentication succeeds, the block should be executed,
	when authentication fails, a appropriate response should be returned"

	self optionAt: #authenticator put: object
]

{ #category : #private }
P2PServer >> closeDelegate [
	self delegate
		ifNotNil: [ :delegate | 
			(delegate respondsTo: #close)
				ifTrue: [ delegate close ] ]
]

{ #category : #options }
P2PServer >> debugMode [
	"Return whether we are in debug mode, the default is false."
	
	^ self optionAt: #debugMode ifAbsent: [ false ] 
]

{ #category : #options }
P2PServer >> debugMode: boolean [
	"Set my debug mode, the default being false.
	In debug mode, Smalltalk Error during #handleRequest: will raise a Debugger.
	When not in debug mode, a Smalltalk Error during #handleRequest: will result in an HTTP Server Error response."
	
	^ self optionAt: #debugMode put: boolean
]

{ #category : #options }
P2PServer >> defaultEncoder [
	"The default character encoder to use when none is set in a mime-type"
	
	^ self optionAt: #defaultEncoder ifAbsent: [ ZnDefaultCharacterEncoder value ] 
]

{ #category : #options }
P2PServer >> defaultEncoder: encoder [
	"Set the default character encoder to use when none is set in a mime-type"
	
	^ self optionAt: #defaultEncoder put: encoder asZnCharacterEncoder
]

{ #category : #options }
P2PServer >> delegate [
	"Return the optional delegate, 
	the object that will be sent #handleRequest: to handle a request and produce a response.
	The default delegate is ZnDefaultServerDelegate"
	
	^ self optionAt: #delegate ifAbsentPut: [ ZnDefaultServerDelegate new ]
]

{ #category : #options }
P2PServer >> delegate: object [
	"Set the delegate to object. Can be nil.
	This will be sent #handleRequest: to handle a request and produce a response"
	
	self optionAt: #delegate put: object
]

{ #category : #'request handling' }
P2PServer >> executeOneRequestResponseOn: stream [
	"Execute one single HTTP request / response cycle on stream in 3 steps:
	#readRequest: #handleRequest: and #writeResponse:on:
	Indicate that we intend to close the connection afterwards"

	| request response timing|
	ZnCurrentServer
		value: self
		during: [ 
			timing := ZnServerTransactionTiming new.
			request := self readRequest: stream timing: timing.
			response := self handleRequest: request timing: timing.
			response setConnectionClose.
			self writeResponse: response on: stream timing: timing ]
]

{ #category : #'request handling' }
P2PServer >> handleRequest: request timing: timing [
	"Handle request and return a response.
	Do logging and timing. Set a dynamic variable referencing the server.
	If necessary do session management in the response."

	| response initialMilliseconds |
	initialMilliseconds := Time millisecondClockValue.
	ZnCurrentServerSession value: nil.
	response := self handleRequestProtected: request.
	request method = #HEAD
		ifTrue: [ response clearEntity ].
	timing handlerDuration: (self logRequest: request response: response handledStarted: initialMilliseconds).
	ZnCurrentServerSession value 
		ifNotNil: [ :session | self sessionManager setSession: session in: response ].
	^ response
]

{ #category : #'request handling' }
P2PServer >> handleRequestProtected: request [
	"Handle request and return a response.
	If a ZnRespond notification is signaled, return its response directly.
	If an Error is thrown, return a HTTP Server Error response."

	^ [ [ self authenticateAndDelegateRequest: request ]
			on: ZnRespond 
			do: [ :notification | notification response ] ]
		on: Error
		do: [ :exception | 
			self debugMode
				ifTrue: [ exception pass ]
				ifFalse: [
					self logServerHandlerError: exception.
					ZnResponse serverError: exception printString ] ]
]

{ #category : #private }
P2PServer >> initializeServerSocket [
	"Set up a new server socket and listen on it"
	
	serverSocket := self bindingAddress
		ifNil: [ ZnNetworkingUtils serverSocketOn: self port ]
		ifNotNil: [ ZnNetworkingUtils serverSocketOn: self port interface: self bindingAddress ].
	"Binding a server socket to port 0 means letting the OS assign a port, fetch it"
	self port isZero 
		ifTrue: [ self optionAt: #port put: serverSocket port ].
	self logServerSocketBound
]

{ #category : #testing }
P2PServer >> isListening [
	"Return true when I have a valid server socket listening at the correct port"
	
	^ self serverSocket notNil
		and: [ self serverSocket isValid and: [ self serverSocket localPort = self port ] ]
]

{ #category : #testing }
P2PServer >> isRunning [
	"Return true when I am running"
	
	^ self process notNil and: [ self serverSocket notNil ]
]

{ #category : #'request handling' }
P2PServer >> listenLoop [
	"We create a listening Socket, then wait for a connection.
	After each connection we also check that the listening Socket is still valid 
	- if not we just make a recursive call to this method to start over."

	self initializeServerSocket.
	[ [ 
		serverSocket isValid
			 ifFalse: [
				"will trigger #ifCurtailed: block and destroy socket"
				^ self listenLoop ].
		self serveConnectionOn: serverSocket ] repeat ]

		ifCurtailed: [ self releaseServerSocket ]
]

{ #category : #private }
P2PServer >> noteAcceptWaitTimedOut [
	"The accept wait on a server socket timed out (see #acceptWaitTimeout).
	This can be used as an opportunity to do some periodic tasks."
	
	self periodicTasks
]

{ #category : #accessing }
P2PServer >> onRequestRespond: block [
	"Convenience method to quickly set up a delegate.
	On any incoming request, block will be executed with the request 
	as argument to produce a valid response."
	
	self delegate: (ZnValueDelegate with: block)  
]

{ #category : #accessing }
P2PServer >> optionAt: key ifAbsent: block [
	"Return my option/settings stored under key.
	Execute block if I have no such option/setting.
	This is a generic interface, see my options protocol for specific usages."

	options ifNil: [ ^ block value ].
	^ options at: key ifAbsent: block
]

{ #category : #accessing }
P2PServer >> optionAt: key ifAbsentPut: block [
	"Return my option/settings stored under key.
	If I have no such option/setting, store the result of evaluating block as new value and return it.
	This is a generic interface, see my options protocol for specific usages."

	^ options at: key ifAbsentPut: block
]

{ #category : #accessing }
P2PServer >> optionAt: key put: value [
	"Set my option/setting identified by key to be value.
	This is a generic interface, see my options protocol for specific usages."
	
	options ifNil: [ options := Dictionary new ].
	options at: key put: value
]

{ #category : #private }
P2PServer >> periodicTasks [
	"Every #acceptWaitTimeout seconds this method is called.
	Note that during this time the server is not actively listening for connections."
	
	sessionManager ifNotNil: [ sessionManager cleanupInvalidSessions ]
]

{ #category : #accessing }
P2PServer >> process [
	"Return the process that is running my main listening loop.
	Will be nil when I am not running"
	
	^ process
]

{ #category : #'request handling' }
P2PServer >> readRequest: stream timing: timing [
	"Read a request from stream.
	We add a virtual header containing the remote IP address of the client"

	| request initialMilliseconds |
	initialMilliseconds := Time millisecondClockValue.
	request := self withMaximumEntitySizeDo: [ 
		self withMaximumNumberOfDictionaryEntriesDo: [ 
			self withDefaultCharacterEncoderDo: [
				self reader value: stream ] ] ].
	request headers 
		at: ZnConstants remoteAddressHeader
		put: (ZnNetworkingUtils ipAddressToString: stream socket remoteAddress).
	timing requestDuration:  (self logRequestRead: request started: initialMilliseconds).
	^ request
]

{ #category : #options }
P2PServer >> reader [
	"Return a block that when given a stream reads an entity from it."
	
	^ self optionAt: #reader ifAbsentPut: [ [ :stream | ZnRequest readFrom: stream ] ]
]

{ #category : #options }
P2PServer >> reader: block [
	"Customize how entities are read from a stream, see #reader"
	
	self optionAt: #reader put: block
]

{ #category : #registry }
P2PServer >> register [
	"Ask for start/stop to be sent to me on System startUp/shutDown"
	
	self class register: self
]

{ #category : #private }
P2PServer >> releaseServerSocket [
	"Release our server socket"
	
	| address port |
	serverSocket ifNil: [ ^ self ].
	address := [ serverSocket address ] on: Error do: [ nil ].
	port := [ serverSocket port ]on: Error do: [ nil ].
	(Delay forMilliseconds: 10) wait.
	serverSocket destroy.
	serverSocket := nil.
]

{ #category : #constants }
P2PServer >> scheme [
	^ #http
]

{ #category : #'request handling' }
P2PServer >> serveConnectionOn: listeningSocket [
	"We wait up to acceptWaitTimeout seconds for an incoming connection.
	If we get one we wrap it in a SocketStream and #executeOneRequestResponseOn: on it.
	We do not fork a worker thread/process but stay in the current one for just one request/response cycle."

	| stream socket |
	socket := listeningSocket waitForAcceptFor: self acceptWaitTimeout.
	socket ifNil: [ ^ self noteAcceptWaitTimedOut ].
	stream := self socketStreamOn: socket.
	[ 
	[ self executeOneRequestResponseOn: stream ]
		ensure: [ 
			self logConnectionClosed: stream.
			stream close ] ]
		ifCurtailed: [ 
			socket destroy ]
]

{ #category : #private }
P2PServer >> serverProcessName [
	^ String streamContents: [ :stream |
		stream nextPutAll: self class name; nextPutAll: ' HTTP port '; print: self port ]
]

{ #category : #accessing }
P2PServer >> sessionFor: request [
	"Bind an existing session to request or create a new session"
	
	^ self sessionManager sessionFor: request
]

{ #category : #accessing }
P2PServer >> sessionManager [
	"Return my session manager"

	^ sessionManager ifNil: [ sessionManager := ZnServerSessionManager new ]
]

{ #category : #public }
P2PServer >> start [
	"Start me. I will start listening on my port for incoming HTTP connections.
	If I am running, I will first stop and thus effectively restart"
	
	self stop: false.
	self class default = self ifTrue: [ self register ].
	process := [ [ self listenLoop ] repeat ]
		forkAt: Processor highIOPriority 
		named: self serverProcessName.
	self logStarted.

]

{ #category : #public }
P2PServer >> stop [
	"Stop me. I will stop listening on my port for incoming HTTP connections.
	Does nothing when I am not running"
	
	self stop: true 
]

{ #category : #public }
P2PServer >> stop: unregister [
	"Stop me. I will stop listening on my port for incoming HTTP connections.
	If unregister is true, unregister me from the list of managed instances.
	Does nothing when I am not running"
	
	self isRunning ifFalse: [ ^ self ].
	process terminate. 
	process := nil.
	unregister ifTrue: [ self unregister ].
	self closeDelegate.
	self logStopped
]

{ #category : #registry }
P2PServer >> unregister [
	"Ask for start/stop to no longer be sent to me on System startUp/shutDown"

	self class unregister: self
]

{ #category : #options }
P2PServer >> useGzipCompressionAndChunking [
	"Return whether we should try to use gzip content encoding and chunked transfer encoding, the default is false."
	
	^ self optionAt: #useGzipCompressionAndChunking ifAbsent: [ false ] 
]

{ #category : #options }
P2PServer >> useGzipCompressionAndChunking: boolean [
	"Set whether we should try to use gzip content encoding and chunked transfer encoding, the default being false."
	
	self optionAt: #useGzipCompressionAndChunking put: boolean
]

{ #category : #private }
P2PServer >> withDefaultCharacterEncoderDo: block [
	^ self defaultEncoder = ZnDefaultCharacterEncoder value
			ifTrue: block
			ifFalse: [ 
				ZnDefaultCharacterEncoder 
					value: self defaultEncoder  
					during: block ]
]

{ #category : #private }
P2PServer >> withMaximumEntitySizeDo: block [
	^ self maximumEntitySize = ZnMaximumEntitySize value
			ifTrue: block
			ifFalse: [ 
				ZnMaximumEntitySize 
					value: self maximumEntitySize  
					during: block ]
]

{ #category : #private }
P2PServer >> withMaximumNumberOfDictionaryEntriesDo: block [
	^ self maximumNumberOfDictionaryEntries = ZnMaximumNumberOfDictionaryEntries value
			ifTrue: block
			ifFalse: [ 
				ZnMaximumNumberOfDictionaryEntries 
					value: self maximumNumberOfDictionaryEntries 
					during: block ]
]

{ #category : #'request handling' }
P2PServer >> writeResponse: response on: stream timing: timing [
	"Write response to stream and flush the stream"
	
	| initialMilliseconds |
	initialMilliseconds := Time millisecondClockValue.
	self withDefaultCharacterEncoderDo: [ response writeOn: stream ].
	stream flush.
	timing responseDuration: (self logResponseWritten: response started: initialMilliseconds)  
]
