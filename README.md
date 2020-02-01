# deploying-plumber-ibm-cloud

First off, I got a lot of help by using various sources of info for this guide as it is mainly for connecting a db2 database to a docker container that is running a R API i.e. a plumber application. Then we deploy this application on a kubernetes cluster to allow us to call it from anywhere in the world.

I had a very hard time finding any documentation about how to connect a db2 database to a docker container so I figured I should let others get the info that I found instead of them having to figure it out on their own. 

## Prereqs
I am assuming you have done all the background work in downloading docker, ibm cli, kubernetes, etc. Their is many guides for that online and it is not my intention to replicate what they have done.

## DB2 connection
The problem with connecting to db2s from a docker container is that the documentation is very confusing and never covers exactly what you need to do. 

## Looking at the Dockerfile

I have blanked out some of the stuff as it is not needed for the explanation for the db2. 

### these packages are essential
r-cran-rjava \
default-jdk \
default-jre \
libbz2-dev \
libpcre3-dev \
liblzma-dev \

What this is doing is downloading the necessary backend for the RJDBC package in R. I ran into problems with the cran download of it on my docker image so I had to use the binaries from cran which is just install.packages("RJDBC", source = TRUE). I also download rjava from the dockerfile as it is the only way I could get it to work. The other packages are need for the java runtime envoirment.

## Steps

In the command line you are going to want to build, tag, and run your image. I have port 80 exposed as that is what plumber is listening on in my program. 



