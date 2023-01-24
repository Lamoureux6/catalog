# syntax=docker/dockerfile:1.2
FROM openjdk:21-jdk-slim-bullseye as build

WORKDIR /work

COPY gradle/ gradle/
COPY gradlew .
COPY build.gradle.kts .
COPY settings.gradle.kts .
COPY src/ src/

RUN ./gradlew installDist

# 2nd stage, build the runtime image
FROM openjdk:21-jdk-slim-bullseye

WORKDIR /work

# Upgrade base image libraries to prevent security vulnerabilities
RUN apt-get --quiet update && \
    apt-get --quiet --assume-yes upgrade && \
    apt-get clean && \
    rm --recursive --force /var/lib/apt/lists/*

# Copy the binary built in the 1st stage
COPY --from=build /work/build/install/<project_name> ./

# Create default user
RUN groupadd --system docker && useradd --system --shell /bin/false --gid docker docker
RUN chown --recursive docker:docker /work
USER docker

ENTRYPOINT ["/work/bin/<project_name>"]
