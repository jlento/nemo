# NEMO 4.0 build instructions for puhti.csc.fi

Juha Lento, CSC, 2019-09-30

```console
svn co https://forge.ipsl.jussieu.fr/ioserver/svn/XIOS/branchs/xios-2.5
svn co https://forge.ipsl.jussieu.fr/nemo/svn/NEMO/releases/release-4.0
```

## Build

The build commands for different compilers and machines are in files
`build-<compiler>-<host>.sh`. The build instructions for xios-2.5 dependency are
in subdirectory xios/2.5, if the library is not already available.
