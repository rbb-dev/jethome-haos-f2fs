FROM debian:bullseye

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Docker
RUN apt-get update && apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        gpg-agent \
        gpg \
        dirmngr \
        software-properties-common \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker.gpg] \
        https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update && apt-get install -y --no-install-recommends \
        docker-ce \
    && rm -rf /var/lib/apt/lists/*

# Build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
        automake \
        bash \
        bc \
        binutils \
        build-essential \
        bzip2 \
        cpio \
        file \
        git \
        graphviz \
        help2man \
        jq \
        make \
        ncurses-dev \
        openssh-client \
        patch \
        perl \
        pigz \
        python3 \
        python3-matplotlib \
        python-is-python3 \
        qemu-utils \
        rsync \
        skopeo \
        sudo \
        texinfo \
        unzip \
        vim \
        wget \
        zip \
    && rm -rf /var/lib/apt/lists/*

# f2fs-tools with LZ4 compression (Debian's package is built without --with-lz4)
RUN apt-get update && apt-get install -y --no-install-recommends \
        liblz4-dev uuid-dev libblkid-dev pkg-config libtool \
    && git clone --depth 1 --branch v1.16.0 \
        https://git.kernel.org/pub/scm/linux/kernel/git/jaegeuk/f2fs-tools.git /tmp/f2fs-tools \
    && cd /tmp/f2fs-tools \
    && autoreconf -fi \
    && ./configure --with-lz4 --without-lzo2 --without-selinux \
    && make -j"$(nproc)" \
    && make install \
    && rm -rf /tmp/f2fs-tools /var/lib/apt/lists/* \
    && ldconfig

# Init entry
COPY scripts/entry.sh /usr/sbin/
ENTRYPOINT ["/usr/sbin/entry.sh"]

# Get buildroot
WORKDIR /build
