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

if [ -z $WORKSPACE ] ; then
  echo "No workspace configured, please set your WORKSPACE environment"
  exit
fi

BUILDENV=`mktemp -d /tmp/mageteststand.XXXXXXXX`

echo "Using build directory ${BUILDENV}"

# TODO: revert it to the original path after debugging
git clone https://github.com/gpaddis/MageTestStand.git -b "install-module-dependencies" "${BUILDENV}"
cp -rf "${WORKSPACE}" "${BUILDENV}/.modman/"

MODULE_NAME=${WORKSPACE##*/}
${BUILDENV}/install.sh $MODULE_NAME

if [ -d "${WORKSPACE}/vendor" ] ; then
  cp -rf ${WORKSPACE}/vendor/* "${BUILDENV}/vendor/"
fi

cd ${BUILDENV}/htdocs

if [ -f ${BUILDENV}/vendor/bin/phpunit ] ; then
    PHPUNIT_BIN="${BUILDENV}/vendor/bin/phpunit"
elif [ -f ${BUILDENV}/bin/phpunit ] ; then
    PHPUNIT_BIN="${BUILDENV}/bin/phpunit"
fi

$PHPUNIT_BIN --colors -d display_errors=1