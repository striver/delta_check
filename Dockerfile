FROM elixir:1.14.3
RUN apt-get update
RUN apt-get install -y inotify-tools
RUN echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get -y install postgresql-client-15
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mkdir -p /elixir
WORKDIR /elixir
COPY . /elixir
