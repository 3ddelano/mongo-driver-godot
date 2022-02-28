@echo off
title Running custom tester
set QUIT_ON_TEST_COMPLETE=1
godot --no-window -d --path ./project addons/tester/Test.tscn %*