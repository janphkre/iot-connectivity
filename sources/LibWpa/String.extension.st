Extension { #name : #String }

{ #category : #'*LibWpa' }
String >> isOk [
	^ self beginsWith: 'OK'
]
