## Makefile for the flusi post-processing tools.

## set the default compiler if it's not already set, make sure it's not F77.
ifndef FC
FC = mpif90
endif
ifeq ($(FC),f77) # sometimes FC gets defined as f77, which is bad.
FC = mpif90
endif


# -----------------------------------------------------------------------
HDF_LIB = $(HDF_ROOT)/lib
HDF_INC = $(HDF_ROOT)/include

LDFLAGS = $(HDF5_FLAGS)
LDFLAGS += -L$(HDF_LIB) -lhdf5_fortran -lhdf5 -lz -ldl

FFLAGS += -I$(HDF_INC)

# Debug options:
# FFLAGS += -Wuninitialized -O -fimplicit-none -fbounds-check -g -ggdb


PROGRAMS = convert_mpiio2vtk convert_mpiio2vtk_ALL convert_mpiio2binary \
	convert_hdf2xmf convert_hdf2xmf_2d

all: $(PROGRAMS)

convert_mpiio2vtk: convert_vtk.f90
	$(FC) $(FFLAGS) $^ -o $@

convert_mpiio2vtk_ALL: convert_vtk_ALL.f90
	$(FC) $(FFLAGS) $^ -o $@

convert_mpiio2binary: convert_mpiio.f90
	$(FC) $(FFLAGS) $^ -o $@

convert_hdf2xmf: convert_hdf2xmf.f90
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)

convert_hdf2xmf_2d: convert_hdf2xmf_2d.f90
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)

clean:
	rm -f *.o *.mod $(PROGRAMS)
