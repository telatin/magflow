FROM mambaorg/micromamba:0.21.2
#COPY --chown=$MAMBA_USER:$MAMBA_USER microenv.yaml /tmp/env.yaml
COPY --chown=mambauser:mambauser  microenv.yaml /tmp/env.yaml
ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN micromamba install -y --file env.yaml && \
     micromamba clean --all --yes
