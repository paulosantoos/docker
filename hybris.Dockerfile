FROM debian:9

LABEL author="Paulo Henrique dos Santos"
LABEL maintainer="Paulo Henrique dos Santos <paulo.santos@fh.com.br>"

## Arguments 
ARG HYBRIS_VERSION="hybris-latest.zip"
ARG HYBRIS_DIR="/app/hybris"
ARG HYBRIS_USER="hybris"
ARG HYBRIS_DIR_CUSTOM=${HYBRIS_DIR}
ARG RECIPE="b2c_b2b_acc"
ARG JAVA_VERSION_FILE="java-oracle-jdk8.tar.gz"
ARG DB_DRIVER="mysql-connector-java.jar"
ARG DOCKER_HOME="/home/hybris"

## Environments
ENV HYBRIS_VERSION=${HYBRIS_VERSION}
ENV HYBRIS_DIR=${HYBRIS_DIR}
ENV HYBRIS_USER=${HYBRIS_USER}
ENV HYBRIS_DIR_CUSTOM=${HYBRIS_DIR_CUSTOM}
ENV RECIPE=${RECIPE}
ENV JAVA_VERSION_FILE=${JAVA_VERSION_FILE}
ENV DB_DRIVER=${DB_DRIVER}
ENV DEVELOPER_NAME=
ENV DEVELOPER_EMAIL=
ENV BRANCH_NAME=
ENV INITIALIZE="false"
ENV DOCKER_HOME=${DOCKER_HOME}


## Install linux packages
RUN apt-get update && apt-get install -y software-properties-common gnupg unzip lsof sudo git apt-utils nano curl
RUN apt-get update && curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -
RUN apt-get update && apt-get install -y build-essential nodejs

## Create hybris user.. home and set password
RUN mkdir -p ${DOCKER_HOME}
RUN useradd -m -d ${DOCKER_HOME} ${HYBRIS_USER} && echo "${HYBRIS_USER}    ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN chown -R ${HYBRIS_USER}:${HYBRIS_USER} ${DOCKER_HOME}
RUN mkdir -p ${DOCKER_HOME}/.ssh
RUN mkdir -p ${HYBRIS_DIR}
RUN mkdir -p /usr/lib/jvm 

## Expose Hybris ports
EXPOSE 9001
EXPOSE 9002

## Expose Solr port
EXPOSE 8983

## Copy files
COPY bashrc.txt ${DOCKER_HOME}/.bashrc
COPY bashrc.txt /root/.bashrc
COPY entrypoint.sh /entrypoint.sh
COPY hybris.sh /etc/init.d/hybris
COPY ${HYBRIS_VERSION} ${DOCKER_HOME}/${HYBRIS_VERSION}
COPY ${JAVA_VERSION_FILE} ${DOCKER_HOME}/${JAVA_VERSION_FILE}
COPY ${DB_DRIVER} ${DOCKER_HOME}

## Update file permissions
RUN chmod +x /entrypoint.sh
RUN chown ${HYBRIS_USER}:${HYBRIS_USER} /entrypoint.sh
RUN chmod +x /etc/init.d/hybris

## Setting workdir
WORKDIR ${HYBRIS_DIR}

## Change to hybris User
USER ${HYBRIS_USER}

## Set entrypoint of container
ENTRYPOINT ["/entrypoint.sh"]

CMD ["run"]