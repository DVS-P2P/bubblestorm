#!/usr/bin/env bash

DIR="distCheck"
EXP_DIR="exp"

VIRTUALENV_BIN="virtualenv-3.2"
VIRTUALENV_DIR="env"

# build package
./setup.py sdist

# cleanup testfolder
rm -r "$DIR"
mkdir -p "$DIR/$EXP_DIR"

OLD_DIR=$(pwd)
cd "$DIR/$EXP_DIR"

# check correct path
CWD=$(pwd)
if [ "$OLD_DIR/$DIR/$EXP_DIR" != "$CWD" ] ; then
	echo "an error occur" ; exit -1
fi

# check spaces in path - virtualenv cant use this path!
case "$CWD" in  
     *\ * )
           echo "**error: path contains spaces - virtualenv cant use this path!"
           pwd
           exit -1
          ;;
esac

# init testfolder
ln -s ../../simulator ../simulator
"$VIRTUALENV_BIN" "$VIRTUALENV_DIR"

# find last package
PACKAGE_FILE=$(find ../../dist -type f -maxdepth 1 | sort | tail -n 1)

echo $PACKAGE_FILE
export PATH="./$VIRTUALENV_DIR/bin:$PATH"

# install package
"./$VIRTUALENV_DIR/bin/pip" install "$PACKAGE_FILE"

# init testbed
"./$VIRTUALENV_DIR/bin/python" -m testbed.init

# create symlink to installed testbed
ln -s env/lib/python3.2/site-packages/testbed installedTestbed

make

./run.sh -d experiment.db -e kv-managed
