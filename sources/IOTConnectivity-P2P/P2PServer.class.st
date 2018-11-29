"
I am P2Pserver, an adaption of the ZnServer for P2PDevices that do not work with sockets and ports.

I do exactly the same as a ZnSingleThreadedServer but by using a P2PDevice for its socket.

	P2Pserver startOn: aP2PDevice.
"
Class {
	#name : #P2PServer,
	#superclass : #ZnManagingMultiThreadedServer,
	#category : #'IOTConnectivity-P2P'
}

{ #category : #'not implemented' }
P2PServer class >> defaultOn: portNumber [
	"Return the default instance on a given port,
	Keep a reference to it in a class instance variable.
	If there was no previous default instance, create a new one.
	If there was a previous default instance, reuse it:
	if it was running stop it, change the port if necessary."

	^ nil
]

{ #category : #'not implemented' }
P2PServer class >> on: aNumber [
	"Instantiate and return a new listener on a given port,
	send #start to it to start listening."

	^ nil
]

{ #category : #public }
P2PServer class >> onDevice: aP2PDevice [
	"Instantiate and return a new listener on a given port,
	send #start to it to start listening."

	^ self new 
		device: aP2PDevice; 
		yourself
]

{ #category : #'not implemented' }
P2PServer class >> startDefaultOn: portNumber [
	"Start and return the default instance on a given port.
	Keep a reference to it in a class instance variable.
	If there was no previous default instance, create a new one.
	If there was a previous default instance, reuse it:
	if it was running stop and start it, effectively restarting it.
	Change the port if necessary.
	Starting the default server will register it automatically."

	^ nil
]

{ #category : #'not implemented' }
P2PServer class >> startOn: portNumber [
	"Instanciate and return a new listener on a given port and start listening."

	^ nil
]

{ #category : #public }
P2PServer class >> startOnDevice: aP2PDevice [
	"Instanciate and return a new listener on a given device and start listening."
	
	^ (self onDevice: aP2PDevice)
		start;
		yourself
]

{ #category : #'not implemented' }
P2PServer >> bindingAddress [
	"Return the interface address we are (or will be) listening on.
	Nil means that we are (or will be) listening on all/any interfaces."
	
	^ nil
]

{ #category : #'not implemented' }
P2PServer >> bindingAddress: address [
	"Set the interface address we will be listening on.
	Specify nil to listen on all/any interfaces, the default.
	Address must be a 4 element ByteArray, like #[127 0 0 1].
	Cannot be changed after the server is already running."
]

{ #category : #accessing }
P2PServer >> device [
	"Return the device we will be listening on."
	^ self optionAt: #device ifAbsent: [ nil ]
]

{ #category : #private }
P2PServer >> device: aP2PDevice [
	"set the p2p device that shall be used for this server"
	self optionAt: #device put: aP2PDevice
]

{ #category : #private }
P2PServer >> initializeServerSocket [
	"Set up a new server socket and listen on it"
	
	serverSocket := self device
		ifNil: [ self logServerSocketMissingDevice: 'Device was not defined for this server!' ]
		ifNotNil: [ :device |
			device openSocket.
			self logServerSocketBound ].
]

{ #category : #logging }
P2PServer >> logServerSocketMissingDevice: subject [
	logLevel < 1 ifTrue: [ ^ nil ].
	^ self logServerGeneric: subject
]

{ #category : #'instance creation' }
P2PServer >> on: aP2PDevice [
	"Instantiate and return a new listener on the given p2pdevice,
	send #start to it to start listening."
	^ self new 
		device: aP2PDevice; 
		yourself
]

{ #category : #'not implemented' }
P2PServer >> port [
	"Return the integer port number we are (or will be) listening on"
	
	^ 0
]

{ #category : #'not implemented' }
P2PServer >> port: integer [
	"Set the port number we will be listening on.
	Cannot be changed after the server is already running." 
]

{ #category : #'not implemented' }
P2PServer >> route [
	"Return the route of the server.
	This is a short identification string to be appended at the end of server session ids, separated by a dot.
	Routes are used by load balancers and proxies to correctly implement session affiinity or stickyness.
	The default is nil, meaning that no route has to be appended."
	
	^ nil
]

{ #category : #'not implemented' }
P2PServer >> route: object [
	"Set the route of the server.
	This is a short identification string to be appended at the end of server session ids, separated by a dot.
	Routes are used by load balancers and proxies to correctly implement session affiinity or stickyness.
	The default is nil, meaning that no route has to be appended."
]

{ #category : #'not implemented' }
P2PServer >> serverUrl [
	"Return the explicitely set external server URL, if any. Defaults to nil."
	
	^ nil
]

{ #category : #'not implemented' }
P2PServer >> serverUrl: urlObject [
	"Set the explicit external server URL to urlObject. Defaults to nil.
	urlObject should be a ZnUrl or a String that parses correctly to one.
	See also #url."
]

{ #category : #public }
P2PServer >> startDefaultOn: portNumber [
	"Start and return the default instance on a given port.
	Keep a reference to it in a class instance variable.
	If there was no previous default instance, create a new one.
	If there was a previous default instance, reuse it:
	if it was running stop and start it, effectively restarting it.
	Change the port if necessary.
	Starting the default server will register it automatically."

	^ nil
]

{ #category : #public }
P2PServer >> startOn: aP2PDevice [
	"Instanciate and return a new listener on a given port and start listening.
	Delegate to the default server class."

	^ (self on: aP2PDevice)
		start;
		yourself.
		
]
