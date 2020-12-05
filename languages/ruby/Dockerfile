# groupadd and useradd don't work with alpine
ARG VERSION
FROM ruby:$VERSION
ARG USER_NAME
ARG USER_UID
ARG USER_GID
RUN groupadd --gid $USER_GID $USER_NAME
RUN useradd --uid $USER_UID --gid $USER_GID $USER_NAME
RUN wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O- | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" | tee /etc/apt/sources.list.d/postgresql.list
RUN apt update && apt install -y postgresql-10