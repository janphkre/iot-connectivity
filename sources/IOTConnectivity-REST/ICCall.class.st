Class {
	#name : #ICCall,
	#superclass : #ZnRestCall,
	#category : #'IOTConnectivity-REST-Calls'
}

{ #category : #accessing }
ICCall class >> description [
	^ ''
]

{ #category : #accessing }
ICCall class >> httpMethods [
	^ #( get )
]

{ #category : #printing }
ICCall class >> implementedMethods [
	^ self httpMethods select: [ :method | self includesSelector: method asSymbol ]
]

{ #category : #testing }
ICCall class >> isAbstract [
	^ self = ICCall
]

{ #category : #public }
ICCall class >> match: request [
	| callPath requestPath |
	requestPath := $/ split: request uri path.
	callPath := $/ split: self path allButFirst.
	(requestPath size = callPath size) ifFalse: [ 
		^ false ].
	requestPath with: callPath do: [ :requestPathSegment : callPathSegment |
		(callPathSegment first = ${)
			ifFalse: [ 
				(callPathSegment  = requestPathSegment )
					ifFalse: [ ^ false ] ] ].
	^ true
	
]

{ #category : #accessing }
ICCall class >> objectsForPragmas: aCollection [
	^ aCollection
		collect: [:each | each method valueWithReceiver: self arguments: #() ]
]

{ #category : #accessing }
ICCall class >> openApiPragmasNamed: aSymbol [
	^ Pragma 
		allNamed: aSymbol
		from: self class 
		to: ICCall class.
]

{ #category : #accessing }
ICCall class >> operationForMethod: aString [ 
	^ self pathItem perform: aString asSymbol.
]

{ #category : #accessing }
ICCall class >> parametersForMethod: aSymbol [
	^ self objectsForPragmas: ( self pragmas: #openApiParameter: includingMethod: aSymbol )
]

{ #category : #accessing }
ICCall class >> pathItem [
	| item |
	item := OAPathItem new.
	self implementedMethods do: [ :method |
		(item operationAt: method)
			summary: self summary;
			description: self description;
			parameters: (self parametersForMethod: method);
			requestBody: (self requestBodyForMethod: method ) ].
	^ item

]

{ #category : #accessing }
ICCall class >> pragmas: pragmaName includingMethod: aSymbol [
	^ (self openApiPragmasNamed: pragmaName) 
		select: [ :each | 
			each arguments first includesAny: { aSymbol . #common } ]
]

{ #category : #accessing }
ICCall class >> requestBody [
	^ OARequestBody new
]

{ #category : #accessing }
ICCall class >> requestBodyForMethod: aSymbol [

	| body pragmas |
	pragmas := (self pragmas: #openApiRequestBody:contentType: includingMethod: aSymbol)
		ifEmpty: [ ^ nil ].
	
	body := self requestBody.
	pragmas do: [ :pragma | | mediaObject |
		mediaObject := pragma method valueWithReceiver: self arguments: #().
		pragma arguments second do: [ :contentType | 
			body
				contentAt: contentType 
				put: mediaObject ] ].
	^ body
]

{ #category : #accessing }
ICCall class >> summary [
	^ ''
]

{ #category : #'instance creation' }
ICCall >> badRequest: message [
	response := self delegate 
		errorResponse: request 
		code: 400 
		message: message
]

{ #category : #public }
ICCall >> created: uri [
	^ (response := ZnResponse new)
		statusLine: ZnStatusLine created;
		headers: ZnHeaders defaultResponseHeaders;
		setLocation: uri;
		yourself
]

{ #category : #private }
ICCall >> errorEntityFor: anError [
	^ ZnEntity 
		with:(NeoJSONWriter toStringPretty: anError)
		type: ZnMimeType applicationJson setCharSetUTF8
]

{ #category : #private }
ICCall >> errorResponseFor: anError [
	^ ZnResponse statusLine: ZnStatusLine badRequest
]

{ #category : #public }
ICCall >> execute [
	"execution of the api call"
	^ (self respondsTo: self method)	
		ifTrue: [ 
			[ 
			self preProcess.
			self perform: self method.
			self postProcess. 
			response]
				on: OAError 
				do: [ :err | self handleError: err ] ] 
		ifFalse: [ self delegate wrongMethod: request ]  
]

{ #category : #'instance creation' }
ICCall >> fromJson: aString [
	^ self delegate fromJson: aString
]

{ #category : #private }
ICCall >> handleError: anError [

	^ (self errorResponseFor: anError) 
		entity: (self errorEntityFor: anError)
		yourself
]

{ #category : #initialization }
ICCall >> initializeParameters [
	| operation |
	operation := self class operationForMethod: request method asLowercase.
	operation 
		initializeValuesOn: self valueDelegate
		fromRequest: self
]

{ #category : #accessing }
ICCall >> jsonRequest [
	^ (self request contentType matches: ZnMimeType applicationJson)
		ifTrue: [
			self fromJson: self request contents ]
		ifFalse: [
			self error: 'JSON content expected' ]
]

{ #category : #accessing }
ICCall >> postProcess [
	
]

{ #category : #accessing }
ICCall >> preProcess [
	self initializeParameters 
]

{ #category : #accessing }
ICCall >> requestBody [
	^ OARequestBody new
]

{ #category : #accessing }
ICCall >> requestBodyForMethod: aSymbol [

	| body pragmas |
	pragmas := (self pragmas: #openApiRequestBody:contentType: includingMethod: aSymbol)
		ifEmpty: [ ^ nil ].
	
	body := self requestBody.
	pragmas do: [ :pragma | | mediaObject |
		mediaObject := pragma method valueWithReceiver: self arguments: #().
		pragma arguments second do: [ :contentType | 
			body
				contentAt: contentType 
				put: mediaObject ] ].
	^ body
]

{ #category : #accessing }
ICCall >> summary [
	^ ''
]

{ #category : #accessing }
ICCall >> valueDelegate [
	^ self 
]
