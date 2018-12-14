Class {
	#name : #LWpaWritebackString,
	#superclass : #FFIExternalValueHolder,
	#category : #'LibWpa-FFI-Objects'
}

{ #category : #accessing }
LWpaWritebackString class >> typeDecl [
	"Define the type for this value holder. 
	 It can be anything that FFIExternalType class>>resolveType: can resolve. 
	 If you need something different, you can override #representationType"
	^ 'char *'
]
