# Docker Endpoint for DRILL

Part of RAKI D6.1

# Manuel Installation
Create a anaconda virtual environment and install dependencies.
```sh
git clone https://github.com/dice-group/RAKI-Drill-Endpoint # clone the repo.
cd RAKI-Drill-Endpoint # enter to the folder.
unzip embeddings.zip
unzip LPs.zip
unzip pre_trained_agents.zip
git clone https://github.com/dice-group/Ontolearn.git
cd Ontolearn
git checkout bf2f94f56bf4508b53a540b5e580a59d73689ccb # use this specific version
conda create --name temp python=3.8 # Proceed ([y]/n)? y 
conda activate temp
pip install -e .
cd ..
# To run endpoint
python Ontolearn/examples/simple_drill_endpoint.py --path_knowledge_base 'Ontolearn/KGs/Biopax/biopax.owl' --path_knowledge_base_embeddings 'embeddings/ConEx_Biopax/ConEx_entity_embeddings.csv' --pretrained_drill_avg_path 'pre_trained_agents/Biopax/DrillHeuristic_averaging/DrillHeuristic_averaging.pth'
# open a new terminal here 
curl http://0.0.0.0:9080/status # To test
{"status":"ready"} # Expected output
jq '
   .problems
     ."((pathwayStep ⊓ (∀INTERACTION-TYPE.Thing)) ⊔ (sequenceInterval ⊓ (∀ID-VERSION.Thing)))"
   | {
      "positives": .positive_examples,
      "negatives": .negative_examples
     }' LPs/Biopax/lp.json         | curl -d@- http://0.0.0.0:9080/concept_learning
```

To Build the Docker Endpoint for DRILL

```
docker build -t drill:latest "."
```

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
