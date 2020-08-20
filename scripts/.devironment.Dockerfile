FROM ubuntu:16.04
MAINTAINER csmiga@ore.com

LABEL version='1.0.1'
LABEL description='devironment Image'

# RELEASE INFORMATION
# NOTE: build information must also be updated in the 'devironment.sh' file
# 'ENVIRONMENT INFORMATION' section of that file.
RUN echo 'Environment: Tsung Development' && \
    echo 'Build: 20180828-1201' > /etc/container-release && \
    echo 'Version: 1.0.1' >> /etc/container-release && \
    echo 'Description: Container Image' >> /etc/container-release

# SET IMAGE ENVIRONMENT VARIABLES
ENV DEBIAN_FRONTEND 'noninteractive'
ENV LANG 'C.UTF-8'
ENV PERL_MM_USE_DEFAULT '1'
ENV CONTAINER_SHELL '/bin/bash'
ENV PYTHON_VERSION '2.7.9'
ENV PYTHON_GPG_KEY 'C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF'
ENV HOME '/tmp'

# UPDATE REPOSITORY AND INSTALL DEPENDENCIES
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y --no-install-recommends software-properties-common \
        apt-utils \
        dnsutils \
        iputils-ping \
        net-tools \
        tcpdump \
        curl \
        wget \
        git \
        vim

# TSUNG REPOSITORY AND APPLICATION
RUN add-apt-repository -y ppa:tsung/daily && \
    apt-get update && \
    apt-get install -y --no-install-recommends tsung

# PERL, DEPENDENCIES, AND MODULES (FOR TSUNG REPORTS)
RUN apt-get install -y --no-install-recommends build-essential \
        perl \
        cpanminus \
        libtemplate-perl \
        libexpat1-dev \
        gnuplot && \
    cpan install XML::Simple

# PYTHON, DEPENDENCIES, AND MODULES (FOR TEST FRAMEWORK)
RUN apt-get install -y --no-install-recommends gnupg2 \
    zlib1g-dev \
    libssl-dev \
    libpython2.7
RUN mkdir -p /usr/src/python && \
    cd /usr/src/python && \
    wget -O /usr/src/python/python.tar.xz https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-${PYTHON_VERSION}.tar.xz && \
    wget -O /usr/src/python/python.tar.xz.asc https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-${PYTHON_VERSION}.tar.xz.asc && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys ${PYTHON_GPG_KEY} && \
    gpg --batch --verify python.tar.xz.asc python.tar.xz && \
    tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz && \
	gnuArch=$(dpkg-architecture --query DEB_BUILD_GNU_TYPE) && \
	./configure --build=${gnuArch} --enable-shared --enable-unicode=ucs4 && \
	make -j $(nproc) && \
	make install && \
    wget -O get-pip.py https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    cd /root && \
    rm -rf /usr/src/python && \
    pip install requests==2.10.0 \
        paramiko==2.1.1 \
        fabric==1.13.1 \
        pyOpenSSL==17.5.0 \
        ndg-httpsclient==0.4.2 \
        pyasn1==0.1.9 \
        cryptography==1.5 \
        cffi==1.7.0 \
        enum34==1.1.6 \
        idna==2.1 \
        ipaddress==1.0.16 \
        pycparser==2.14 \
        six==1.10.0 \
        sshtunnel==0.1.3 \
        boto3 \
        setuptools \
        elasticsearch==2.4.1 \
        pathos==0.2.1
u
# JAVA
RUN apt-get install -y --no-install-recommends openjdk-8-jre

# SSH SERVER
RUN apt-get install -y --no-install-recommends openssh-server

# REMOVE CACHED DPKG FILES
RUN apt-get auto-remove && \
    apt-get clean

# ENABLE inet_dist_listen_* PROPERTIES FOR ERLANG TO RUN
RUN sed -i.bak s/64000/9001/g /usr/bin/tsung && \
    sed -i.bak s/65500/9050/g /usr/bin/tsung && \
    printf '[{kernel,[{inet_dist_listen_min,9001},{inet_dist_listen_max,9050}]}]. \n\n' > /root/sys.config && \
    # Modifying '/root' directory permissions to permit Erlang/Tsung to access
    # the /root/sys.config file. No other location for sys.config is adiquate
    chmod 707 /root && \
    sed -i.bak s/'erlexec\"'/'erlexec\" -config \/root\/sys'/g /usr/bin/erl

