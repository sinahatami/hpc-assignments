# Root Makefile for all HPC assignments

SUBDIRS = cuda_assignment openmp_assignment mpi_assignment final_project

.PHONY: all clean $(SUBDIRS)

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

clean:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done
