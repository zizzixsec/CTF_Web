# ZizzixSec CTF Web Dockerfile
FROM archlinux:latest
LABEL maintainer="Rachel Snyder <zizzixsec@gmail.com>"

ARG TZ="America/Chicago"
ARG LANG="en_US.UTF-8"

ENV SHELL "/bin/bash"
ENV HOME "/root"
ENV EDITOR "vim"
ENV PATH "$PATH:$HOME/go/bin:$HOME/.local/share/gem/ruby/3.0.0/bin:$HOME/.cargo/bin:$HOME/bin"

RUN ln -svf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    sed -i "s/^#${LANG}/${LANG}/g" /etc/locale.gen && \
    locale-gen && echo "LANG=${LANG}" > /etc/locale.conf

RUN pacman-key --init && pacman -Syu --noconfirm

RUN pacman -S --noconfirm \
    base-devel git wget curl tmux python python-pip gnu-netcat go\
    ruby vim xclip nodejs npm sqlmap proxychains-ng cargo perl-image-exiftool 

WORKDIR ${HOME}
RUN mkdir -pv bin github

RUN pip install --no-cache-dir --break-system-packages -U \
    pip pycryptodomex requests click termcolor cprint setuptools && \
    gem install mime mime-types mini_exiftool nokogiri rubyzip spider && \
    rm -rf .local/share/gem/ruby/3.0.0/cache/* && \
    cargo install feroxbuster

RUN git clone https://github.com/ticarpi/jwt_tool github/jwt_tool && \
    chmod +x github/jwt_tool/jwt_tool.py && \
    ln -svf $HOME/github/jwt_tool/jwt_tool.py $HOME/bin/jwt_tool

RUN git clone https://github.com/digininja/CeWL.git github/CeWL && \
    chmod +x github/CeWL/cewl.rb && \
    ln -svf $HOME/github/CeWL/cewl.rb $HOME/bin/cewl

RUN git clone https://github.com/zizzixsec/munge3.git github/Munge3 && \
    pip install -r github/Munge3/requirements.txt && \
    chmod +x github/Munge3/munge3.py && \
    ln -svf $HOME/github/Munge3/munge3.py $HOME/bin/munge3

RUN go install github.com/ffuf/ffuf/v2@latest

COPY home/.vimrc .vimrc
COPY home/.bash_profile .bash_profile
COPY home/.bashrc .bashrc

WORKDIR /chal
CMD bash