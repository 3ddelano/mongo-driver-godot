@echo off
title Setup for mongo-driver-godot
setlocal ENABLEDELAYEDEXPANSION

set build_target="%~1"
set target="release"
echo Building using %build_target% compiler and %target% target

if not exist "bin/godot-cpp" mkdir "bin/godot-cpp"
if not exist "bin/mongo-c-driver" mkdir "bin/mongo-c-driver"
if not exist "bin/mongo-cxx-driver" mkdir "bin/mongo-cxx-driver"
if not exist "addons/mongo-driver-godot/bin/win64" mkdir "addons/mongo-driver-godot/bin/win64"

pushd %CD%
cd "bin/godot-cpp"
set bin_godot_cpp_dir=%CD%
popd
pushd %CD%
cd "bin/mongo-c-driver"
set bin_mongo_c_driver_dir=%CD%
popd
pushd %CD%
cd "bin/mongo-cxx-driver"
set bin_mongo_cxx_driver_dir=%CD%
popd
pushd %CD%
cd addons/mongo-driver-godot/bin/win64
set project_bin_win_dir=%CD%
popd

set godot_target="release"
if %TARGET%=="debug" (set godot_target="debug")

@REM Check if godot-cpp is built
IF EXIST "bin/godot-cpp/libgodot-cpp.windows.%TARGET%.64.lib" (
    echo Found godot-cpp %TARGET% lib
) ELSE (
    echo Builing godot-cpp %TARGET% lib
    pushd %CD%
    cd thirdparty/godot-cpp
    scons platform=windows target=%godot_target% generate_bindings=yes -j8
    move /Y ".\bin\libgodot-cpp.windows.release.64.lib" %bin_godot_cpp_dir%
    popd
)


REM Installation instructions from:
REM http://mongoc.org/libmongoc/current/installing.html#preparing-a-build-from-a-git-repository-clone
echo Installing mongo-c-driver
pushd %CD%
cd thirdparty/mongo-c-driver
@REM python -u build/calc_release_version.py > VERSION_CURRENT
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
cmake -G %build_target% -DCMAKE_CXX_STANDARD=17 -DCMAKE_CXX_FLAGS="/Zc:__cplusplus" -DENABLE_TESTS=OFF -DCMAKE_BUILD_TYPE=%mongocxx_target% -DLIBMONGOC_DIR==%bin_mongo_c_driver_dir% -DLIBBSON_DIR==%bin_mongo_c_driver_dir% -DCMAKE_PREFIX_PATH=%bin_mongo_c_driver_dir% -DCMAKE_INSTALL_PREFIX=%bin_mongo_cxx_driver_dir% ..
set mongocxx_config_type="RelWithDebInfo"
if %TARGET%=="debug" (set mongocxx_config_type="Debug")
cmake --build . --config %mongocxx_config_type% --target install
popd


echo Copying dlls to project
robocopy %bin_mongo_c_driver_dir%\bin %project_bin_win_dir% /NFL /NDL /NJH /NJS /nc /ns /np /IS /IT
robocopy %bin_mongo_cxx_driver_dir%\bin %project_bin_win_dir% /NFL /NDL /NJH /NJS /nc /ns /np /IS /IT

set error = %ERRORLEVEL%
if %error% LEQ 7 (exit /b 0) else (exit /b %error%)