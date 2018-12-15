Extension { #name : #ExternalData }

{ #category : #'*LibWpa' }
ExternalData >> fromCString: length [
	"Convert a (not-null terminated) c string to a small talk string."
	| stream index char |
	type isPointerType ifFalse: [self error: 'External object is not a pointer type.'].
	stream := WriteStream on: String new.
	index := 1.
	[ index <= length ] whileTrue: [
		char := handle unsignedCharAt: index.
		stream nextPut: char.
		index := index + 1].
	^stream contents
]
