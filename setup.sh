#!/usr/bin/bash

build_target="Unix Makefiles"
TARGET="debug"
echo Building using "$build_target" compiler and $TARGET target

mkdir -p bin/mongo-c-driver
mkdir -p bin/mongo-cxx-driver
mkdir -p mongo-driver-godot/bin/linux

pushd $(pwd)
cd "bin/mongo-c-driver"
bin_mongo_c_driver_dir=$(pwd)
popd
pushd $(pwd)
cd "bin/mongo-cxx-driver"
bin_mongo_cxx_driver_dir=$(pwd)
popd
pushd $(pwd)
cd addons/mongo-driver-godot/bin/win64
project_bin_win_dir=$(pwd)
popd


echo Generating bindings for godot-cpp
pushd $(pwd)
cd thirdparty/godot-cpp
godot_target="release"
if [ "$TARGET" == "debug" ]; then
    godot_target="debug"
fi
# scons platform=linux target=$godot_target generate_bindings=yes -j8
popd

# Installation instructions from:
# http://mongoc.org/libmongoc/current/installing.html#preparing-a-build-from-a-git-repository-clone
echo Installing mongo-c-driver
pushd $(pwd)
cd thirdparty/mongo-c-driver
# python3 build/calc_release_version.py > VERSION_CURRENT
mkdir -p cmake-build
cd cmake-build
mongoc_target="Release"
if [ "$TARGET" == "debug" ]; then
    mongoc_target="Debug"
fi
# cmake -G "$build_target" -DENABLE_EXAMPLES=OFF -DENABLE_TESTS=OFF -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF -DCMAKE_BUILD_TYPE=$mongoc_target -DCMAKE_INSTALL_PREFIX=$bin_mongo_c_driver_dir -DCMAKE_PREFIX_PATH=$bin_mongo_c_driver_dir ..
mongoc_config_type="RelWithDebInfo"
if [ "$TARGET" == "debug" ]; then
    mongoc_config_type="Debug"
fi
# cmake --build . --config $mongoc_config_type --target install
popd


# Installation instructions from:
# http://mongocxx.org/mongocxx-v3/installation/windows/#step-4-configure-the-driver
echo Installing mongo-cxx-driver
pushd $(pwd)
mkdir -p thirdparty/mongo-cxx-driver/build
cd thirdparty/mongo-cxx-driver/build
mongocxx_target="Release"
if [ "$TARGET" == "debug" ]; then
    mongocxx_target="Debug"
fi
CC=gcc CXX=g++ cmake ..                                            \
-DCMAKE_BUILD_TYPE=$mongocxx_target                      \
-DLIBMONGOC_DIR=$bin_mongo_c_driver_dir         \
-DLIBBSON_DIR=$bin_mongo_c_driver_dir         \
-DCMAKE_INSTALL_PREFIX=$bin_mongo_cxx_driver_dir
# cmake -G "$build_target" -DCMAKE_INSTALL_RPATH=$bin_mongo_c_driver_dir -DBSONCXX_POLY_USE_MNMLSTC=1 -DENABLE_TESTS=OFF -DCMAKE_BUILD_TYPE=$mongocxx_target -DLIBMONGOC_DIR==$bin_mongo_c_driver_dir -DLIBBSON_DIR==$bin_mongo_c_driver_dir -DCMAKE_INSTALL_PREFIX=$bin_mongo_cxx_driver_dir ..
mongocxx_config_type="RelWithDebInfo"
if [ $TARGET=="debug" ]; then
    mongocxx_config_type="Debug"
fi
cmake --build . --config $mongocxx_config_type --target install

echo Copying dlls to project
cp $bin_mongo_c_driver_dir/bin $project_bin_win_dir
cp $bin_mongo_cxx_driver_dir/bin $project_bin_win_dir
