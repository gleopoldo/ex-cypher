FROM elixir:1.10

ARG uid
ARG workdir=/ex-cypher

RUN adduser --uid $uid --gecos "" --disabled-password ex-cypher \
    && apt-get update \
    && apt-get install -y inotify-tools


USER $uid
WORKDIR $workdir

CMD /bin/bash
