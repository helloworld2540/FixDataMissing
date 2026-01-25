#!/bin/sh
# build.sh

ME=${0##*/}
# just put the script to .zip, exclude myself and previous build.zip
7z a latest_build.zip . -x!latest_build.zip -x!$ME -x!update.json # no need exclude changelog