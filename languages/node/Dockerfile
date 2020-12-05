# groupadd and useradd don't work with alpine
ARG VERSION
FROM node:$VERSION
ARG USER_NAME
ARG USER_UID
ARG USER_GID
RUN groupadd -o --gid $USER_GID $USER_NAME
RUN useradd -o --uid $USER_UID --gid $USER_GID $USER_NAME
