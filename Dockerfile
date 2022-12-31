################################################################################
# STEP 1 - Docker image stage for building the release
ARG ELIXIR_VERSION=1.14.2
ARG OTP_VERSION=25.1.2
ARG DEBIAN_VERSION=bullseye-20221004-slim
ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

ARG MIX_ENV="prod"

FROM ${BUILDER_IMAGE}  AS builder

# Install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Sets work directory
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

ARG MIX_ENV
ENV MIX_ENV="${MIX_ENV}"

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only ${MIX_ENV}

# Copy compile configuration files
RUN mkdir config
COPY config/config.exs config/$MIX_ENV.exs config/

# Compile dependencies
RUN mix deps.compile

COPY priv priv

# Copy assets
# note: if your project uses a tool like https://purgecss.com/,
# which customizes asset compilation based on what it finds in
# your Elixir templates, you will need to move the asset compilation
# step down so that `lib` is available.
COPY assets assets

# Compile project
COPY lib lib

# IMPORTANT: Make sure asset compilation is after copying lib
# Compile assets
RUN mix assets.deploy

RUN mix compile

# Copy runtime configuration file
COPY config/runtime.exs config/

# Assemble release
COPY rel rel
RUN mix release

################################################################################
# STEP 2 - Docker image stage for running the release
# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

ARG MIX_ENV
ENV MIX_ENV="${MIX_ENV}"

RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV USER="manju"

WORKDIR "/home/${USER}/app"

# Create unprivileged user to run the release
RUN \
addgroup --system "${USER}" \
&& adduser --system ${USER}

# run as user
USER "${USER}"

# copy release executable
COPY --from=builder --chown="${USER}":"${USER}" /app/_build/"${MIX_ENV}"/rel/docker_phoenix_tailwind ./

ENTRYPOINT ["bin/docker_phoenix_tailwind"]

CMD ["start"]