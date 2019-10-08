@echo off
tbsetup
cls
del tetris.zip
pkzip25 -add -attributes=all -directories=relative tetris *.*
