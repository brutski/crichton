# @title Roadmap

## Overview

Perform the following tasks to add hypermedia functionality to your services. 

1. Integrate Representors gem.
2. Apply conditions to embedded resources.
3. Apply conditions to resource descriptors by state to auto-configure their presence in a response.
4. Hook into Rails routes functionality.
5. Scaffold applications.
6. Scaffold tests.
7. Generate Hypermedia human-readable contracts for resources.
8. Generate state-machine diagrams.

## Design Goals<a name"design-goals"></a>
An [API Descriptor Document](api_descriptor_documents) serves several purposes, including defining the 
following items. The items are described.

- Protocol and media-type independent semantics of resources.
 - Delineates semantic data (properties and, optionally, embedded resources), semantic links, and transition controls 
  (links and forms).
 - Facilitates generating machine-to-machine readable ALPS profiles in XML and JSON.
 - Facilitates generating service responses for media-types.
- States and associated state transitions to facilitate generating responses that include complete state 
information.
 - References semantic definitions of transitions.
 - Supports business logic that limits the available transitions in a response.
 - Supports diagramming state machines and registering resources and their relationships as a state-machine graph.
- Protocol-specific idioms associated with a resource.
 - Includes idioms such as HTTP methods, headers, and status codes. 
 - Facilitates generating form controls that are protocol-dependent.
- Documentation-related descriptions and references for generating human-readable documentation.
 - Includes sample data values for generating sample representations in supported media-types.
 - Includes protocol-specific documentation.
- Routing metadata to generate routes and scaffold models and controllers.
- Testing metadata to facilitate testing service or external resource dependencies:
 - Factory generation of mock resources for testing.
 - Services self-testing resources.
 
Future evolution of the library and refinements of descriptor document elements will support this functionality.

[_API Descriptor Document_]: api_descriptor_documents.md
