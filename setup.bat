@echo off
title Setup for mongo-godot-driver
setlocal ENABLEDELAYEDEXPANSION

set build_target="Visual Studio 16 2019"
set target="release"
echo Building using %build_target% compiler and %target% target

mkdir "bin/mongo-c-driver"
mkdir "bin/mongo-cxx-driver"
mkdir "project/addons/mongo-godot-driver/bin/win64"

pushd %CD%
cd "bin/mongo-c-driver"
set bin_mongo_c_driver_dir=%CD%
popd
pushd %CD%
cd "bin/mongo-cxx-driver"
set bin_mongo_cxx_driver_dir=%CD%
popd
pushd %CD%
cd project/addons/mongo-godot-driver/bin/win64
set project_bin_win_dir=%CD%
popd


echo Generating bindings for godot-cpp
pushd %CD%
cd thirdparty/godot-cpp
set godot_target="release"
if %TARGET%=="debug" (set godot_target="debug")
scons platform=windows target=%godot_target% generate_bindings=yes -j8
popd


REM Installation instructions from:
REM http://mongoc.org/libmongoc/current/installing.html#preparing-a-build-from-a-git-repository-clone
echo Installing mongo-c-driver
pushd %CD%
cd thirdparty/mongo-c-driver
python build/calc_release_version.py > VERSION_CURRENT
mkdir cmake-build
cd cmake-build
set mongoc_target="Release"
if %TARGET%=="debug" (set mongoc_target="Debug")
cmake -G %build_target% -DENABLE_EXAMPLES=OFF -DENABLE_TESTS=OFF -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF -DCMAKE_BUILD_TYPE=%mongoc_target% -DCMAKE_INSTALL_PREFIX=%bin_mongo_c_driver_dir% -DCMAKE_PREFIX_PATH=%bin_mongo_c_driver_dir% ..
set mongoc_config_type="RelWithDebInfo"
if %TARGET%=="debug" (set mongoc_config_type="Debug")
cmake --build . --config MinSizeRel --target install
popd


REM Installation instructions from:
REM http://mongocxx.org/mongocxx-v3/installation/windows/#step-4-configure-the-driver
echo Installing mongo-cxx-driver
pushd %CD%
cd thirdparty/mongo-cxx-driver/build
set mongocxx_target="Release"
if %TARGET%=="debug" (set mongocxx_target="Debug")
cmake -G %build_target% -DCMAKE_CXX_STANDARD=17 -DCMAKE_CXX_FLAGS="/Zc:__cplusplus" -DENABLE_TESTS=OFF -DCMAKE_BUILD_TYPE=%mongocxx_target% -DLIBMONGOC_DIR==%bin_mongo_c_driver_dir% -DLIBBSON_DIR==%bin_mongo_c_driver_dir% -DCMAKE_INSTALL_PREFIX=%bin_mongo_cxx_driver_dir% ..
set mongocxx_config_type="RelWithDebInfo"
if %TARGET%=="debug" (set mongocxx_config_type="Debug")
cmake --build . --config %mongocxx_config_type% --target install
popd

echo Copying dlls to project
robocopy %bin_mongo_c_driver_dir%\bin %project_bin_win_dir% /NFL /NDL /NJH /NJS /nc /ns /np /IS /IT
robocopy %bin_mongo_cxx_driver_dir%\bin %project_bin_win_dir% /NFL /NDL /NJH /NJS /nc /ns /np /IS /IT