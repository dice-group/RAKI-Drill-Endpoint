# Docker Endpoint for DRILL

Part of RAKI D6.1

## 1. Creating an endpoint for DRILL manually 
Here, we provide each command to create an endpoint to use [DRILL](https://arxiv.org/abs/2106.15373)
```sh
# (1) clone the repo & unzip necessary files.
git clone https://github.com/dice-group/RAKI-Drill-Endpoint && cd RAKI-Drill-Endpoint 
unzip embeddings.zip && unzip LPs.zip && unzip pre_trained_agents.zip
# (2) clone the ontolearn repo
git clone https://github.com/dice-group/Ontolearn.git && cd Ontolearn && git checkout bf2f94f56bf4508b53a540b5e580a59d73689ccb 
# (3) Create an anaconda virtual environment and install dependencies.
conda create --name temp python=3.8  && conda activate temp
pip install -e . && cd ..
# (4) Execute python script to create flask based endpoint.
python Ontolearn/examples/simple_drill_endpoint.py --path_knowledge_base 'Ontolearn/KGs/Biopax/biopax.owl' --path_knowledge_base_embeddings 'embeddings/ConEx_Biopax/ConEx_entity_embeddings.csv' --pretrained_drill_avg_path 'pre_trained_agents/Biopax/DrillHeuristic_averaging/DrillHeuristic_averaging.pth'
#...
# Running on http://0.0.0.0:9080/ # Copy this address
```
### How to use the endpoint  
pick one of the example learning problems and submit it to the system: (requires [jq](https://stedolan.github.io/jq/))
```sh
# (1) Open a new terminal (Ctrl+Alt+T on ubuntu) to verify the endpoint.
curl http://0.0.0.0:9080/status # => {"status":"ready"} # If you see this  all went well :)
# (2) Use an example learning problem
jq '
     .problems
       ."((pathwayStep ⊓ (∀INTERACTION-TYPE.Thing)) ⊔ (sequenceInterval ⊓ (∀ID-VERSION.Thing)))"
     | {
        "positives": .positive_examples,
        "negatives": .negative_examples
       }' LPs/Biopax/lp.json \
		   | curl -d@- http://0.0.0.0:9080/concept_learning
```

## 2. Creating an endpoint for DRILL via Docker
```sh
git clone https://github.com/dice-group/RAKI-Drill-Endpoint && cd RAKI-Drill-Endpoint 
unzip LPs # unzip learning problems file to use it later on
sudo docker build -t drill:latest "." 
# Successfully tagged drill:latest # if you see **done**, all went well
sudo docker images # to see installed image
```

Run the docker image.
```
sudo docker run drill
# expected to see 
# Running on http://172.17.0.2:9080/
```
### How to use the endpoint  
pick one of the example learning problems and submit it to the system: (requires [jq](https://stedolan.github.io/jq/))
  ```sh
# (1) Open a new terminal (Ctrl+Alt+T on ubuntu) to verify the endpoint.
curl http://172.17.0.2:9080/status
{"status":"ready"} # If you see this  all went well :)
# (2) Use an example learning problem
jq '
     .problems
       ."((pathwayStep ⊓ (∀INTERACTION-TYPE.Thing)) ⊔ (sequenceInterval ⊓ (∀ID-VERSION.Thing)))"
     | {
        "positives": .positive_examples,
        "negatives": .negative_examples
       }' LPs/Biopax/lp.json \
		   | curl -d@- http://172.17.0.2:9080/concept_learning
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
Congrats!

## Contact
For any questions, please contact:  ```caglar.demir@upb.de``` / ```caglardemir8@gmail.com```