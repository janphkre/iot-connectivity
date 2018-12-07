Class {
	#name : #IOTConnectivityCall,
	#superclass : #ZnRestCall,
	#category : 'IOTConnectivity-REST'
}

{ #category : #accessing }
IOTConnectivityCall class >> description [
	^ ''
]

{ #category : #'as yet unclassified' }
IOTConnectivityCall class >> httpMethods [
	^ #( get update )
]

{ #category : #printing }
IOTConnectivityCall class >> implementedMethods [
	^ self httpMethods select: [ :method | self includesSelector: method asSymbol ]
]

{ #category : #testing }
IOTConnectivityCall class >> isAbstract [
	^ self = IOTConnectivityCall
]

{ #category : #public }
IOTConnectivityCall class >> match: request [
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

{ #category : #'as yet unclassified' }
IOTConnectivityCall class >> objectsForPragmas: aCollection [
	^ aCollection
		collect: [:each | each method valueWithReceiver: self arguments: #() ]
]

{ #category : #'as yet unclassified' }
IOTConnectivityCall class >> openApiPragmasNamed: aSymbol [
	^ Pragma 
		allNamed: aSymbol
		from: self class 
		to: IOTConnectivityCall class.
]

{ #category : #'as yet unclassified' }
IOTConnectivityCall class >> operationForMethod: aString [ 
	^ self pathItem perform: aString asSymbol.
]

{ #category : #'as yet unclassified' }
IOTConnectivityCall class >> parametersForMethod: aSymbol [
	^ self objectsForPragmas: ( self pragmas: #openApiParameter: includingMethod: aSymbol )
]

{ #category : #accessing }
IOTConnectivityCall class >> pathItem [
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

{ #category : #'as yet unclassified' }
IOTConnectivityCall class >> pragmas: pragmaName includingMethod: aSymbol [
	^ (self openApiPragmasNamed: pragmaName) 
		select: [ :each | 
			each arguments first includesAny: { aSymbol . #common } ]
]

{ #category : #accessing }
IOTConnectivityCall class >> requestBody [
	^ OARequestBody new
]

{ #category : #'as yet unclassified' }
IOTConnectivityCall class >> requestBodyForMethod: aSymbol [

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
IOTConnectivityCall class >> summary [
	^ ''
]

{ #category : #private }
IOTConnectivityCall >> errorEntityFor: anError [
	^ ZnEntity 
		with:(NeoJSONWriter toStringPretty: anError)
		type: ZnMimeType applicationJson setCharSetUTF8
]

{ #category : #private }
IOTConnectivityCall >> errorResponseFor: anError [
	^ ZnResponse statusLine: ZnStatusLine badRequest
]

{ #category : #public }
IOTConnectivityCall >> execute [
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

{ #category : #private }
IOTConnectivityCall >> handleError: anError [

	^ (self errorResponseFor: anError) 
		entity: (self errorEntityFor: anError)
		yourself
]

{ #category : #initialization }
IOTConnectivityCall >> initializeParameters [
	| operation |
	operation := self class operationForMethod: request method asLowercase.
	operation 
		initializeValuesOn: self valueDelegate
		fromRequest: self
]

{ #category : #'as yet unclassified' }
IOTConnectivityCall >> postProcess [
	
]

{ #category : #'as yet unclassified' }
IOTConnectivityCall >> preProcess [
	self initializeParameters 
]

{ #category : #accessing }
IOTConnectivityCall >> requestBody [
	^ OARequestBody new
]

{ #category : #'as yet unclassified' }
IOTConnectivityCall >> requestBodyForMethod: aSymbol [

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
IOTConnectivityCall >> summary [
	^ ''
]

{ #category : #accessing }
IOTConnectivityCall >> valueDelegate [
	^ self 
]
