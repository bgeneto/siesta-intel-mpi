#
# Copyright (C) 1996-2016 The SIESTA group
#  This file is distributed under the terms of the
#  GNU General Public License: see COPYING in the top directory
#  or http://www.gnu.org/copyleft/gpl.txt.
# See Docs/Contributors.txt for a list of contributors.
#
#-------------------------------------------------------------------
# arch.make file for gfortran compiler.
# To use this arch.make file you should rename it to
# arch.make
# or make a sym-link.
# For an explanation of the flags see DOCUMENTED-TEMPLATE.make

.SUFFIXES:
.SUFFIXES: .f .F .o .c .a .f90 .F90

SIESTA_ARCH = x86_64_MPI_INTEL

INSDIR = /opt

CC = mpiicc
FPP = $(FC) -E -P
FC = mpiifort
FC_SERIAL = ifort

# MPI setup
MPI_INTERFACE = libmpi_f90.a
MPI_INCLUDE = .

FFLAGS = -O3 -fPIC -xHost -ip -no-prec-div

AR = ar
RANLIB = ranlib

SYS = nag

SP_KIND = 4
DP_KIND = 8
KINDS = $(SP_KIND) $(DP_KIND)

LDFLAGS =
INCFLAGS=
COMP_LIBS =
LIBS =

FPPFLAGS = $(DEFS_PREFIX)-DFC_HAVE_ABORT

# MPI requirement:
FPPFLAGS += -DMPI

# netcdf
INCFLAGS += -I$(INSDIR)/siesta/siesta-4.1-b3/Docs/build/netcdf/4.4.1.1/include
LDFLAGS += -L$(INSDIR)/siesta/siesta-4.1-b3/Docs/build/zlib/1.2.11/lib -Wl,-rpath=$(INSDIR)/siesta/siesta-4.1-b3/Docs/build/zlib/1.2.11/lib
LDFLAGS += -L$(INSDIR)/siesta/siesta-4.1-b3/Docs/build/hdf5/1.8.18/lib -Wl,-rpath=$(INSDIR)/siesta/siesta-4.1-b3/Docs/build/hdf5/1.8.18/lib
LDFLAGS += -L$(INSDIR)/siesta/siesta-4.1-b3/Docs/build/netcdf/4.4.1.1/lib -Wl,-rpath=$(INSDIR)/siesta/siesta-4.1-b3/Docs/build/netcdf/4.4.1.1/lib
LIBS += -lnetcdff -lnetcdf -lhdf5_hl -lhdf5 -lz
COMP_LIBS += libncdf.a libfdict.a
FPPFLAGS += -DCDF -DNCDF -DNCDF_4

# mkl with scalapack
MKLROOT = $(INSDIR)/intel/compilers_and_libraries/linux/mkl
INCFLAGS += -I${MKLROOT}/include
LDFLAGS += -L${MKLROOT}/lib/intel64 
LIBS += -lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lmkl_blacs_intelmpi_lp64 -lpthread -lm -ldl

# Dependency rules ---------

FFLAGS_DEBUG = -g -O1

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
