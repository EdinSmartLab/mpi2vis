#!/bin/bash

#-------------------------------------------------------------------------------
# convert files from mpi format to a Fortran-readable format
#-------------------------------------------------------------------------------

# usage: 
# convert_mpiio_duke.script <NX> <NY> <NZ>
# where NX, NY, and NZ are the number of elements in each dimension

USAGE="convert_mpiio_duke.script <NX> <NY> <NZ>"

if [ "$1" == "" ]; then
    echo "need to specify NX"
    echo $USAGE
    exit 1
fi
if [ "$2" == "" ]; then
    echo "need to specify NY"
    echo $USAGE
    exit 1
fi
if [ "$3" == "" ]; then
    echo "need to specify NZ"
    echo $USAGE
    exit 1
fi

NX=$1
NY=$2
NZ=$3

# Reset
Color_Off='\e[0m'       # Text Reset
# Pretty colors
# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

echo -e $Green "****************************" $Color_Off
echo -e $Green "**      mpiio2binary      **" $Color_Off
echo -e $Green "****************************" $Color_Off


#-------------------------------------------------------------------------------
# ask what to do with existing *.binary files
#-------------------------------------------------------------------------------
echo "If a binary file already exists, do you want to proceed and overwrite it or do you want to skip it?"
echo -e ${Cyan} "[ [s] for skipping, anyting else for overwriting]" ${Color_Off}
echo -e ${Cyan} "[enter for skipping]" ${Color_Off}
read skip
if [ "${skip}" == "" ]; then
    skip="s"
fi

#-------------------------------------------------------------------------------
# ask whether to keep original *.mpiio files. note we can also convert
# *.binary->*.vtk
# ------------------------------------------------------------------------------
echo -e $Cyan "Do you want to delete *.mpiio files after converting? (y,[n])" $Color_Off
read delete
if [ "${delete}" == "" ]; then
    delete="n"
fi

#-----------------------------------------------------------------
# loop over all *.mpiio files and call the converter
#-----------------------------------------------------------------
for file in *.mpiio
do
    
    target_file=${file%%mpiio}binary
    
    if [ -f $target_file ]; then
      # file does already exist
	if [ "${skip}" == "s" ]; then
	    echo -e $Green "File " ${file%%.mpiio}"binary already exists, skipping."
	else
	    convert_mpiio2binary ${file%%.mpiio} ${NX} ${NY} ${NZ} 0
	# check if binary file now exists
	    if [ -f $target_file ]; then
		if [ "${delete}" == "y" ]; then
		    echo "succes, deleting *.mpiio file" ${file}
		    rm ${file}
		fi
	    else
		echo -e $Red "Error! convert_mpiio2binary didn't produce a binary file. exit."
		exit 1
	    fi      
	fi 
    else
      # file does not exist
	convert_mpiio2binary ${file%%.mpiio} ${NX} ${NY} ${NZ} 0
      # check if binary file now exists
	if [ -f $target_file ]; then
	    if [ "${delete}" == "y" ]; then
		echo "succes, deleting *.mpiio file" ${file}
		rm ${file}
	    fi
	else
	    echo -e $Red "Error! convert_mpiio2binary didn't produce a binary file. exit."
	    exit 1
	fi      
    fi  
done

#----------------------------------------------------------------------
# if desired, directly convert everything to vapor.
#----------------------------------------------------------------------
echo -e ${Cyan} "launch binary2vapor?" ${Color_Off}
read answer
if [ "${answer}" == "" ]; then
    answer="y"
fi
if [ "${answer}" == "y" ]; then
    binary2vapor.script ${NX} ${NY} ${NZ}
fi
