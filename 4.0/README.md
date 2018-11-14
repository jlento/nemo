# Install nemo 4.0 beta in taito.csc.fi

Juha Lento, CSC, 2018-11-14

## Status

Currently builds with GNU compilers, should be possible with Intel, too. Intel
build of xios minimally started.

## The recipe

```bash
module purge

# module load git intel/18.0.1  intelmpi/18.0.1 hdf5-par/1.10.2 netcdf4/4.6.1

module load git gcc/7.3.0  intelmpi/18.0.2 hdf5-par/1.8.20 netcdf4/4.6.1

svn co ​http://forge.ipsl.jussieu.fr/ioserver/svn/XIOS/branchs/xios-2.5
svn co http://forge.ipsl.jussieu.fr/nemo/svn/NEMO/trunk
git clone https://github.com/jlento/nemo.git

# ln -s $PWD/nemo/4.0/arch-intel_CSC.fcm xios-2.5/arch/arch-intel_CSC.cfm 
# ln -s $PWD/nemo/4.0/arch-intel_CSC.fcm xios-2.5/arch/arch-intel_CSC.fcm 

ln -s $PWD/nemo/4.0/arch-GNU_CSC.fcm xios-2.5/arch/arch-GNU_CSC.cfm 
ln -s $PWD/nemo/4.0/arch-GNU_CSC.fcm xios-2.5/arch/arch-GNU_CSC.fcm 


# Fails to build 'xios_server.exe', but who cares. The xios library in 'lib/xios.a'

cd xios-2.5
./make_xios -arch GNU_CSC --job 8
cd ..

cd trunk

```
