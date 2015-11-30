#set -x
set -e

export VAGRANT_CPUS=4
export VAGRANT_MEM=9000
export GIT_REPO="git@github.com:mesosphere/mesos-private.git"
export GIT_CHECKOUT="till/0.26.0-rc3_wip"

# export VAGRANT_CPUS=8
# export VAGRANT_MEM=16384
# export GIT_REPO="git@github.com:mesosphere/mesos-private.git"
# export GIT_CHECKOUT="till/0.26.0-rc3_wip"


if [[ $# -eq 0 ]] ; then
    echo "We need at least a platform."
fi

export PLATFORM_NAME=$1

if [[ $# -eq 1 ]] || [[ $2 = "setup" ]] ; then
    ./provision.sh
fi

if [[ $# -eq 1 ]] || [[ $2 = "run" ]] ; then
    cd "$PLATFORM_NAME"
    vagrant ssh -c "./test.sh '${PLATFORM_NAME}' '${VAGRANT_CPUS}' '${GIT_REPO}' '${GIT_CHECKOUT}'"
fi
