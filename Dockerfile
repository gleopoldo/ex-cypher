FROM elixir:1.9.4

ARG uid
ARG workdir=/ex-cypher

RUN mix local.hex --force \
    && adduser --uid $uid --home $workdir --disabled-password ex-cypher
RUN apt-get update && apt-get install -y inotify-tools

USER $uid
WORKDIR $workdir

CMD /bin/bash
