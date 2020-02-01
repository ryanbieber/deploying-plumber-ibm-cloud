# deploying-plumber-ibm-cloud

First off, I got a lot of help by using various sources of info for this guide as it is mainly for connecting a db2 database to a docker container that is running a R API i.e. a plumber application. Then we deploy this application on a kubernetes cluster to allow us to call it from anywhere in the world.

I had a very hard time finding any documentation about how to connect a db2 database to a docker container so I figured I should let others get the info that I found instead of them having to figure it out on their own. 

## Prereqs
I am assuming you have done all the background work in downloading docker, ibm cli, kubernetes, etc. Their is many guides for that online and it is not my intention to replicate what they have done.

## Dockerfile explanation
This is the image we are going base our program off of not the trestletech one as I had problems with that one for the db2 connection.

>FROM rocker/r-ver:3.6.0

Most of these you wont need and I highlighted the ones essential to the db2 database connection using the RJDBC package

>RUN apt-get update \
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
    
    
My setup R file is in the src folder this dockerfile is in and I run it then delete it after I run it, it mainly installs the r-packages I need (I have warn=-2) so the build fails if a package doesnt install correctly.
>COPY src/setup.R /
>RUN Rscript setup.R && rm setup.R

Here is where I copy the rest of the r files in the src folder.
>COPY src /src

I have the db2jcc4.jar file in my folder as well which I got from the ibm website, i.e. [db2jcc drivers](https://www.ibm.com/support/pages/db2-jdbc-driver-versions-and-downloads)
>COPY db2jcc4.jar /opt/ibm/dsdriver/java/db2jcc4.jar

Expose port 80 since that is what plumber is running on and listening too
>EXPOSE 80

Set my Workdir and entrypoint
>WORKDIR /src

>ENTRYPOINT ["Rscript","main.R"]

This could probably get cleaned up a bit as some of those packages I install in the initial apt-get aren't used anymore, feel free to trim it down if needed. The image ends up being around 500mb if I remember correctly so it isnt very big.

### these packages are essential for db2 connection
>r-cran-rjava \
default-jdk \
default-jre \
libbz2-dev \
libpcre3-dev \
liblzma-dev \

What this is doing is downloading the necessary backend for the RJDBC package in R. I ran into problems with the cran download of it on my docker image so I had to use the binaries from cran which is just install.packages("RJDBC", source = TRUE). I also download rjava from the dockerfile as it is the only way I could get it to work. The other packages are need for the java runtime envoirment.

## Looking at the Dockerfile

I have blanked out some of the stuff as it is not needed for the explanation for the db2.

## DB2 connection
The problem with connecting to db2s from a docker container is that the documentation is very confusing and never covers exactly what you need to do. ODBC drivers didnt work for me so I had to use the JDBC drivers to connect to the database. Another thing is that using the prepackaged functions in RJDBC for the db2 inside a docker container don't entirely work correctly. I recommend using the dbSendUpdate("SELECT * FROM BLUDB.TEST") fucntion along with writing your own sql functions to push or pull your data from a db2.

## Steps
In your R program make sure you initilize these parameters,

>jcc <- RJDBC::JDBC(driverClass = "com.ibm.db2.jcc.DB2Driver", classPath = "/opt/ibm/dsdriver/java/db2jcc4.jar")
urljdbc <- "JDBCURL"
databaseUsername <- "bluadmin"
databasePassword <- "PASSWORD"

The driverclass is the db2jcc4 driver where the classpath is where we placed the db2jcc4 file in the dockerfile. This is telling the RJDBC to look on that path to find the driver so it can connect using the jdbcurl and user/password. Now, when you run your program and try to connect to a db2 database from it inside a container, this will know how to do it.

In the command line you are going to want to build, tag, and run your image. I have port 80 exposed as that is what plumber is listening on in my program. 

Make sure it works locally by using ngrok to open a port on your pc to test the connection to the database. After you made sure it works, then you are ready to deploy to the ibmcloud.

You built the image and tagged it now you just need to push it to the IBM container registry. On the container registry they give you a pretty good tutorial of how to do it, it takes about 4 lines in the cmd line. (FYI for the namespace part, if you are on a shared account make sure you have admin privledges or you wont be able to make a namespace to store your images.)

After you have your images in the registry, use the deployment and service-nodeport .yaml files to use kubernetes to deploy your app and expose it to the real world.

Now, you should be able to make a plumber api, house it in docker, put it on the cloud, and connect to a db2 database all at the same time.

I had alot of help from looking at mainly two "areas", [Marc Mondson](https://code.markedmondson.me/r-on-kubernetes-serverless-shiny-r-apis-and-scheduled-scripts/) and [Most Useful](https://github.com/holken1/deploying-r-on-cloud). With the latter being a HUGE help in connecting the app to kubernetes. 

### The end

That is pretty much it, I had to use an amalgamation of resources to put this together as most of the answers were for different programs, different databases, etc.



