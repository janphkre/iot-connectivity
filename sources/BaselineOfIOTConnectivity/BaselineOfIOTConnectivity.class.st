Class {
	#name : #BaselineOfIOTConnectivity,
	#superclass : #BaselineOf,
	#category : #BaselineOfIOTConnectivity
}

{ #category : #baselines }
BaselineOfIOTConnectivity >> baseline: spec [
	<baseline>
		spec
			for: #common
			do: [
				spec
					package: 'IOTConnectivity-REST' with: [ spec requires: #('OpenAPI-Core'). ];
					package: 'IOTConnectivity-P2P' with: [ spec requires: #('ZincHTTPComponents') ].
					
				spec
					baseline: 'OpenAPI' with: [
						spec
							loads: #('REST');
							repository: 'github://zweidenker/OpenAPI/source' ];
					project: 'OpenAPI-Core' copyFrom: 'OpenAPI' with: [ 
						 spec loads: 'Core'].
				spec
					baseline: 'ZincHTTPComponents' with: [
						spec
							loads: #('REST');
							repository: 'github://zweidenker/zinc/repository' ].
				spec
					group: 'default' with: #('REST' 'P2P');
					group: 'REST' with: #('IOTConnectivity-REST');
					group: 'P2P' with: #('IOTConnectivity-P2P'). ].

]
