#!/bin/bash

set -ex

# XIOS build and install instructions for sisu.csc.fi
#
# 2018-11-15, Juha Lento, CSC
#
# The following build instruction is based on:
# - http://forge.ipsl.jussieu.fr/ioserver/wiki/documentation


# Environment setup

module load svn craypkg-gen cray-hdf5-parallel cray-netcdf-hdf5parallel

XIOS_VERSION=2.5
if [[ "$PE_ENV" = "GNU" ]]; then
    PE_LEVEL=5.1
fi


# Checkout sources

cd $TMPDIR
svn co http://forge.ipsl.jussieu.fr/ioserver/svn/XIOS/branchs/xios-${XIOS_VERSION}


# Build

cd xios-${XIOS_VERSION}
cat > arch/arch-gnu-sisu.csc.fi.fcm <<EOF
%CCOMPILER      CC
%FCOMPILER      ftn
%LINKER         ftn
%BASE_CFLAGS    $(case $PE_ENV in GNU) echo '-ansi';;esac)
%PROD_CFLAGS    -O3 -DBOOST_DISABLE_ASSERTS
%BASE_FFLAGS    -D__NONE__ $(case $PE_ENV in CRAY) echo '-em -m 4 -e0 -eZ';;GNU) echo '-ffree-line-length-none';;esac)
%PROD_FFLAGS    -O3
%BASE_INC       -D__NONE__
%BASE_LD        -lstdc++
%CPP            cpp
%FPP            cpp -P -CC
%MAKE           make
EOF

./make_xios --arch sisu.csc.fi --job 8 || true
$(case $PE_ENV in CRAY) ./make_xios --arch sisu.csc.fi;;esac)

# Manually copy files...

mkdir -p  /appl/climate/xios/${XIOS_VERSION}/${PE_ENV}/${PE_LEVEL}
cp -r {bin,lib,inc} /appl/climate/xios/${XIOS_VERSION}/${PE_ENV}/${PE_LEVEL}


# Generate pkgconfig file xios.pc
#
# Remember to add nonstandard "inc" directory to CRAY_includedir

craypkg-gen -p /appl/climate/xios/${XIOS_VERSION}/${PE_ENV}/${PE_LEVEL}/
sed -i "s:${PE_ENV}_includedir=.*:${PE_ENV}_includedir= -I\${${PE_ENV}_prefix}/inc:" /appl/climate/xios/${XIOS_VERSION}/${PE_ENV}/${PE_LEVEL}/lib/pkgconfig/xios.pc


# Generate modulefile and move it to system location

craypkg-gen -m /appl/climate/xios/${XIOS_VERSION}
cp /appl/climate/modulefiles/xios/${XIOS_VERSION} /appl/modulefiles/xios/

# Fix permissions

chmod -R a+rX,g+rwX /appl/climate/xios
chmod -R a+rX,g+rwX /appl/modulefiles/xios
