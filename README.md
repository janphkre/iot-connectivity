# Setting up dependencies on the Raspberry Pi:

```
Metacello new
    repository: 'github://zweidenker/JSONSchema/source';
    baseline: #JSONSchema;
    load.
Metacello new
    repository: 'github://zweidenker/OpenAPI/source';
    baseline: #OpenAPI;
    load.

Gofer new
    squeaksource: 'MetacelloRepository';
    package: 'ConfigurationOfOSProcess';
    load.

((Smalltalk at: #ConfigurationOfOSProcess) project version: #stable) load.
```
