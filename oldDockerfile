# this is our first build stage, it will not persist in the final image
# source: https://vsupalov.com/build-docker-image-clone-private-repo-ssh-key/
FROM ubuntu as intermediate

# install git
RUN apt-get update
RUN apt-get install -y git

RUN git clone https://github.com/dice-group/Ontolearn.git -b master

ADD pre_trained_agents.zip /Ontolearn
ADD embeddings.zip /Ontolearn

# Dockerfile start
FROM continuumio/anaconda3

RUN mkdir -p /usr/share/man/man1/
RUN apt-get update && apt-get -y install openjdk-11-jre unzip

# enable shell for conda
SHELL ["/bin/bash", "--login", "-c"]

RUN conda update -n base -c defaults conda

RUN conda init bash

RUN apt-get -y install gcc
RUN conda create -n ontolearn_env python=3.8.0
RUN conda activate ontolearn_env && conda install Cython

# copy the repository form the previous image
COPY --from=intermediate /Ontolearn /Ontolearn

WORKDIR /Ontolearn
RUN conda activate ontolearn_env && pip install -e .

RUN unzip embeddings.zip
RUN unzip pre_trained_agents.zip

WORKDIR /raki

EXPOSE 9080

CMD conda activate ontolearn_env && \
    simple_drill_endpoint \
        --path_knowledge_base /Ontolearn/KGs/Biopax/biopax.owl \
        --path_knowledge_base_embeddings /Ontolearn/embeddings/Shallom_Biopax/Shallom_entity_embeddings.csv \
        --pretrained_drill_avg_path /Ontolearn/pre_trained_agents/Biopax/DrillHeuristic_averaging/DrillHeuristic_averaging.pth
