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
Checked out revision 6542.
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

### Get a bash helper for editing configuration files

```
source <(curl -s https://raw.githubusercontent.com/jlento/nemo/master/fixfcm.bash)
```

...or if you have a buggy bash 3.2...

```
wget https://raw.githubusercontent.com/jlento/nemo/master/fixfcm.bash; source fixfcm.bash
```


### Edit (create) configuration files

```
cd ../NEMOGCM/CONFIG
fixfcm < ../ARCH/arch-XC40_METO.fcm > ../ARCH/arch-MY_CONFIG.fcm \
	NCDF_HOME="$NETCDF_DIR" \
	HDF5_HOME="$HDF5_DIR" \
	XIOS_HOME="$(readlink -f ../../xios-2.0)"
```


### Build

```
./makenemo -m MY_CONFIG -r GYRE_XIOS -n MY_GYRE add_key "key_nosignedzero"
```


Run first GYRE test
-------------------

### Preapare input files

```
cd MY_GYRE/EXP00
sed -i '/using_server/s/false/true/' iodef.xml
sed -i '/&nameos/a ln_useCT = .false.' namelist_cfg
sed -i '/&namctl/a nn_bench = 1' namelist_cfg
```

### Run the experiment interactively

```
aprun -n 4 ../BLD/bin/nemo.exe : -n 2 ../../../../xios-2.0/bin/xios_server.exe
```


GYRE configuration with higher resolution
-----------------------------------------

### Modify configuration

Parameter `jp_cfg` controls the resolution.

```
rm -f time.step solver.stat output.namelist.dyn ocean.output  slurm-*  GYRE_* mesh_mask_00*
jp_cfg=4
sed -i -r \
    -e 's/^( *nn_itend *=).*/\1 21600/' \
    -e 's/^( *nn_stock *=).*/\1 21600/' \
    -e 's/^( *nn_write *=).*/\1 1000/' \
    -e 's/^( *jp_cfg *=).*/\1 '"$jp_cfg"'/' \
    -e 's/^( *jpidta *=).*/\1 '"$(( 30 * jp_cfg +2))"'/' \
    -e 's/^( *jpjdta *=).*/\1 '"$(( 20 * jp_cfg +2))"'/' \
    -e 's/^( *jpiglo *=).*/\1 '"$(( 30 * jp_cfg +2))"'/' \
    -e 's/^( *jpjglo *=).*/\1 '"$(( 20 * jp_cfg +2))"'/' \
    namelist_cfg

```


### Run the experiment as a SLURM batch job

```
sbatch -N 3 -p test -t 30 << EOF
#!/bin/bash
aprun -n 48 ../BLD/bin/nemo.exe : -n 8 ../../../../xios-2.0/bin/xios_server.exe
EOF
```
