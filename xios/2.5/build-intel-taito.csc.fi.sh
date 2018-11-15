#!/bin/bash

module purge
module load git intel/18.0.1  intelmpi/18.0.1 hdf5-par/1.10.2 netcdf4/4.6.1

ln -s $PWD/nemo/4.0/arch-intel_CSC.fcm xios-2.5/arch/arch-intel_CSC.cfm
ln -s $PWD/nemo/4.0/arch-intel_CSC.fcm xios-2.5/arch/arch-intel_CSC.fcm

