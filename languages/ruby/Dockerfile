# groupadd and useradd don't work with alpine
ARG LANGUAGE
ARG VERSION
FROM $LANGUAGE:$VERSION
ARG USER_NAME
ARG USER_UID
ARG USER_GID
RUN groupadd --gid $USER_GID $USER_NAME
RUN useradd --uid $USER_UID --gid $USER_GID $USER_NAME
RUN wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O- | apt-key add -
RUN apt update && apt install -y lsb-release && RELEASE=$(lsb_release -cs) && echo "deb http://apt.postgresql.org/pub/repos/apt/ ${RELEASE}-pgdg main" | tee /etc/apt/sources.list.d/postgresql.list
ARG ADDITIONAL_PACKAGES
RUN if [ ! -z $ADDITIONAL_PACKAGES ]; then apt update && apt install -y $ADDITIONAL_PACKAGES && apt clean all; fi