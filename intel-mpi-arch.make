#
# Copyright (C) 1996-2016 The SIESTA group
#  This file is distributed under the terms of the
#  GNU General Public License: see COPYING in the top directory
#  or http://www.gnu.org/copyleft/gpl.txt.
# See Docs/Contributors.txt for a list of contributors.
#
#-------------------------------------------------------------------
# arch.make file for intel compiler with mkl and mpi.
# To use this arch.make file you should rename it to
#   arch.make
# or make a sym-link.
# For an explanation of the flags see DOCUMENTED-TEMPLATE.make

.SUFFIXES:
.SUFFIXES: .f .F .o .c .a .f90 .F90

SIESTA_ARCH = x86_64_MPI_INTEL

CC = mpicc
FPP = $(FC) -E -P
FC = mpiifort
FC_SERIAL = ifort

# MPI setup
MPI_INTERFACE = libmpi_f90.a
MPI_INCLUDE = -I/opt/intel/compilers_and_libraries/linux/mpi/intel64/include

FFLAGS = -O2 -fPIC

AR = ar
RANLIB = ranlib

SYS = nag

SP_KIND = 4
DP_KIND = 8
KINDS = $(SP_KIND) $(DP_KIND)

LDFLAGS =
INCFLAGS=

# commented: we are using Intel's openblas implementation (mkl) of lapack
#COMP_LIBS = libsiestaLAPACK.a libsiestaBLAS.a


FPPFLAGS = $(DEFS_PREFIX)-DFC_HAVE_ABORT
# MPI requirement:
FPPFLAGS += -DMPI

LIBS =

# netcdf
INCFLAGS += -I/opt/siesta/siesta-4.1-b3/Docs/build/netcdf/4.4.1.1/include
LDFLAGS += -L/opt/siesta/siesta-4.1-b3/Docs/build/zlib/1.2.11/lib -Wl,-rpath=/opt/siesta/siesta-4.1-b3/Docs/build/zlib/1.2.11/lib
LDFLAGS += -L/opt/siesta/siesta-4.1-b3/Docs/build/hdf5/1.8.18/lib -Wl,-rpath=/opt/siesta/siesta-4.1-b3/Docs/build/hdf5/1.8.18/lib
LDFLAGS += -L/opt/siesta/siesta-4.1-b3/Docs/build/netcdf/4.4.1.1/lib -Wl,-rpath=/opt/siesta/siesta-4.1-b3/Docs/build/netcdf/4.4.1.1/lib
LIBS += -lnetcdff -lnetcdf -lhdf5_hl -lhdf5 -lz
COMP_LIBS += libncdf.a libfdict.a
FPPFLAGS += -DCDF -DNCDF -DNCDF_4

# intel mkl
MKL = /opt/intel/compilers_and_libraries/linux/mkl
INTEL_LIBS = $(MKL)/lib/intel64/libmkl_intel_lp64.a \
             $(MKL)/lib/intel64/libmkl_sequential.a \
             $(MKL)/lib/intel64/libmkl_core.a \
             $(MKL)/lib/intel64/libmkl_blacs_intelmpi_lp64.a \
             $(MKL)/lib/intel64/libmkl_scalapack_lp64.a
MKL_LIBS = -Wl,--start-group $(INTEL_LIBS) \
           -Wl,--end-group -lpthread -lm
MKL_INCLUDE = -I$(MKL)/include -I$(MKL)/include/intel64/lp64
INCFLAGS += $(MPI_INCLUDE) $(MKL_INCLUDE)

# Dependency rules ---------

FFLAGS_DEBUG = -g -O1   # your appropriate flags here...

# The atom.f code is very vulnerable. Particularly the Intel compiler
# will make an erroneous compilation of atom.f with high optimization
# levels.
atom.o: atom.F
	$(FC) -c $(FFLAGS_DEBUG) $(INCFLAGS) $(FPPFLAGS) $(FPPFLAGS_fixed_F) $<
.c.o:
	$(CC) -c $(CFLAGS) $(INCFLAGS) $(CPPFLAGS) $<
.F.o:
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FPPFLAGS) $(FPPFLAGS_fixed_F) $<
.F90.o:
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FPPFLAGS) $(FPPFLAGS_free_F90) $<
.f.o:
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FCFLAGS_fixed_f) $<
.f90.o:
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FCFLAGS_free_f90) $<
