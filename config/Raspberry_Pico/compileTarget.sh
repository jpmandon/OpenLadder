#!/bin/sh
$1fpc/bin/x86_64-linux/ppcrossarm -n \
-Tembedded \
-Parm \
-CpARMV6M \
-MObjFPC \
-Scghi \
-O1 \
-gw2 \
-l \
-va \
-Fi$1rtl/* \
-Fi$1lib/arm-embedded \
-Fi$1fpc/units/arm-embedded/armv6m/eabi/rtl \
-Fi$1runtime \
-Fi$1config/$3 \
-Fl$1config/$3/include \
-Fl$1config/$3 \
-Fu$1examples/$2/ \
-Fu$1runtime \
-Fu$1config/$3/include \
-Fu$1config/$3 \
-Fu$1rtl/* \
-FU$1fpc/units/arm-embedded/armv6m/eabi/rtl \
-Fo$1projets/$2/lib/x86_64-linux \
-Fo$1config/Raspberry_Pico/include \
-FL$1config/Raspberry_Pico/include \
-FD$1cross/bin/arm-embedded \
-FEbin \
-o$2bin/runtime \
-Wpraspi_pico \
-Xu \
-al \
$2runtime.lpr
$1cross/bin/arm-embedded/elf2uf2 $2/bin/runtime.elf $2/bin/runtime.uf2

