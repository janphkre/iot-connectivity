"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestLibWpa,
	#superclass : #PackageManifest,
	#category : #'LibWpa-Manifest'
}

{ #category : #'code-critics' }
ManifestLibWpa class >> ruleRBEqualsTrueRuleV1FalsePositive [
	^ #(#(#(#RGPackage #(#LibWpa)) #'2018-12-17T15:30:08.498603+01:00') )
]
