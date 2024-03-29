# this is our first build stage, it will not persist in the final image
FROM debian:11-slim as intermediate
RUN apt-get update && apt-get install -y unzip wget
WORKDIR /data

# embeddings, pre_trained_agents
ADD embeddings.zip pre_trained_agents.zip ./
RUN unzip embeddings.zip && unzip pre_trained_agents.zip

RUN wget --output-document ontolearn.zip https://github.com/dice-group/Ontolearn/archive/refs/tags/0.5.1.zip && unzip -d tmp ontolearn.zip && mv tmp/* ontolearn

# Dockerfile start
FROM python:3.9
WORKDIR /data

COPY --from=intermediate /data/ontolearn ./ontolearn/
RUN pip3 install Cython
RUN pip3 install -e ./ontolearn/

COPY DRILL_RAKI DRILL_RAKI
RUN unzip DRILL_RAKI/KGs.zip

# embeddings
COPY --from=intermediate /data/embeddings ./embeddings
# pre_trained_agents
COPY --from=intermediate /data/pre_trained_agents ./pre_trained_agents

COPY drill-endpoint drill-endpoint

EXPOSE 9080

CMD ./drill-endpoint
