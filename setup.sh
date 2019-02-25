#!/bin/bash
set -e
set -x


function cleanup {
  if [ -z $SKIP_CLEANUP ]; then
    echo "Removing build directory ${BUILDENV}"
    rm -rf "${BUILDENV}"
  fi
}

trap cleanup EXIT

# check if this is a travis environment
if [ ! -z $TRAVIS_BUILD_DIR ] ; then
  WORKSPACE=$TRAVIS_BUILD_DIR
fi

# check if this is a gitlab-ci environment
if [ ! -z $CI_PROJECT_DIR ] ; then
  WORKSPACE=$CI_PROJECT_DIR
fi

if [ -z $WORKSPACE ] ; then
  echo "No workspace configured, please set your WORKSPACE environment"
  exit
fi

BUILDENV=`mktemp -d /tmp/mageteststand.XXXXXXXX`

echo "Using build directory ${BUILDENV}"

# TODO: Remove before merge in master
git clone https://github.com/gpaddis/MageTestStand.git -b install-dependencies-from-composer-json-in-htdocs "${BUILDENV}"
cp -rf "${WORKSPACE}" "${BUILDENV}/.modman/"

MODULE_NAME=${WORKSPACE##*/}
${BUILDENV}/install.sh $MODULE_NAME

if [ -d "${WORKSPACE}/vendor" ] ; then
  cp -rf ${WORKSPACE}/vendor/* "${BUILDENV}/vendor/"
fi

cd ${BUILDENV}/htdocs
${BUILDENV}/bin/phpunit --colors -d display_errors=1
