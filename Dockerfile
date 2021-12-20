
# ARG PYTHON_VERSION=3.8
# ARG NODEJS_VERSION=14

FROM alpine:3.14 as downloads
WORKDIR /downloads/
RUN wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O "awscliv2.zip"

# Immutable tag - Node Version 14.18.2, Python Version 3.8.12
FROM nikolaik/python-nodejs@sha256:02d0cce207a5d79f085c4a3a455af5b8b9454bc35ff7f755a25341fcaa3b088e as dev
# FROM nikolaik/python-nodejs:python${PYTHON_VERSION}-nodejs${NODEJS_VERSION}-slim as dev
RUN apt-get update && \
    apt-get install -y \
    bash git zip unzip bash-completion curl jq

WORKDIR /tmp/tmpdir
COPY --from=downloads /downloads/awscliv2.zip ./
RUN unzip awscliv2.zip && \
    chmod +x ./aws/install && \
    ./aws/install

ARG SERVERLESS_VERSION=2.66.2
ARG TYPESCRIPT_VERSION=3.8.2
RUN yarn global add serverless@${SERVERLESS_VERSION} typescript@${TYPESCRIPT_VERSION}

ARG APP_USER_NAME="appuser"
ARG APP_GROUP_ID="appgroup"
ARG APP_HOME_DIR="/home/${APP_USER_NAME}"
ENV HOME="${APP_HOME_DIR}"


# Run as a non-root user
WORKDIR "/code/"
RUN mkdir -p "${APP_HOME_DIR}" && \
    addgroup "${APP_GROUP_ID}" && \
    useradd "${APP_USER_NAME}" --gid "${APP_GROUP_ID}" --home-dir "${APP_HOME_DIR}" && \
    chown "${APP_USER_NAME}":"${APP_GROUP_ID}" "${APP_HOME_DIR}"
RUN \
    curl --silent -o "${APP_HOME_DIR}/.git-prompt.sh" "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh" && \
    chmod +x "${APP_HOME_DIR}/.git-prompt.sh"
RUN echo "export PATH=$PATH:/usr/local/bin" >> "${HOME}/.bashrc" && \
    echo "source ${HOME}/.git-prompt.sh" >> "${HOME}/.bashrc" && \
    echo "export PS1=\"\[\033[01;34m\]$ \w\[\033[00m\]$(__git_ps1) \"" >> "${HOME}/.bashrc"
USER "${APP_USER_NAME}"

CMD ["bash"]
