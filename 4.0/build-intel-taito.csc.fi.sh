#!/bin/bash

set -ex

# NEMO build and install instructions for taito.csc.fi
#
# 2018-12-11, Juha Lento, CSC

nemo_version=4.0

compiler=intel
compiler_version=18.0.1
mpi=intelmpi
mpi_version=18.0.1

module purge
module load ${compiler}/${compiler_version} ${mpi}/${mpi_version}
module load svn hdf5-par netcdf4 xios


# Checkout sources

cd $WRKDIR/DONOTREMOVE
svn co http://forge.ipsl.jussieu.fr/nemo/svn/NEMO/trunk

cd trunk
nemo_revision=$(svn info | sed -n 's/Revision: \([0-9]\+\)/\1/p')

cat > arch/arch-${compiler}-taito.csc.fi.fcm <<EOF
%CC                  mpicc
%CFLAGS              -O0
%CPP	               cpp
%FC	                 mpif90
%FCFLAGS             $(case $compiler in (gnu) echo '-fdefault-real-8 -O3 -funroll-all-loops -fcray-pointer -ffree-line-length-none';; (intel) echo '-O3 -i4 -r8 -fp-model precise -fno-alias';; esac)
%FFLAGS              %FCFLAGS
%LD                  mpif90
%LDFLAGS
%FPPFLAGS            -P -C -traditional-cpp
%AR                  ar
%ARFLAGS             rs
%MK                  make

%NCDF_HOME           $NETCDF_DIR
%HDF5_HOME           $H5ROOT
%XIOS_HOME           $XIOS_DIR
%OASIS_HOME          /not/defined
%NCDF_INC            -I%NCDF_HOME/include
%NCDF_LIB            -L%NCDF_HOME/lib -lnetcdff -lnetcdf -L%HDF5_HOME/lib -lhdf5_hl -lhdf5 -lhdf5
%XIOS_INC            -I%XIOS_HOME/inc
%XIOS_LIB            -L%XIOS_HOME/lib -lxios -lstdc++

%USER_INC            %XIOS_INC %NCDF_INC
%USER_LIB            %XIOS_LIB %NCDF_LIB
EOF


./makenemo -j 8 -m ${compiler}-taito.csc.fi -r 'GYRE_PISCES' -n 'MY_GYRE_PISCES'
