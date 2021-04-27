# Docker Endpoint for DRILL

Part of RAKI D6.1

To Build using your Private SSH Key `~/.ssh/id_rsa`,

```
docker build --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)" "."
```

Documentation for the Endpoint can be found on:

https://github.com/dice-group/RAKI-D5.1

Quick start:

```sh
CONTAINER=172.17.0.2:9080
```

* Check if system running:
  (requires [curl](https://curl.se/))

  ```sh
  curl http://$CONTAINER/status
  ```
  
  response: (JSON)
  > ```json
  > {"status":"ready"}
  > ```
  
* Submit Learning task:

  unzip some example learning problems:
  ```sh
  unzip LPs
  ```
 
  pick one of the example learning problems and submit it to the system:
  (requires [jq](https://stedolan.github.io/jq/))
  ```sh
  jq '
     .problems
       ."((pathwayStep ⊓ (∀INTERACTION-TYPE.Thing)) ⊔ (sequenceInterval ⊓ (∀ID-VERSION.Thing)))"
     | {
        "positives": .positive_examples,
        "negatives": .negative_examples
       }' LPs/Biopax/lp.json \
		   | curl -d@- http://$CONTAINER/concept_learning
  ```
  
  response: (OWL rdf/xml)
  > ```xml
  > <?xml version="1.0"?>
  > <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  >          xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
  >          xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
  >          xmlns:owl="http://www.w3.org/2002/07/owl#"
  >          xml:base="https://dice-research.org/predictions/1619526593.1690164"
  >          xmlns="https://dice-research.org/predictions/1619526593.1690164#">
  > 
  > <owl:Ontology rdf:about="https://dice-research.org/predictions/1619526593.1690164">
  >   <owl:imports rdf:resource="file:///OntoPy/KGs/Biopax/biopax.owl"/>
  > </owl:Ontology>
  > 
  > <owl:Class rdf:about="#Pred_0">
  >   <owl:equivalentClass rdf:resource="http://www.biopax.org/examples/glycolysis#pathwayStep"/>
  >   <rdfs:label rdf:datatype="http://www.w3.org/2001/XMLSchema#string">pathwayStep</rdfs:label>
  > </owl:Class>
  > 
  > 
  > </rdf:RDF>
  > ```
