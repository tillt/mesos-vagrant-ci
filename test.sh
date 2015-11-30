#!/usr/bin/env bash

#set -x
set -e

if [[ $# -ne 4 ]] ; then
	echo "We need four parameters."
	exit 1
fi

PLATFORM_NAME="$1"
VAGRANT_CPUS="$2"
GIT_REPO="$3"
GIT_CHECKOUT="$4"

printf "\nControlling platform $1\n"

STEP=1

STEP_NAMES=('non ssl, user, check' 	\
	    'non ssl, root, check' 	\
	    'ssl, user, check' 		\
	    'ssl, root, check')

PREFIX=" ${PLATFORM_NAME} :: "

function finish {
	printf "\n"
	echo "${PREFIX} !!! ABORT in step: ${STEP_NAMES[$STEP]}"
}


function step_it {
	case ${STEP} in
	1)	../configure
		make -j$VAGRANT_CPUS check
		;;
	2)	sudo ./bin/mesos-tests.sh
		;;
	3)	make clean
		../configure --enable-libevent --enable-ssl
		make -j$VAGRANT_CPUS check
		;;
	4)	sudo ./bin/mesos-tests.sh
		;;
	*)	echo 'invalid phase'
		exit 1
		;;
	esac
}

trap finish EXIT

if [ ! -d "mesos" ]; then
	git clone $GIT_REPO mesos
	cd mesos
	git checkout $GIT_CHECKOUT
else
	cd mesos
fi

if [ ! -d "build" ]; then
	./bootstrap
	mkdir build
fi

cd build

while [ ${STEP} -lt 5 ]; do
	echo "${PREFIX} running step \"${STEP_NAMES[$STEP]}\""
	read -rsp $'Press any key to continue...\n' -n1 key
	step_it
	echo "${PREFIX} finished step \"${STEP_NAMES[$STEP]}\""
	(( STEP++ ))
done
