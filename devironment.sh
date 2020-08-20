#!/usr/bin/env bash

# Enable debug mode (-x). Disable debug mode (+x)
set +x

: <<'END'
Author:      Christopher Smiga
Address:     3868 Bream Court
Address:     Buford, GA. 30019
e-Mail:      csmiga@ore.com

Team:        Ore
Team eMail:  team@ore.com

Docker:      1.12.5+
File:        devironment.sh
END

# ENVIRONMENT INFORMATION
# NOTE: build information must also be updated in the
# "devironment.Dockerfile", "RELEASE INFORMATION" section of that file.
buildNumber='20180828-1201'
repository01='containers.gitlab.com/ovpss/devironment'
image01=${repository01}':latest'
image02=${repository01}':'${buildNumber}
workspace=${HOME}/Workspace
container01='devironment'

# FUNCTIONS
function build() {
    docker build -t ${image01} -f scripts/.devironment.Dockerfile .
    docker tag ${image01} ${image02}
}

function clone() {
    # CLONE REPOS, SETUP COOKIE DIRECTORY
    cd ${workspace}
    if [ ! -d ${workspace}/performance_tests/.git ]
    then
        echo 'INFO: Cloning performance_tests repository since it does not exist.'
            git clone git@github3.gitlab.com:ore/performance_tests.git ${workspace}/performance_tests
    else
        echo 'INFO: performance_tests repository already exist. Run "./devironment.sh gpull" to pull latest code from the master branch.'
    fi
    if [ ! -d ${workspace}/performance_tests/testFolder ]
    then
        echo 'INFO: Creating testFolder directory since it does not exist.'
        mkdir -p ${workspace}/performance_tests/testFolder
    else
        echo 'INFO: testFolder directory already exist.'
    fi
    if [ ! -d ${workspace}/systest_utilities/.git ]
    then
        echo 'INFO: Cloning systest_utilities repository since it does not exist.'
        git clone git@github3.gitlab.com:ore/systest_utilities.git ${workspace}/systest_utilities
    else
        echo 'INFO: systest_utilities repository already exist. Run "./devironment.sh gpull" to pull latest code from the master branch.'
    fi
    if [ ! -d ${workspace}/device_cookies/.git ]
    then
        echo 'INFO: Cloning device_cookies repository since it does not exist.'
        git clone git@github3.gitlab.com:ore/device_cookies.git ${workspace}/device_cookies
        echo 'INFO: Decompressing device cookie files'
        gzip -d ${workspace}/device_cookies/Solutions/AWS/Ontario/*.gz
    else
        echo 'INFO: device_cookies repository already exist. Run "./devironment.sh gpull" to pull latest code from the master branch.'
    fi
    if [ ! -d ${workspace}/systest_utilities/ihstpy/ihstcookies/sessioncookies ]
    then
        echo 'INFO: Creating sessioncookies directory since it does not exist.'
        mkdir -p ${workspace}/systest_utilities/ihstpy/ihstcookies/sessioncookies
    else
        echo 'INFO: sessioncookies directory already exist.'
    fi
}

function console() {
    docker exec -it --user $(id -u):$(id -g) ${container01} /bin/bash
}

function dpull() {
    docker pull ${image01}
}

function dpush() {
    docker login --username 'ovpss+cswbuild' --password 'F8PSW7RVXZS8IPKOY4YMFT34MXT5VJXE5P1PYMI92P6SB8RD1H9Z695BY80C7E2T' containers.gitlab.com
    docker push ${image01}
    docker push ${image02}
}

function gpull() {
    if [ ! -d ${workspace}/performance_tests/.git ]
    then
        echo 'INFO: performance_tests directory or required sub-directory does not exist. Run "./devironment.sh clone"'
    else
        echo 'INFO: performance_tests directory and required sub-directory exist. Pulling latest code from performance_tests repo.'
        cd ${workspace}/performance_tests
        git pull origin master
    fi
    if [ ! -d ${workspace}/systest_utilities/.git ]
    then
        echo 'INFO: systest_utilities directory or required sub-directory does not exist. Run "./devironment.sh clone"'
    else
        echo 'INFO: systest_utilities directory and required sub-directory exist. Pulling latest code from systest_utilities repo.'
        cd ${workspace}/systest_utilities
        git pull origin master
    fi
    if [ ! -d ${workspace}/device_cookies/.git ]
    then
        echo 'INFO: device_cookies directory or required sub-directory does not exist. Run "./devironment.sh clone"'
    else
        echo 'INFO: device_cookies directory and required sub-directory exist. Pulling latest code from device_cookies repo.'
        cd ${workspace}/device_cookies
        git pull origin master
    fi
}

function image() {
    docker images
}

function remove() {
    echo 'INFO: Removing images from build process'
    docker rmi ubuntu:16.04 \
               ${image02}
               #${image01}
}

function startContainer() {
    # devironment
    local userName=$(whoami)
    local home=${HOME}
    local tsung_clusters='False'
    local headend='foo'

    echo 'STATUS: Starting '${container01}' container'
    if [ ! -d ${workspace}/tsung_log ]
    then
        echo 'INFO: Creating tsung_log directory since it does not exist.'
        mkdir -p ${workspace}/tsung_log
    else
        echo 'INFO: tsung_log directory already exist.'
    fi
    if [ ! -d ${HOME}/.vim ]
    then
        echo 'INFO: Copying .vim directory to host since it does not exist.'
        cp -R ${workspace}/devironment/scripts/.vim ${HOME}
    else
        echo 'INFO: .vim directory already exist.'
    fi
    if [ ! -f ${HOME}/.vimrc ]
    then
        echo 'INFO: Copying .vimrc file to host since it does not exist.'
        cp ${workspace}/devironment/scripts/.vimrc ${HOME}
    else
        echo 'INFO: .vimrc file already exist.'
    fi
    if [ ! -f ${HOME}/.bashrc ]
    then
        echo 'INFO: Copying .bashrc file to host since it does not exist.'
        cp -R ${workspace}/devironment/scripts/.bashrc ${HOME}
    else
        echo 'INFO: .bashrc file already exist.'
    fi
    if [ ! -f ${HOME}/.bash_history ]
    then
        echo 'INFO: Copying .bash_history file to host since it does not exist.'
        cp -R ${workspace}/devironment/scripts/.bash_history ${HOME}
    else
        echo 'INFO: .bash_history file already exist.'
    fi
    if [ ! -d ${HOME}/.ssh ]
    then
        echo 'INFO: Creating ~/.ssh directory on host since it does not exist.'
        mkdir ${HOME}/.ssh
        chmod 700 ${HOME}/.ssh
        touch ${HOME}/.ssh/known_hosts
    else
        echo 'INFO: .ssh directory already exist.'
    fi
    docker run --rm -itd \
        --hostname ${container01} \
        --volume ${workspace}/devironment/scripts/etc_hosts.db:/etc/hosts:rw \
        --volume /etc/services:/etc/services:ro \
        --volume /etc/resolv.conf:/etc/resolv.conf:ro \
        --volume /etc/TZ:/etc/TZ:ro \
        --volume /etc/passwd:/etc/passwd:ro \
        --volume /etc/group:/etc/group:ro \
        --volume /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
        --volume ${HOME}/.ssh:${home}/.ssh:rw \
        --volume ${HOME}/.vimrc:${home}/.vimrc:rw \
        --volume ${HOME}/.vim:${home}/.vim:rw \
        --volume ${HOME}/.bash_history:${home}/.bash_history:rw \
        --volume ${HOME}/.bashrc:${home}/.bashrc:rw \
        --volume ${workspace}/performance_tests:${home}/performance_tests:rw \
        --volume ${workspace}/systest_utilities:${home}/systest_utilities:rw \
        --volume ${workspace}/systest_utilities/ihstpy/ihstcookies/sessioncookies:${home}/sessioncookies:rw \
        --volume ${workspace}/device_cookies/Solutions/AWS/Ontario:${home}/sessioncookies/ontario:rw \
        --volume ${workspace}/device_cookies/Solutions/AWS/Ontario:${home}/sessioncookies/superior:rw \
        --volume ${workspace}/devironment/scripts:${home}/scripts:rw \
        --volume ${workspace}/tsung_log:${home}/.tsung/log:rw \
        --volume ${workspace}/tsung_log:${home}/tsung_log:rw \
        --workdir ${home} \
        --env HOME=${home} \
        --env TERM=xterm \
        --env headend=${headend} \
        --env tsung_clusters=${tsung_clusters} \
        --env ERL_EPMD_PORT=4369 \
        --expose 9001-9050 \
        --publish 22:8022 \
        --publish 4369:4369 \
        --publish 8080:8080 \
        --publish 8091:8091 \
        --network host \
        --user $(id -u):$(id -g) \
        --name ${container01} ${image01} \
        /bin/bash
    echo 'STATUS: Started '${container01}' container'
}

function status() {
    local container=(${container01})
    for element in "${container[@]}"
    do
        echo -n 'STATUS: '$element' container '
        docker inspect ${element} | grep Status | awk -F'"' '{print "(" $4 ")"}'
    done
}

function stopTest() {
    echo 'STATUS: Stopping '${container01}' container'
    docker stop ${container01} > /dev/null 2>&1
    echo 'STATUS: Stopped '${container01}' container'
}

function waitOnContainer() {
    # Creating empty value for variable 'state' in line below
    local state=`docker inspect ${waitOnContainerJob} | grep Status | awk -F'"' '{ print $4 }'`
    while [ "${state:-0}" == 'running' ]
    do
        clear
        echo $waitOnContainerJob $state
        local state=`docker inspect ${waitOnContainerJob} | grep Status | awk -F'"' '{ print $4 }'`
        sleep 1
    done
}

# CASE STATEMENTS
case "$1" in
    build)
        build
        ;;
    clone)
        clone
        ;;
    console)
        console
        ;;
    dpull)
        dpull
        ;;
    dpush)
        dpush
        ;;
    fresh)
        dpull
        clone
        startContainer
        ;;
    gpull)
        gpull
        ;;
    help)
        echo ''
        echo 'Syntax: ./devironment.sh <option>'
        echo ''
        echo 'Usage Options:'
        echo '  build   - Build new docker images locally'
        echo '  clone   - Clone git repository'
        echo '  console - Log into container console'
        echo '  dpull   - Pull latest docker image from registry server'
        echo '  dpush   - Push new docker images to registry server'
        echo '  fresh   - Set up a new development environment'
        echo '  gpull   - Pull the latest master branch from git repositories'
        echo '  help    - This help information'
        echo '  image   - List images on system'
        echo '  remove  - Remove docker images after build, test, and push process is complete'
        echo '  start   - Start container'
        echo '  status  - Check running state of docker container'
        echo '  stop    - Stop container and remove'
        echo '  version - Build version for this script and docker images'
        echo ''
        ;;
    image)
        image
        ;;
    remove)
        remove
        ;;
    start)
        startContainer
        ;;
    status)
        status
        ;;
    stop)
        stopTest
        ;;
    version)
        echo ${buildNumber}
        ;;
    *)
        echo ''
        echo 'Usage:' $0 '{build|clone|console|dpull|dpush|fresh|gpull|help|image|remove|start|status|stop|version}'
        echo ''
        echo 'Syntax: ./devironment.sh help'
        echo ''
        exit 1
esac

exit 0

