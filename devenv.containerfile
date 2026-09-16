ARG PKGS_IMAGE=ghcr.io/sebag90/devenv-pkgs:latest
ARG HELIX_IMAGE=ghcr.io/sebag90/helix:latest

FROM docker.io/alpine/git:latest as config
WORKDIR /workspace
# busts the clone layer whenever dotfiles HEAD moves
ADD https://api.github.com/repos/sebag90/dotfiles/commits/main /tmp/dotfiles-head
RUN git clone --depth 1 https://github.com/sebag90/dotfiles.git

FROM ${PKGS_IMAGE} AS pkgs
FROM ${HELIX_IMAGE} AS helix

FROM fedora AS final

ARG WORK_DIR=/workspace
ARG HOME_DIR=/home/dev
ARG VENV_DIR=/home/dev/venv

COPY --from=pkgs /home/linuxbrew/.linuxbrew /home/linuxbrew/.linuxbrew
COPY --from=helix /usr/local/bin/hx /usr/local/bin/hx
COPY --from=helix /usr/local/share/helix /usr/local/share/helix
COPY --from=config /workspace/dotfiles/config $HOME_DIR/.config

ENV PATH=$VENV_DIR/bin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/usr/local/bin:$PATH \
    HELIX_RUNTIME=/usr/local/share/helix/runtime \
    LANG=C.UTF-8 \
    HOME=$HOME_DIR \
    XDG_CONFIG_HOME=$HOME_DIR/.config \
    VIRTUAL_ENV=$VENV_DIR \
    UV_PROJECT_ENVIRONMENT=$VENV_DIR \
    SHELL=/home/linuxbrew/.linuxbrew/bin/fish \
    NPM_CONFIG_PREFIX=/usr/local \
    DEVENV=1

RUN mkdir -p $HOME_DIR/.local/share $HOME_DIR/.cache \
    && ln -s /home/linuxbrew/.linuxbrew/bin/podman /usr/local/bin/docker \
    && echo "ALL ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/container \
    && chmod 440 /etc/sudoers.d/container

RUN dnf install -y git wl-clipboard openssh-clients which && dnf clean all

# install pi coding agent and aws cli
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent \
    && pi install npm:pi-ponytail \
    && curl -fsSL https://awscli.amazonaws.com/v2/install.sh | bash

# any uid must be able to write to the home dir (podman --user)
RUN uv venv $VENV_DIR \
    && chmod -R 777 $HOME_DIR

WORKDIR $WORK_DIR
ENTRYPOINT ["fish"]
