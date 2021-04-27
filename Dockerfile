# this is our first build stage, it will not persist in the final image
# source: https://vsupalov.com/build-docker-image-clone-private-repo-ssh-key/
FROM ubuntu as intermediate

# install git
RUN apt-get update
RUN apt-get install -y git

# add credentials on build
# source: https://itnext.io/building-docker-images-from-private-git-repositories-using-ssh-login-433edf5a18f2
ARG SSH_PRIVATE_KEY
RUN eval $(ssh-agent) && \
    echo "${SSH_PRIVATE_KEY}" | ssh-add - && \
    ssh-keyscan -H github.com >> /etc/ssh/ssh_known_hosts && \
    git clone git@github.com:dice-group/OntoPy.git -b master

ADD pre_trained_agents.zip /OntoPy


# Dockerfile start
FROM continuumio/anaconda3

RUN mkdir /usr/share/man/man1/
RUN apt-get update && apt-get -y install openjdk-11-jre unzip

# enable shell for conda
SHELL ["/bin/bash", "--login", "-c"]

RUN conda update -n base -c defaults conda

RUN conda init bash

RUN apt-get -y install gcc
RUN conda create -n ontolearn_env python=3.7.1
RUN conda activate ontolearn_env && conda install Cython

# copy the repository form the previous image
COPY --from=intermediate /OntoPy /OntoPy

WORKDIR /OntoPy
RUN conda activate ontolearn_env && pip install -e .

RUN unzip embeddings.zip
RUN unzip pre_trained_agents.zip

WORKDIR /raki

EXPOSE 9080

CMD conda activate ontolearn_env && \
    simple_drill_endpoint \
        --path_knowledge_base /OntoPy/KGs/Biopax/biopax.owl \
	--path_knowledge_base_embeddings /OntoPy/embeddings/Shallom_Biopax/Shallom_entity_embeddings.csv \
	--pretrained_drill_avg_path /OntoPy/pre_trained_agents/Biopax/DrillHeuristic_averaging/DrillHeuristic_averaging.pth
