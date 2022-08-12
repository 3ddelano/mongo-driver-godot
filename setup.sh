#!/bin/bash

platform=$1
target=${2:-release}

bin_dir="addons/mongo-driver-godot/bin/"

if [[ $platform == "x11" ]] || [[ $platform == "linux" ]]; then
    platform="linux"
    bin_dir="$bin_dir/x11"
elif [[ $platform == "osx" ]]; then
    bin_dir="$bin_dir/osx"
else
    echo No valid platform provided
    exit 1
fi

echo Building $target target

if [ ! -d "bin" ]; then
    mkdir bin
fi

if [ ! -d "addons/mongo-driver-godot/bin/" ]; then
    mkdir -p addons/mongo-driver-godot/bin
fi

if [ ! -d "bin/godot-cpp" ]; then mkdir "bin/godot-cpp"; fi
if [ ! -d "bin/mongo-c-driver" ]; then mkdir "bin/mongo-c-driver"; fi
if [ ! -d "bin/mongo-cxx-driver" ]; then mkdir "bin/mongo-cxx-driver"; fi
if [ ! -d "$bin_dir" ]; then mkdir "$bin_dir"; fi

bin_godot_cpp_dir="$PWD/bin/godot-cpp"
bin_mongo_c_driver_dir="$PWD/bin/mongo-c-driver"
bin_mongo_cxx_driver_dir="$PWD/bin/mongo-cxx-driver"
project_bin_win_dir="$PWD/addons/mongo-driver-godot/bin/"

echo Builing godot-cpp $target lib

pushd thirdparty/godot-cpp
CORES=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || sysctl -n hw.ncpu)
scons platform=$platform target=$target generate_bindings=yes -j$CORES
cp ./bin/libgodot-cpp.* $bin_godot_cpp_dir
popd

BUILD_TYPE="Release"
CONFIG_TYPE="RelWithDebInfo"
if [[ $target == "debug" ]]; then
    BUILD_TYPE="Debug"
    CONFIG_TYPE="Debug"
fi
export BUILD_TYPE

echo Installing mongo-c-driver

pushd thirdparty/mongo-c-driver
python build/calc_release_version.py > VERSION_CURRENT
cat VERSION_CURRENT

mkdir cmake-build
cd cmake-build
cmake ..                                           \
    -DENABLE_EXAMPLES=OFF                          \
    -DENABLE_TESTS=OFF                             \
    -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF        \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE                 \
    -DCMAKE_INSTALL_PREFIX=$bin_mongo_c_driver_dir \
    -DCMAKE_PREFIX_PATH=$bin_mongo_c_driver_dir 

sudo cmake --build . --config MinSizeRel --target install
popd

echo Installing mongo-cxx-driver

pushd thirdparty/mongo-cxx-driver/build
cmake ..                                             \
    -DENABLE_TESTS=OFF                               \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE                   \
    -DLIBMONGOC_DIR==$bin_mongo_c_driver_dir         \
    -DCMAKE_PREFIX_PATH=$bin_mongo_c_driver_dir      \
    -DCMAKE_INSTALL_PREFIX=$bin_mongo_cxx_driver_dir

sudo cmake --build . --config $CONFIG_TYPE --target install
popd

echo Copying dependencies to project
cp $bin_mongo_cxx_driver_dir/lib/* $bin_dir || true
cp $bin_mongo_c_driver_dir/lib/* $bin_dir   || true