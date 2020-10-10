FROM elixir:1.10

ARG uid
ARG workdir=/ex-cypher

RUN adduser --uid $uid --gecos "" --disabled-password ex-cypher \
    && apt-get update \
    && apt-get install -y inotify-tools

USER $uid
WORKDIR $workdir

RUN mix local.hex --force

CMD /bin/bash
