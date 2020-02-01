FROM rocker/r-ver:3.6.0

# update some packages, including sodium and apache2, then clean
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    file \
    libcurl4-openssl-dev \
    libedit2 \
    libssl-dev \
    lsb-release \
    psmisc \
    procps \
    unixodbc-dev \
    wget \
    libxml2-dev \
    libpq-dev \
    libssh2-1-dev \
    ca-certificates \
    libglib2.0-0 \
	libxext6 \
	libsm6  \
	libxrender1 \
	bzip2 \
	libsodium-dev \
    apache2 \
    zlib1g-dev \
    r-cran-rjava \
    default-jdk \
    default-jre \
    libbz2-dev \
    libpcre3-dev \
    liblzma-dev \
    && wget -O libssl1.0.0.deb http://ftp.debian.org/debian/pool/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u8_amd64.deb \
    && dpkg -i libssl1.0.0.deb \
    && rm libssl1.0.0.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/ 



# copy the setup script, run it, then delete it
COPY src/setup.R /
RUN Rscript setup.R && rm setup.R


# copy all the other R files.
COPY src /src

# db2 drivers
COPY db2jcc4.jar /opt/ibm/dsdriver/java/db2jcc4.jar

EXPOSE 80

WORKDIR /src
ENTRYPOINT ["Rscript","main.R"]
