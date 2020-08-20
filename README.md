
## Overview:
The dockerized development environment (devironment) is designed so all files
reside on a host file system while a preconfigured microservice ensures
portability across any cloud or on-prem system. This means there are no
boundaries to the type of host this containerized environment resides. The
general purpose of a container is to decrease development, test, and deployment
time. The advantage is a flexible enviroment that literally downloads, installs,
and runs anywhere in a few minutes. In addition, dockerized microservices are
easy to throw away and reuse since everything is available via cloud
infrastructure. This is the reason cloud computing is wildly popular.

## Prerequisites:

"docker-engine" must be installed on host system:
https://docs.docker.com/engine/installation/

Access to the git repositories requires your private ssh key. Verify your
key is available (~/.ssh/id_rsa) on the host file system with permissions set as
the example below.

  `-rw-------    1 user  group          1675 Aug 22 15:43 id_rsa`

Make a "Workspace" directory from a user's home path and change directory
(cd ~/Workspace) to the newly created space. Run "git clone <url_of_this_repo>".
After the devironment repo download is complete, run "./devironment.sh fresh" to
create an enviroment that includes all required repos for development and
testing. All repositories are directly accessible via the host file system.
Tests are started via the container console which is accessible running
"./devironment.sh console". For assistance, read the help information listed
below or run './devironment.sh help' for similar guidance.

## Available Services:
  ```
  Port 8022 - SSH Access
    Syntax: ssh -p 8022 -l <userName> <hostIp>
    Note: SSH port 8022 and other services are only available while the devironment container is up. Run
          "./devironment.sh status" from the host system to review the state of the container.

  Port 8080 - Tsung Reports
    URL: http://<hostIp>:8080
    Note: From the container, run "~/scripts/simpleHTTPServer.sh start" to launch a web server or run
          "~/scripts/simpleHTTPServer.sh help" for command line assistance.

  Port 8091 - Tsung Dashboard
    URL: http://<hostIp>:8091
    Note: The Tsung Dashboard is available only while a test is running.
  ```

## Help Information:
In the "~/scripts" directory of the devironment console, the following files
are available to ease development and test efforts.

  ```
  flushCouchDB.sh     - flush the CouchDb
  runTsung.sh         - run tests
  simpleHTTPServer.sh - start a web server for reviewing reports
  sshKnownHosts.sh    - gather SSH keys from worker nodes before running tests
  ```

From the host, run any of the following options below.

### Build new docker images locally
    ./devironment.sh build

### Clone git repository
    ./devironment.sh clone

### Log into container console
    ./devironment.sh console

### Pull latest docker image from registry server
    ./devironment.sh dpull

### Push new docker images to registry server
    ./devironment.sh dpush

### Set up a new development environment
    ./devironment.sh fresh

### Pull the latest master branch from git repositories
    ./devironment.sh gpull

### This help information
    ./devironment.sh help

### List images on system
    ./devironment.sh image

### Remove docker images after build, test, and push process is complete'
    ./devironment.sh remove

### Start container
    ./devironment.sh start

### Check running state of docker container
    ./devironment.sh status

### Stop container and remove
    ./devironment.sh stop

### Build version for this script and docker images
    ./devironment.sh version

