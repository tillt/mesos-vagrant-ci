#!/usr/bin/env bash

cd "$PLATFORM_NAME"
./setup.sh

vagrant up
vagrant reload
