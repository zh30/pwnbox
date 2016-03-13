##################################################################
# Dockerfile to build a container for binary reverse engineering #
# and exploitation. Suitable for CTFs.                           #
#                                                                #
# To build: docker build -t superkojiman/pwnbox64 .              #
##################################################################

FROM phusion/baseimage
MAINTAINER superkojiman@techorganic.com

ENV DEBIAN_FRONTEND noninteractive

RUN dpkg --add-architecture i386
RUN apt-get update && apt-get -y upgrade

# Install packages from Ubuntu repos
RUN apt-get install -y \
    build-essential \
    gdb \
    python-dev \
    python-pip \
    python3-pip \
    binutils-arm-linux-gnueabi \
    binfmt-support \
    binfmtc \
    gcc-arm-linux-gnueabi \
    g++-arm-linux-gnueabi \
    libc6-armhf-cross \
    gdb-multiarch \
    nasm \
    tmux \
    git \
    binwalk \
    strace \
    ltrace \
    autoconf \
    socat \
    netcat \
    libc6:i386 \
    libncurses5:i386 \
    libstdc++6:i386 \
    libc6-dev-i386

RUN apt-get -y autoremove
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install stuff from pip repos
RUN pip install pycipher uncompyle ropgadget distorm3
RUN yes | pip uninstall capstone
RUN pip install --upgrade git+https://github.com/binjitsu/binjitsu.git
RUN pip3 install pycparser

# Install stuff from GitHub repos
RUN git clone https://github.com/aquynh/capstone /opt/capstone && \
    cd /opt/capstone && \
    git checkout -t origin/next && \
    ./make.sh install && \
    cd bindings/python && \
    python setup.py install && \
    python3 setup.py install

RUN git clone https://github.com/radare/radare2.git /opt/radare2 && \
    cd /opt/radare2 && \
    ./sys/install.sh 

RUN git clone https://github.com/sashs/Ropper.git /opt/ropper && \
    cd /opt/ropper && \
    python setup.py install

RUN git clone https://github.com/packz/ropeme.git /opt/ropeme && \
    sed -i 's/distorm/distorm3/g' /opt/ropeme/ropeme/gadgets.py

RUN git clone https://github.com/hellman/libformatstr.git /opt/libformatstr && \
    cd /opt/libformatstr && \
    python setup.py install

# gdbinit files
RUN git clone https://github.com/bruce30262/peda.git /opt/peda
RUN git clone https://github.com/zachriggle/pwndbg /opt/pwndbg
RUN git clone https://github.com/hugsy/gef.git /opt/gef

ENTRYPOINT ["/bin/bash"]