NEMO 3.6, GYRE configuration
============================

juha.lento@csc.fi, 2016-05-16

Build and test documentation for NEMO 3.6 in GYRE
configuration. Example commands are tested in CSC's Cray XC40,
`sisu.csc.fi`.


Download NEMO and XIOS sources
------------------------------

### Register

http://www.nemo-ocean.eu


### Check out NEMO sources


```
svn --username USERNAME --password PASSWORD --no-auth-cache co http://forge.ipsl.jussieu.fr/nemo/svn/branches/2015/nemo_v3_6_STABLE/NEMOGCM
...
Checked out revision 6536.
```


### Check out XIOS2 sources

http://www.nemo-ocean.eu/Using-NEMO/User-Guides/Basics/XIOS-IO-server-installation-and-use

```
svn co -r819 http://forge.ipsl.jussieu.fr/ioserver/svn/XIOS/trunk xios-2.0
```


Build XIOS
----------

### Build environment

Xios requires Netcdf4.

```
module load cray-hdf5-parallel cray-netcdf-hdf5parallel
```


### Build command

http://forge.ipsl.jussieu.fr/ioserver/wiki/documentation

```
cd xios-2.0
./make_xios --job 8 --arch XC30_Cray
```

...need to be rerun without `--job 8` and test suite is broken, but library got built?


Build NEMO 3.6 in GYRE configuration
------------------------------------

### Edit (create) configuration files

```
cd ../NEMOGCM/CONFIG
source <(curl -s https://raw.githubusercontent.com/jlento/nemo/master/fixfcm.bash)
fixfcm < ../ARCH/arch-XC40_METO.fcm > ../ARCH/arch-MY_CONFIG.fcm \
	NCDF_HOME="$NETCDF_DIR" \
	HDF5_HOME="$HDF5_DIR" \
	XIOS_HOME="$(readlink -f ../../xios-2.0)"
```


### Build

```
./makenemo -m MY_CONFIG -r GYRE_XIOS -n MY_GYRE
```

Run first GYRE test
-------------------

```
cd MY_GYRE/EXP00
aprun -n 4 ./opa
```

##############################
# Have a look at the results #
##############################

cd ../../../TOOLS/
./maketools -n REBUILD

cd ../CONFIG/MY_GYRE/EXP00/
sed -i.orig '101s/.*/aprun -n 1 &/' ../../../TOOLS/REBUILD/rebuild
../../../TOOLS/REBUILD/rebuild -o GYRE_5d_00010101_00011230_grid_W.nc GYRE_5d_00010101_00011230_grid_W_????.nc
ncview GYRE_5d_00010101_00011230_grid_W.nc

########################
# Download NEMO source #
########################

wget http://www.prace-ri.eu/UEABS/NEMO/NEMO_Source.tar.gz

# Extract only experiment configuration
tar --wildcards -x -v -f NEMO_Source.tar.gz 'NEMOGCM/CONFIG/ORCA*'

##############################
# Download PRACE TEST Case A #
##############################

cd ../../../..
wget http://www.prace-ri.eu/UEABS/NEMO/NEMO_TestCaseA.tar.gz
tar -x -v --strip-components=1 -f NEMO_TestCaseA.tar.gz

#########################################
# Build PRACE Test Case A configuration #
#########################################

cd NEMOGCM/CONFIG/

cp ORCA12.L75-PRACE/cpp_ORCA12.L75-PRACE.fcm ORCA12.L75-PRACE/cpp_ORCA12.L75-PRACE.fcm.orig
sed 's/.*/& key_nosignedzero/' < ORCA12.L75-PRACE/cpp_ORCA12.L75-PRACE.fcm.orig \
    > ORCA12.L75-PRACE/cpp_ORCA12.L75-PRACE.fcm

./makenemo -m MY_CONFIG -n ORCA12.L75-PRACE

#######################################
# Run PRACE Test Case A configuration #
#######################################

cd ORCA12.L75-PRACE/EXP00
ln -s ../../../../DATA_CONFIG_ORCA12/* .
ln -s ../../../../FORCING/* .
test -f namelist.orig || cp namelist namelist.orig

fixnml() {
    local name value prog=""
    for arg in "$@"; do
        name="${arg%%=*}"
	value=$(printf %q "${arg#*=}")
	value="${value//\//\/}"
        prog="s/(^ *${name} *=).*/\\1 ${value}/"$'\n'"$prog"
    done
    sed -r -e "$prog"
}

fixnml cn_dirout="${WRKDIR}/ORCA12.L75-PRACE-DIMGPROC.1" < namelist.orig > namelist

aprun -n 16 opa
