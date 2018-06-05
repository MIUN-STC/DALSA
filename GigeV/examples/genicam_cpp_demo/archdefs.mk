#-----------------------------------------------------------------------------
# archdefs.mk               						
#
# Description: 
#       Architecture specific definitions for compiling and linking
#		programs using GigE-V Framework API and GenICam libraries.
#		For ARMhf 
#
#-----------------------------------------------------------------------------#
# Architecture-dependent definitions.
# (GenICam libraries have different paths and names depending on the architecture)
#
ARMFP = -mhard-float
ARMSUFFIX=hf
#
# Architecture specific environment defs for self-hosted environment 
#
ifndef ARCH
  ARCH := $(shell uname -m | sed -e s/i.86/i386/ -e s/x86_64/x86_64/ -e s/armv5.*/armv5/ -e s/armv6.*/armv6/ -e s/armv7.*/armv7/ -e s/armv8.*/armv8/)
endif

ifeq  ($(ARCH), armv5)
	# Very Old
	ARCHNAME=armv5$(ARMSUFFIX)
	ARCH_GENICAM_BIN=Linux32_ARMhf
	ARCH_OPTIONS= -D__arm__ -D_REENTRANT -march=armv5t -mthumb-interwork $(ARMFP)
	ARCH_GCCVER=46
else
ifeq  ($(ARCH), armv6)
	# Old
	ARCHNAME=armv6$(ARMSUFFIX)
	ARCH_GENICAM_BIN=Linux32_ARMhf
	ARCH_OPTIONS= -D__arm__ -D_REENTRANT -march=armv6 -mthumb-interwork $(ARMFP)
	ARCH_GCCVER=46
else
ifeq  ($(ARCH), armv7)
	# Common
	ARCHNAME=armv7$(ARMSUFFIX)
	ARCH_GENICAM_BIN=Linux32_ARMhf
	ARCH_OPTIONS= -D__arm__ -D_REENTRANT -march=armv7 -mthumb-interwork $(ARMFP)
	ARCH_GCCVER=46
else
ifeq  ($(ARCH), armv8)
	# Common
	ARCHNAME=armv8$(ARMSUFFIX)
	ARCH_GENICAM_BIN=Linux32_ARMhf
	ARCH_OPTIONS= -D__arm__ -D_REENTRANT -march=armv8 -mthumb-interwork $(ARMFP)
	ARCH_GCCVER=46
else
# Not supported
$(error Architecture $(ARCH) not configured for this installation.)
endif
endif
endif
endif

ARCHLIBDIR=/usr/lib/arm-linux-gnueabihf
ARCH_LINK_OPTIONS=-mhard-float

#
# Arch dependent GenICam library specification
#
GENICAM_PATH_VERSION=v3_0
GENICAM_PATH:=$(GENICAM_ROOT_V3_0)
INC_GENICAM=-I$(GENICAM_PATH)/library/CPP/include
GENICAM_LIBS=-L$(GENICAM_PATH)/bin/$(ARCH_GENICAM_BIN)\
					-lGenApi_gcc$(ARCH_GCCVER)_$(GENICAM_PATH_VERSION)\
					-lGCBase_gcc$(ARCH_GCCVER)_$(GENICAM_PATH_VERSION)			

