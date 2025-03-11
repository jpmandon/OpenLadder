#!/bin/sh
$1fpc/bin/x86_64-linux/ppcx64 \
-MObjFPC \
-Scghi \
-Cg \
-O1 \
-g \
-gl \
-l \
-va \
-Fi$1config/LinuxSimulation \
-Fu$1fpc/units/x86_64-linux/rtl \
-Fu$1fpc/units/x86_64-linux/fcl-base \
-Fu$1runtime \
-Fu$1config/LinuxSimulation \
-FU$2lib \
-Fo$2lib/x86_64-linux \
-FE. \
-o$2runtime \
$2runtime.lpr

