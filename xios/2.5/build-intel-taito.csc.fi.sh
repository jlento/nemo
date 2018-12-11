#!/bin/bash

set -ex

# XIOS build and install instructions for taito.csc.fi
#
# 2018-12-11, Juha Lento, CSC
#
# The following build instruction is based on:
# - http://forge.ipsl.jussieu.fr/ioserver/wiki/documentation

xios_version=2.5

compiler=intel
compiler_version=18.0.1
mpi=intelmpi
mpi_version=18.0.1

module purge
module load ${compiler}/${compiler_version} ${mpi}/${mpi_version}
module load git hdf5-par netcdf4

cd $TMPDIR
svn co http://forge.ipsl.jussieu.fr/ioserver/svn/XIOS/branchs/xios-${xios_version}
xios_revision=$(svn info | sed -n 's/Revision: \([0-9]\+\)/\1/p')

# Build

cd xios-${xios_version}
cat > arch/arch-${compiler}-taito.csc.fi.fcm <<EOF
%CCOMPILER      mpiCC
%FCOMPILER      mpif90
%LINKER         mpif90
%BASE_CFLAGS    $(case $compiler in (intel|gnu) echo '-ansi';;esac)
%PROD_CFLAGS    -O3 -DBOOST_DISABLE_ASSERTS
%BASE_FFLAGS    -D__NONE__ $(case $compiler in (gnu) echo '-ffree-line-length-none';; esac)
%PROD_FFLAGS    -O3
%BASE_INC       -D__NONE__
%BASE_LD        -lstdc++
%CPP            cpp
%FPP            cpp -P -CC
%MAKE           make
EOF

cat > arch/arch-${compiler}-taito.csc.fi.path <<EOF
NETCDF_INCDIR="-I${NETCDF_DIR}/include"
NETCDF_LIBDIR="-L${NETCDF_DIR}/lib"
NETCDF_LIB="-lnetcdf -lnetcdff"
HDF5_INCDIR="-I${H5ROOT}/include"
HDF5_LIBDIR="-L${H5ROOT}/lib"
HDF5_LIB="-lhdf5_hl -lhdf5 -lhdf5 -lz -lcurl"
EOF

./make_xios --arch ${compiler}-taito.csc.fi --job 8

install_dir=/appl/earth/xios/${xios_version}.${xios_revision}/${compiler}-${compiler_version}/${mpi}-${mpi_version}
mkdir -p ${install_dir}
cp -r {bin,lib,inc} ${install_dir}/


module_dir=/appl/modulefiles/MPI/${compiler}/${compiler_version}/${mpi}/${mpi_version}/xios
mkdir -p ${module_dir}
cat > ${module_dir}/${xios_version}.${xios_revision}.lua <<EOF
help([[
        xios library, version ${xios_version}, revision ${xios_revision}.

        Modifies: LD_LIBRARY_PATH, XIOS_DIR
]])

local ncroot = '${install_dir}'

always_load('hdf5-par/1.10.2')
always_load('netcdf4/4.6.1')
prepend_path( 'LD_LIBRARY_PATH', pathJoin( ncroot, 'lib' ) )
setenv( 'XIOS_DIR', ncroot )
EOF

chmod -R g+rwX,o+rX /appl/earth/xios ${module_dir}
