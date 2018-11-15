#!/bin/bash

module purge
module load git gcc/7.3.0  intelmpi/18.0.2 hdf5-par/1.8.20 netcdf4/4.6.1

ln -s $PWD/nemo/4.0/arch-GNU_CSC.fcm xios-2.5/arch/arch-GNU_CSC.cfm 
ln -s $PWD/nemo/4.0/arch-GNU_CSC.fcm xios-2.5/arch/arch-GNU_CSC.fcm 




cd xios-2.5
./make_xios -arch GNU_CSC --job 8
