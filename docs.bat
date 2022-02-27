@echo off
title Generate docs for mongo-godot-driver

pushd .
cd docs
doxygen

sphinx-build -b html . build

popd