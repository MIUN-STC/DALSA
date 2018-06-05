#-----------------------------------------------------------------------------
# MAKEFILE.armsf               						
#					Copyright(C) Teledyne DALSA Inc. 2016
#						All rights reserved.
#
# Description: 
#       CorW32 Library for Linux (Posix/Win32 compatibility layer).
# 	for ARMsf (soft-float) architecture.
#
# 		CorW32 is a shared library
#
# History:
# (Adapted from std PC makefile)
#
#-----------------------------------------------------------------------------
#
# Standard dependencies.
#
DEBUGFLAGS=-g
CC=gcc
RM=/bin/rm -f
RANLIB=ranlib
LD=ld
LDCONFIG=/sbin/ldconfig

INC_PATH = -I../include

ARCHLIBDIR=/usr/lib/aarch64-linux-gnu
ARCH_OPTIONS= -Darm_family -D__arm__ -D_REENTRANT

#
# API Version control information to be embedded.
#
TARGETNAME=CorW32
LIBVERSION=1
LIBBUILDID=0

#
# Path dependency for this library.
#
CURDIR = $(shell pwd)
VPATH = $(CURDIR)

#
# Object definitions: Specific files for this library.
#
OBJS= corw32lib.o \
	dynaqueue.o \
	fileutils.o \
	iniutils.o \
	objutils.o \
	ioctlutils.o \
	csection.o \
	timeutils.o \
	ipcutils.o \
	threadutils.o \
	waitutils.o \
	archutils.o 

#
# Libraries required.
#
EXTRALIBS=-L$(ARCHLIBDIR) -lpthread -lm -ldl -lrt

#
# Dynamic libraries need position independent code.
#
C_COMPILE_OPTIONS= $(DEBUGFLAGS) -fPIC -fhosted -Wall -Wno-parentheses -Wno-missing-braces \
	-Wno-unknown-pragmas -Wno-cast-qual -Wno-unused-function -Wno-unused-label -Wno-unused-variable -Wno-unused-but-set-variable

# c++ compiler options.
CXX_COMPILE_OPTIONS= $(DEBUGFLAGS) -fPIC -fno-for-scope -fno-const-strings -Wall \
	-Wno-parentheses -Wno-missing-braces -Wno-unknown-pragmas -Wno-cast-qual \
	-Wno-unused-function -Wno-unused-label -Wno-unused-variable -Wno-unused-but-set-variable

#BASE_OPTIONS= -DPOSIX_HOSTPC -DHOSTPC -DCOR_TRACE_LIBINIT 
BASE_OPTIONS= -DPOSIX_HOSTPC -DHOSTPC 

# See if this is 2.6.18 or later (named posix semaphores - process shared)
# (Hopefully kernel is name 2.6.###-### and not 2.6.###text )
CORKERNEL_MAJOR:=$(shell uname -r | cut -d '.' -f 1)
CORKERNEL_MINOR:=$(shell uname -r | cut -d '.' -f 2)
CORKERNEL_LEVEL_TMP:=$(shell uname -r | cut -d '.' -f 3)
CORKERNEL_LEVEL:=$(shell echo $(CORKERNEL_LEVEL_TMP) | cut -d '-' -f 1)
#CORKERNEL_LEVEL:=$(shell echo $(CORKERNEL_LEVEL_TMP) | cut -c '1-2')

ifeq ($(CORKERNEL_MAJOR), 2)
	ifeq ($(CORKERNEL_MINOR), 6)
		ifeq ($(shell if test $(CORKERNEL_LEVEL) -ge  18; then echo ok; fi), ok)
			#BASE_OPTIONS += -DUSE_POSIX_SEMAPHORES
		endif
	endif
endif

#
# Use the monotonic clock if it is present.
#
ifeq ($(shell if test -f /usr/include/linux/time.h; then echo exists; fi), exists)
CLOCK_MONOTONIC_PRESENT = $(shell grep CLOCK_MONOTONIC /usr/include/linux/time.h)
	ifneq ($(CLOCK_MONOTONIC_PRESENT),)
		BASE_OPTIONS += -DUSE_MONOTONIC_CLOCK
	endif
endif


.SUFFIXES: .o .c .cpp

%.o : %.c
	$(CC) -I. $(INC_PATH) $(C_COMPILE_OPTIONS) $(BASE_OPTIONS) $(TARGET_OPTIONS) $(ARCH_OPTIONS) -c $< -o $@

%.o : %.cpp
	$(CC) -I. $(INC_PATH) $(CXX_COMPILE_OPTIONS) $(BASE_OPTIONS) $(TARGET_OPTIONS) $(ARCH_OPTIONS) -c $< -o $@


#
# Define the installation paths
#
INSTALL_PREFIX	= /usr/local
BINDIR	= $(INSTALL_PREFIX)/bin
MANDIR	= $(INSTALL_PREFIX)/man
LIBDIR	= $(INSTALL_PREFIX)/lib
INCDIR	= $(INSTALL_PREFIX)/include
CNFDIR	= $(INSTALL_PREFIX)/share


LIBNAME=lib$(TARGETNAME)_$(LIBVERSION)_$(LIBBUILDID)_a
SONAME=lib$(TARGETNAME).so
SHAREDLIBLINK=$(SONAME).$(LIBVERSION)
SHAREDLIBNAME= $(SONAME).$(LIBVERSION).$(LIBBUILDID)

#
# Main target creation section.
#
all:	$(LIBNAME) $(SHAREDLIBNAME)

release:	$(SHAREDLIBNAME)

$(SHAREDLIBNAME): $(OBJS)
	$(CC) -shared -Wl,-Bsymbolic -Wl,-allow-shlib-undefined -Wl,-soname,$(SONAME).$(LIBVERSION) -o $(SHAREDLIBNAME) $(OBJS) $(EXTRALIBS)


$(LIBNAME): $(OBJS)
	$(LD) -r $^ -o $@

clean: distclean
	-$(RM) $(OBJS) *~ *.bak

distclean: 
	-$(RM) $(SHAREDLIBNAME)
	-$(RM) $(LIBNAME)

relink:
	-$(RM) $(SHAREDLIBNAME)

install: all
	cp $(SHAREDLIBNAME) $(LIBDIR)/$(SHAREDLIBNAME)
	-$(RM) $(LIBDIR)/$(SHAREDLIBLINK)
	ln -s $(LIBDIR)/$(SHAREDLIBNAME) $(LIBDIR)/$(SHAREDLIBLINK)
	-$(LDCONFIG) -l $(LIBDIR)/$(SHAREDLIBNAME)
	-$(RM) $(LIBDIR)/$(SONAME)
	ln -s $(LIBDIR)/$(SHAREDLIBLINK) $(LIBDIR)/$(SONAME)





