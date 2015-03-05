#!/bin/bash

#-------------------------------------------------------------------------------
# convert files from binary format to format readable by vapor.
# see README for more information.
#-------------------------------------------------------------------------------

USAGE="convert_mpiio_duke.sh <NX> <NY> <NZ> <NAME>"

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
if [ "$4" == "" ]; then
    echo "need to specify name of program (flusi or mhd3d)"
    echo $USAGE
    exit 1
fi

nx=$1
ny=$2
nz=$3

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
echo -e $Green "**      binary2vapor      **" $Color_Off
echo -e $Green "****************************" $Color_Off

#-------------------------------------------------------------------------------
# check if data collection already exists and if so, delete it.
#-------------------------------------------------------------------------------
if [ -f $4.vdf ]; then
  echo -e $Cyan "deleting old file..." $Color_Off
  rm $4.vdf
fi

if [ -d $4_data ]; then
  echo -e $Cyan "found existing directory. deleting it..." $Color_Off
  rm -r $4_data
fi




#-------------------------------------------------------------------------------
# find prefixes
#-------------------------------------------------------------------------------
# look through all the files whose names start with binary_ and put
# them in the items array, as well as in the list, where file names
# are separated with colons. N is the number of items in the list.
N=0
list=""
lastp=""
for F in `ls *.binary`
do
    # as is the file name with everything after 
    p=$(echo ${F}  | sed 's/_[^_]*$//')_ 
    p=${p%%_}
    if [ "$p" != "$lastp" ] ; then
	list=${list}:${p}
	lastp=$p
	items[$N]=$p
	N=$((N+1))
    fi
done
# remove the first colong from the list (format should be "a:b:c", not ":a:b:c").
list=$(echo $list | sed 's/^.//g')



#-------------------------------------------------------------------------------
# determine number of time-steps by counting files matching a prefix
#-------------------------------------------------------------------------------

p=${items[0]}
FLIST=$( ls ${p}*.binary )
nts=0
for F in ${FLIST}
do
    nts=$((nts+1))
done


#-------------------------------------------------------------------------------
#put findings and give possibility to abort if failed
#-------------------------------------------------------------------------------
echo -e ${Cyan} "-----------------------------" ${Color_Off}
echo -e ${Cyan} "time steps" ${nts} ${Color_Off}
echo -e ${Cyan} "prefixes" ${list} ${Color_Off}
echo -e ${Cyan} "-----------------------------" ${Color_Off}
#echo -e $Green "any key to continue!" $Color_Off
#read dummy


#-------------------------------------------------------------------------------
# call vapor convert for the *.binary files 
#-------------------------------------------------------------------------------

# run vdfcreate on ${list}, the list of colon-separated files
# create the vapor-data file
VDFNAM="$4.vdf"
vdfcreate -dimension ${nx}x${ny}x${nz} -numts ${nts} -level 10 -varnames ${list} ${VDFNAM}

# loop throug the prefixes and process the files one-by-one
# for each prefix in the items array
for (( i=0; i<N; i++ ))
do
    # the prefix
    p=${items[i]}

    # find the files that start with the prefix
    FLIST=$( ls ${p}*.binary )

    # loop over the files starting with the prefix and process with raw2vdf
    j=0
    for F in ${FLIST}
    do
	echo ${j}
	echo ${F}
	raw2vdf -ts ${j} -varname ${p} ${VDFNAM} ${F}
	j=$((j+1))
    done
done
