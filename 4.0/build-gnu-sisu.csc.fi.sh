#!/bin/bash

# Environment setup

module swap PrgEnv-cray PrgEnv-gnu
module load svn craypkg-gen cray-hdf5-parallel cray-netcdf-hdf5parallel xios/2.5

# Checkout sources

cd $TMPDIR
svn co http://forge.ipsl.jussieu.fr/nemo/svn/NEMO/trunk


# Configure architecture

cd trunk
cat > arch/arch-gnu-sisu.csc.fi.fcm <<EOF
%CC                  cc
%CFLAGS              -O0
%CPP	               cpp
%FC	                 ftn
%FCFLAGS             -fdefault-real-8 -O3 -funroll-all-loops -fcray-pointer -ffree-line-length-none
%FFLAGS              %FCFLAGS
%LD                  ftn
%LDFLAGS
%FPPFLAGS            -P -C -traditional
%AR                  ar
%ARFLAGS             rs
%MK                  make

%NCDF_HOME           $NETCDF_DIR
%HDF5_HOME           $HDF5_DIR
%XIOS_HOME           $(pkg-config --variable=${PE_ENV}_prefix xios)
%OASIS_HOME          /not/defined
%NCDF_INC            -I%NCDF_HOME/include -I%HDF5_HOME/include
%NCDF_LIB            -L%NCDF_HOME/lib -lnetcdff -lnetcdf
%XIOS_INC            -I%XIOS_HOME/inc
%XIOS_LIB            -L%XIOS_HOME/lib -lxios -lstdc++
%OASIS_INC           -I%OASIS_HOME/build/lib/mct -I%OASIS_HOME/build/lib/psmile.MPI1
%OASIS_LIB           -L%OASIS_HOME/lib -lpsmile.MPI1 -lmct -lmpeu -lscrip
%USER_INC            %XIOS_INC %OASIS_INC %NCDF_INC
%USER_LIB            %XIOS_LIB %OASIS_LIB %NCDF_LIB
EOF


# Test

./makenemo -m gnu-sisu.csc.fi -r 'GYRE' -n 'MY_GYRE' -j 8
