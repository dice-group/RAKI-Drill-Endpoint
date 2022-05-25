# Docker Endpoint for DRILL

Part of RAKI D6.1

## 1. Creating an endpoint for DRILL manually
Here, we provide each command to create an endpoint to use [DRILL](https://arxiv.org/abs/2106.15373)
```sh
# (1) clone the repo & unzip necessary files.
git clone https://github.com/dice-group/RAKI-Drill-Endpoint && cd RAKI-Drill-Endpoint
unzip embeddings.zip && unzip LPs.zip && unzip pre_trained_agents.zip
# (2) Clone the repository and create a python virtual enviroment via anaconda
git clone https://github.com/dice-group/DRILL_RAKI && conda create -n drill_env python=3.9 && conda activate drill_env
# (3) Install requirements
cd DRILL_RAKI && unzip KGs.zip && wget --no-check-certificate --content-disposition https://github.com/dice-group/Ontolearn/archive/refs/tags/0.5.1.zip
unzip Ontolearn-0.5.1.zip && cd Ontolearn-0.5.1 && pip install -e . && cd ..
# For the Endpoint only
cd .. && pip install flask==2.1.2
# Test the installation. No error should occur.
python -c "import ontolearn"
# (4) Execute python script to create flask based endpoint.
python DRILL_RAKI/flask_end_point.py --path_knowledge_base 'DRILL_RAKI/KGs/Biopax/biopax.owl' --path_knowledge_base_embeddings 'embeddings/ConEx_Biopax/ConEx_entity_embeddings.csv' --pretrained_drill_avg_path 'pre_trained_agents/Biopax/DrillHeuristic_averaging/DrillHeuristic_averaging.pth'
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
```sh
sudo docker run \
-e KG=Biopax/biopax.owl \
-e EMBEDDINGS=ConEx_Biopax/ConEx_entity_embeddings.csv \
-e PRE_TRAINED_AGENT=Biopax/DrillHeuristic_averaging/DrillHeuristic_averaging.pth \
drill:latest
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
