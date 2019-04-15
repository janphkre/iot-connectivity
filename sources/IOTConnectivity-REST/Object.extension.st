Extension { #name : #Object }

{ #category : #'*IOTConnectivity-REST' }
Object >> asZnResponse [
  ^ ZnResponse  ok: (ZnEntity 
    with: (NeoJSONWriter toString: self)
    type: ZnMimeType applicationJson setCharSetUTF8).
]
