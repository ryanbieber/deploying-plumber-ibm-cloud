# deploying-plumber-ibm-cloud

First off, I got a lot of help by using various sources of info for this guide as it is mainly for connecting a db2 database to a docker container that is running a R API i.e. a plumber application. Then we deploy this application on a kubernetes cluster to allow us to call it from anywhere in the world.

I had a very hard time finding any documentation about how to connect a db2 database to a docker container so I figured I should let others get the info that I found instead of them having to figure it out on their own. 

## Prereqs
I am assuming you have done all the background work in downloading docker, ibm cli, kubernetes, etc. Their is many guides for that online and it is not my intention to replicate what they have done.

## DB2 connection
The problem with connecting to db2s from a docker container is that the documentation is very confusing and never covers exactly what you need to do. 


