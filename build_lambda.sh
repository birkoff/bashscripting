#!/usr/bin/env bash

# Lambda functions shall be in a separate directory name after the function name
# The main script shall be named as the directory {function}.py
#
# CLI Params
# $1 Function Name
# $2 List of dependencies to include in the buildfile (comma separated)
#
# Example:
# sh build_lambda.sh [function_name] [list,of,dependencies,like,requests]

function die() {
    >&2 printf "Error: %s!!!\n" "$@"
    exit 1
}

FUNCTION_NAME=$1
[[ -d ${FUNCTION_NAME} ]] || { die "Missing directory [$FUNCTION_NAME]!"; }

cd ${FUNCTION_NAME}

[[ -f ${FUNCTION_NAME}.py ]] || { die "Missing file [$FUNCTION_NAME.py]!"; }

## To bootstrap and install requirements create a virtual environment
[[ -d "env" ]] || { die "No virtual env, run: [ cd $FUNCTION_NAME && virtualenv env && cd .. ]"; }


echo "Create build Directory and copy files..."
timestamp=$(date +%s)
build_dir=./build/${timestamp}


mkdir -p ${build_dir}
cp -v ${FUNCTION_NAME}.py ${build_dir}/


echo "Installing dependencies..."
if [[ -f "requirements.txt" ]]; then
    env/bin/pip install -r requirements.txt -t ${build_dir}/
fi


# Create buildfile package
FUNCTION_DEPENDENCIES=$2
pushd ${build_dir}
echo "Create buildfile package..."
echo "zip -r buildfile.zip ${FUNCTION_NAME}.py ${FUNCTION_DEPENDENCIES//,/ }"
zip -r buildfile.zip ${FUNCTION_NAME}.py ${FUNCTION_DEPENDENCIES//,/ }
popd


# just for easy use
# remove old buildfile
rm -f ./build/buildfile.zip
cp ${build_dir}/buildfile.zip ./build/buildfile.zip
