#!/bin/bash

set -e
set -x

rm -rf say/cmake-build-release
rm -rf hello/cmake-build-release


conan editable add say/ say/0.1@user/channel

pushd say
# Install into a subfolder, to avoid mixing generated files and source files
# in the same directory, and to make .gitignore easier to manage.
conan install . --install-folder=my_install
pushd cmake-build-release
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=conan/conan_toolchain.cmake
cmake --build .
popd
popd

mkdir hello/cmake-build-release
pushd hello/cmake-build-release
# This runs all of say's generators, and the output files are saved directly
# into say's source directory, not its generators directory. This is the
# behaviour that doesn't seem right to me.
conan install ..
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake
cmake --build .
./hello
popd

pushd say
# This fails
conan info . && echo "*** Conan info worked ***" || echo "*** Conan info failed ***"
rm graph_info.json
# This works
conan info . && echo "*** Conan info worked ***" || echo "*** Conan info failed ***"
popd

# Modification to code
pushd say/cmake-build-release
cp ../src/say2.cpp ../src/say.cpp
cmake --build .
popd

# build consumer again
pushd hello/cmake-build-release
cmake --build .
./hello
popd

conan editable remove say/0.1@user/channel
