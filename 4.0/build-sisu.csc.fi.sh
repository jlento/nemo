#!/bin/bash

# Environment setup

module load svn craypkg-gen cray-hdf5-parallel cray-netcdf-hdf5parallel xios/2.5

if [[ "$PE_ENV" = "GNU" ]]; then
    PE_LEVEL=5.1
fi


# Checkout sources

cd $TMPDIR
svn co http://forge.ipsl.jussieu.fr/nemo/svn/NEMO/trunk


# Configure architecture

find_root () {
    local regexp="-I[^ ]*${1}[^ ]*"
    [[ $(ftn -craype-verbose 2> /dev/null) =~ $regexp ]]
    echo ${BASH_REMATCH[1]}
}

cd trunk
cat > arch/arch-gnu-sisu.csc.fi.fcm <<EOF
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
