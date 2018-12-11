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
%CC                  cc
%CFLAGS              -O0
%CPP	               cpp
%FC	                 ftn
%FCFLAGS             $(case $PE_ENV in (GNU) echo '-fdefault-real-8 -O3 -funroll-all-loops -fcray-pointer -ffree-line-length-none';; (CRAY) echo '-em -s real64 -s integer32  -O2 -hflex_mp=intolerant -e0 -ez';; esac)
%FFLAGS              %FCFLAGS
%LD                  ftn
%LDFLAGS             -hbyteswapio
%FPPFLAGS            -P -C -traditional-cpp
%AR                  ar
%ARFLAGS             -r
%MK                  make

%NCDF_HOME           $NETCDF_DIR
%HDF5_HOME           $HDF5_DIR
%XIOS_HOME           $(find_root xios)
%OASIS_HOME          /not/defined
%NCDF_INC            -I%NCDF_HOME/include -I%HDF5_HOME/include
%NCDF_LIB            -L%NCDF_HOME/lib -lnetcdff -lnetcdf
%XIOS_INC            -I%XIOS_HOME/inc
%XIOS_LIB            -L%XIOS_HOME/lib -lxios
%OASIS_INC           -I%OASIS_HOME/build/lib/mct -I%OASIS_HOME/build/lib/psmile.MPI1
%OASIS_LIB           -L%OASIS_HOME/lib -lpsmile.MPI1 -lmct -lmpeu -lscrip
%USER_INC            %XIOS_INC %OASIS_INC %NCDF_INC
%USER_LIB            %XIOS_LIB %OASIS_LIB %NCDF_LIB
EOF


# Test

./makenemo -m gnu-sisu.csc.fi -r 'GYRE_PISCES' -n 'MY_GYRE_PISCES'
