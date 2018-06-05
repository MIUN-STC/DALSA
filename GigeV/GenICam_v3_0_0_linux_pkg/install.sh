#!/bin/bash
#!/bin/ksh
#-----------------------------------------------------------------------
# install_aarch64.sh
#					Copyright(C) 2016 Teledyne DALSA Inc
#						All rights reserved.
#
# Description:
#       Manual install script for GenICam libraries under Linux.
#    For aarch64 architectures.
#-----------------------------------------------------------------------
#
#=======================================================================
#
# This is to play nice with our corinstall script which expects a 
# response to different command line options which we do not give here.
SKIPIT="No"
if  [ $# -gt 0 ] ; then
    if [ ! $1 = "Install" ] ; then 
        SKIPIT="Yes"
    fi
fi

if [ $UID != 0 ]; then
    SUDOCMD=sudo
fi
# Definitions for version of GenICam library in this package.
# (Update for each new released version)
#
GENICAM_PATH_VERSION="v3_0"
GENICAM_BUILD_VERSION="0"
GENICAM_VERSION_ENV_STRING="GENICAM_ROOT_V3_0"
GENICAM_INSTALL_BASE_PATH="/opt/genicam_$GENICAM_PATH_VERSION"
GENICAM_LOG_CONFIG_PATH="$GENICAM_INSTALL_BASE_PATH/log/config-unix"
GENICAM_CACHE_PATH="/var/opt/genicam/xml/cache"

GENICAM_INSTALL_FILES_SUBDIR="GenICam_""$GENICAM_PATH_VERSION""_""$GENICAM_BUILD_VERSION"

#==================================================================================
# Check CPU architecture to install to.
ARCH=`uname -m | sed -e s/i.86/i386/ -e s/x86_64/x86_64/ -e s/arm.*/armhf/ -e s/aarch64/aarch64/ `

if [[ $ARCH == "aarch64" ]] ; then
    ARCH_GENICAM_BIN="Linux64_ARM"
    ARCH_GENICAM_SDK_TGZ_FILE="GenICam_SDK_gcc54_Linux64_ARM_""$GENICAM_PATH_VERSION""_""$GENICAM_BUILD_VERSION"".tgz"
    ARCH_GENICAM_TGZ_FILE="GenICam_Runtime_gcc54_Linux64_ARM_""$GENICAM_PATH_VERSION""_""$GENICAM_BUILD_VERSION"".tgz"
else
    echo "Architecture $ARCH is not supported by this package - only aarch64!!"
    SKIPIT="Yes"
fi

#==================================================================================
# Check for existing GenICam library installation of the same version as this
# (in case it is already installed)
GENICAM_ENV=`env | grep $GENICAM_VERSION_ENV_STRING`
if [[ $SKIPIT != "Yes" ]] ; then
    if [[  $GENICAM_ENV != "" ]] ; then
        echo "********************************************************************"
        echo " An existing GenICam library installation was found at $GENICAM_ENV "
        echo " (Uninstall it first if you want to replace it with this one)."        
        echo "  Exiting " 
        echo "********************************************************************"
        SKIPIT="Yes"
    fi
fi

if [[ $SKIPIT != "Yes" ]] ; then
	#==============================================================================
	# Here we will need the sudo password set up to copy to installation dir.
	#
	INSTALLER_NAME="GenICam Library Installer"
   if [[  $SUDOCMD != "" ]] ; then
		if [[ $DISPLAY ]] ; then
			 if [ -x /usr/bin/gksudo ] ; then
				  if ! gksudo -m "$INSTALLER_NAME needs administrative privileges" echo " " ; then
						SKIPIT="Yes"
				  fi
			 elif [ -x /usr/bin/kdesudo ] ; then
				  if ! kdesudo --comment "$INSTALLER_NAME needs administrative privileges" echo " " ; then
						SKIPIT="Yes"
				  fi
			 else
				  echo "**************************************************************"
				  echo "****** $INSTALLER_NAME needs administrative privileges ******" 
				  sudo echo " "
				  RETVAL=$?
				  if [[ "$RETVAL" -ne 0 ]] ; then
						SKIPIT="Yes"
				  fi
			 fi
		else
			 echo "**************************************************************"
			 echo "****** $INSTALLER_NAME needs administrative privileges ******" 
			 sudo echo " "
			 RETVAL=$?
			 if [[ "$RETVAL" -ne 0 ]] ; then
				  SKIPIT="Yes"
			 fi
		fi
	fi

	if [[ $SKIPIT != "Yes" ]] ; then
		#==============================================================================
		# Here we proceed with the copying.
		#
		echo "Installing GenICam $GENICAM_PATH_VERSION to $GENICAM_INSTALL_BASE_PATH "
		# 
		# Make the install dir and uncompress the tgz file there
		if [ ! -d $GENICAM_INSTALL_BASE_PATH ] ; then
			 $SUDOCMD mkdir -p $GENICAM_INSTALL_BASE_PATH
		fi 
		SAVEDIR=$(pwd)
		cd $GENICAM_INSTALL_BASE_PATH
		$SUDOCMD tar -zpxf $SAVEDIR/$GENICAM_INSTALL_FILES_SUBDIR/$ARCH_GENICAM_SDK_TGZ_FILE
		$SUDOCMD tar -zpxf $SAVEDIR/$GENICAM_INSTALL_FILES_SUBDIR/$ARCH_GENICAM_TGZ_FILE
		cd $SAVEDIR

		# Create the XMl cache and make it writable by all.
		if [ ! -d $GENICAM_CACHE_PATH ] ; then
			 $SUDOCMD mkdir -p $GENICAM_CACHE_PATH
			 $SUDOCMD chmod 777 $GENICAM_CACHE_PATH
		fi 

		# Generate the environment variable files to their proper place.
		# Usually this is /etc/profile.d where they get sourced by /etc/profile
		# for interactive shells.
		if [ -d /etc/profile.d ] ; then	
			 # For bash shells
			 #$SUDOCMD echo "export GENICAM_ROOT=$GENICAM_INSTALL_BASE_PATH" > td_genapi.sh
			 $SUDOCMD echo "export GENICAM_ROOT_V3_0=$GENICAM_INSTALL_BASE_PATH" >>  td_genapi.sh
			 $SUDOCMD echo "export GENICAM_LOG_CONFIG_V3_0=$GENICAM_LOG_CONFIG_PATH" >>  td_genapi.sh
			 $SUDOCMD echo "export GENICAM_CACHE_V3_0=$GENICAM_CACHE_PATH" >> td_genapi.sh
			 $SUDOCMD cp td_genapi.sh /etc/profile.d/td_genapi_"$GENICAM_PATH_VERSION".sh
			 # Assume this is a bash shell and set the variables.
			 source td_genapi.sh
			 rm td_genapi.sh
		 
			 # For csh shells
			 #$SUDOCMD echo "setenv GENICAM_ROOT $GENICAM_INSTALL_BASE_PATH" > td_genapi.csh
			 $SUDOCMD echo "setenv GENICAM_ROOT_V3_0 $GENICAM_INSTALL_BASE_PATH" >>  td_genapi.csh
			 $SUDOCMD echo "setenv GENICAM_LOG_CONFIG_V3_0 $GENICAM_LOG_CONFIG_PATH" >>  td_genapi.csh
			 $SUDOCMD echo "setenv GENICAM_CACHE_V3_0 $GENICAM_CACHE_PATH" >> td_genapi.csh
			 $SUDOCMD cp td_genapi.csh /etc/profile.d/td_genapi_"$GENICAM_PATH_VERSION".csh
			 rm td_genapi.csh
			 
			 # Update the current environment (in case it needs to be used before another script starts up)
			 . /etc/profile
		else
			 echo "*****************************************************************"
			 echo " Cannot set environment variables via /etc/profile.d shell files "
			 echo " Please add the folowing enviroment definitions to the local "
			 echo " shell resource file (i.e. to ~/.bashrc) "
			 echo " "
			 echo "       export GENICAM_ROOT_V3_0=$GENICAM_INSTALL_BASE_PATH "
			 echo "       export GENICAM_LOG_CONFIG_V3_0=$GENICAM_LOG_CONFIG_PATH "
			 echo "       export GENICAM_CACHE_V3_0=$GENICAM_CACHE_PATH "
			 echo " "
			 echo "*****************************************************************"
		fi

		GENICAM_LIBRARY_PATH="$GENICAM_INSTALL_BASE_PATH/bin/$ARCH_GENICAM_BIN"
		# Generate the ldconf config file and put it in /etc/ld.so.conf.d directory
		if [ -d /etc/ld.so.conf.d ] ; then
			 $SUDOCMD echo "$GENICAM_LIBRARY_PATH" > td_genicam_$GENICAM_PATH_VERSION.conf
			 $SUDOCMD cp td_genicam_$GENICAM_PATH_VERSION.conf /etc/ld.so.conf.d
			 $SUDOCMD rm td_genicam_$GENICAM_PATH_VERSION.conf
		else
			 # Don't seem to have /etc/ld.so.conf.d ... hmmmmmm .....
			 # Append the ldconfig string to the /etc/ld.so.conf file (brute force).
			 if [ -f /etc/ld/so.conf ] ; then
				  LIBPATH=`awk "\\$1 == \"$GENICAM_LIBRARY_PATH\" {print \\$1}" /etc/ld.so.conf`
				  if [ -z $LIBPATH ] ; then
						$SUDOCMD echo "$GENICAM_LIBRARY_PATH" >> /etc/ld.so.conf
				  fi
			 else
				  # Well - this is odd - no way to update the ld.so.cache with 
				  # the library locations. Complain.
				  echo "*********************************************************"
				  echo " Help - cannot figure out how to add GenICam library path"
				  echo " $GENICAM_LIBRARY_PATH"
				  echo " to the loadable library cache (ld.so.cache) "
				  echo " Manual entry required !!"
				  echo "*********************************************************"
			 fi
		fi

		# Update the loadable library cache.
		if [ -x /sbin/ldconfig ] ; then
			 $SUDOCMD /sbin/ldconfig
		fi

		echo "Done"

	fi
fi
