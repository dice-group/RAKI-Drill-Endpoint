# this is our first build stage, it will not persist in the final image
FROM debian:11-slim as intermediate
RUN apt-get update && apt-get install -y unzip wget
WORKDIR /data

# embeddings, pre_trained_agents
ADD embeddings.zip pre_trained_agents.zip ./
RUN unzip embeddings.zip && unzip pre_trained_agents.zip

RUN wget --output-document ontolearn.zip https://github.com/dice-group/Ontolearn/archive/refs/tags/0.5.1.zip && unzip -d tmp ontolearn.zip && mv tmp/* ontolearn

# Dockerfile start
FROM continuumio/anaconda3
RUN apt-get update && apt-get install -y unzip
RUN conda create --quiet --yes --name conda_env python=3.9
WORKDIR /data

COPY --from=intermediate /data/ontolearn ./ontolearn/
RUN conda run --name conda_env pip install -e ./ontolearn/

RUN git clone --branch 0.0.2 --depth 1 https://github.com/dice-group/DRILL_RAKI && unzip DRILL_RAKI/KGs.zip

# embeddings
COPY --from=intermediate /data/embeddings ./embeddings
# pre_trained_agents
COPY --from=intermediate /data/pre_trained_agents ./pre_trained_agents

EXPOSE 9080

CMD conda run --name conda_env python DRILL_RAKI/flask_end_point.py --path_knowledge_base 'KGs/$KG' --path_knowledge_base_embeddings 'embeddings/$EMBEDDINGS' --pretrained_drill_avg_path 'pre_trained_agents/$PRE_TRAINED_AGENT'
