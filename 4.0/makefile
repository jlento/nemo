# Makefile for Xios-2.5
#
# 1) Load environment (in puhti.csc.fi)
#      module load intel/19.0.4 hpcx-mpi/2.4.0 intel-mkl/2019.0.4 makedepf90  boost/1.68.0-mpi hdf5/1.10.4-mpi netcdf/4.7.0 netcdf-fortran/4.4.4
# 2) Edit this file as appropriate
# 3) Copy this file to <xios-2.5 root dir>
# 4) Move to build directory
# 5) Run make
#      make -f <xios-2.5 root dir>/makefile -j 8

# To include oasis, add -DUSE_OMCT wherever there is -DUSING_NETCDF_PAR, and
# -loasis wherever there is -lnetcdf, or about so :)

XIOS_ROOT  = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

INCSRC     = inc src/io src/transformation src/transformation/Functions \
             extern/blitz extern/rapidxml/include
CXXSRC     = src src/date src/filter src/functor src/interface/c \
             src/interface/c_attr src/io src/node src/parse_expr \
             src/transformation src/transformation/Functions src/type \
             extern/blitz/src extern/remap/src
HPPSRC     = src/interface/fortran src/interface/fortran_attr src/io
FSRC       = src src/interface/fortran src/interface/fortran_attr

INCLUDES   = $(patsubst %,-I$(XIOS_ROOT)%,$(INCSRC)) \
             -I$(BOOST_INSTALL_ROOT)/include

LDFLAGS    = -L$(NETCDF_INSTALL_ROOT)/lib
LIBS       = -lnetcdf -lstdc++

CXX        = mpiCC
CXXFLAGS   = -ansi -xHost -DBOOST_DISABLE_ASSERTS -DUSING_NETCDF_PAR \
             $(INCLUDES)

FC         = mpif90
FCFLAGS    = -xHost -DBOOST_DISABLE_ASSERTS -DUSING_NETCDF_PAR $(INCLUDES)

AR         = ar
MAKEDEPF90 = makedepf90

vpath %.cpp $(XIOS_ROOT)$(subst $() $(),:$(XIOS_ROOT),$(CXXSRC))
vpath %.f90 $(XIOS_ROOT)$(subst $() $(),:$(XIOS_ROOT),$(FSRC))
vpath %.F90 $(XIOS_ROOT)$(subst $() $(),:$(XIOS_ROOT),$(FSRC))
vpath %.hpp $(XIOS_ROOT)$(subst $() $(),:$(XIOS_ROOT),$(HPPSRC))

FSRC       = $(wildcard $(XIOS_ROOT)src/interface/fortran/*.f90) \
             $(wildcard $(XIOS_ROOT)src/interface/fortran/*.F90) \
             $(wildcard $(XIOS_ROOT)src/interface/fortran_attr/*.f90) \
             $(wildcard $(XIOS_ROOT)src/interface/fortran_attr/*.F90)  

include objects.mk

.PHONY: all clean

all: libxios.a xios_server.exe

libxios.a: $(OBJECTS__blitz) $(OBJECTS__remap) $(OBJECTS__xios)
	$(AR) rs $@ $^

xios_server.exe: server_main.o libxios.a
	$(FC) $(FCFLAGS) -o $@ $< -L. -lxios -lnetcdf -lstdc++

%.o : %.cpp
	$(CXX) -c $(CXXFLAGS) $<

%.o : %.f90
	$(FC) -c $(FCFLAGS) $<

%.o : %.F90
	$(FC) -c $(FCFLAGS) $<

realclean: clean
	rm -f fortran.deps objects.mk

clean:
	rm -f *.o *.mod libxios.a xios_server.exe

fxios_oasis_init.o : oasis_interface.F90
	$(FC) -c $(FCFLAGS) -o $@ $<

mod_wait.o: wait.f90
	$(FC) -c $(FCFLAGS) -o $@ $<


netcdfinterface.o: netCdfInterface.cpp netCdfException.hpp netCdfInterface.hpp
	$(CXX) -c $(CXXFLAGS) -o $@ $<

netcdfinterface_decl.o: netCdfInterface_decl.cpp netCdfInterface_impl.hpp
	$(CXX) -c $(CXXFLAGS) -o $@ $<

gridremap.o: gridRemap.cpp
	$(CXX) -c $(CXXFLAGS) -o $@ $<

timerremap.o: timerRemap.cpp
	$(CXX) -c $(CXXFLAGS) -o $@ $<

iduplicate_scalar_to_axis.o: iduplicate_scalar_to_axis_interface.F90 duplicate_scalar_to_axis_interface.o
	$(FC) -c $(FCFLAGS) -o $@ $<

server_main.o: xios_server.f90 xios.o
	$(FC) -c $(FCFLAGS) -o $@ $<

fortran.deps:
	$(MAKEDEPF90) -nosrc -b "" -I $(XIOS_ROOT)/src/interface/fortran:$(XIOS_ROOT)/src/interface/fortran_attr $(FSRC) > $(CURDIR)/$@

objects.mk:
	grep ^OBJECTS__ $(XIOS_ROOT)Makefile > $@

include fortran.deps
