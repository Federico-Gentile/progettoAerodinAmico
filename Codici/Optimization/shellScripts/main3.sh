#!/bin/bash

alphaGlobalVec=("1.6263" "2.4983" "3.3703" "4.2424" "5.1144" "5.9864" "1.6263" "2.4983" "3.3703" "4.2424" "5.9864" "1.6263" "2.4983" "3.3703" "4.2424" "5.1144" "5.9864" "1.6263" "2.4983" "3.3703" "4.2424" "5.1144" "5.9864")
machGlobalVec=("0.53252" "0.53252" "0.53252" "0.53252" "0.53252" "0.53252" "0.56436" "0.56436" "0.56436" "0.56436" "0.56436" "0.59704" "0.59704" "0.59704" "0.59704" "0.59704" "0.59704" "0.62715" "0.62715" "0.62715" "0.62715" "0.62715" "0.62715")
reGlobalVec=("6659530.2531" "6659530.2531" "6659530.2531" "6659530.2531" "6659530.2531" "6659530.2531" "7057828.1461" "7057828.1461" "7057828.1461" "7057828.1461" "7057828.1461" "7466514.7287" "7466514.7287" "7466514.7287" "7466514.7287" "7466514.7287" "7466514.7287" "7843038.4807" "7843038.4807" "7843038.4807" "7843038.4807" "7843038.4807" "7843038.4807")
nCoresCoarse=1
nCoresFine=14
innerFirstIter=12
alphaFine="5.1144"
machFine="0.56436"
reFine="7057828.1461"
flagSerial=1
nTotSimCoarse=${#alphaGlobalVec[@]}
echo $nTotSimCoarse
# Directories creation
mkdir CFDFiles
rm -r CFDFiles/*
mkdir imfinished
rm imfinished/*

if [ $flagSerial -eq 1 ]
then
    # Launch fine simulation in foreground
    time ./shellScripts/runRANSFine.sh "$alphaFine" "$machFine" "$reFine" "$nCoresFine"
else
    # Launch fine simulation in the background
    time ./shellScripts/runRANSFine.sh "$alphaFine" "$machFine" "$reFine" "$nCoresFine" &
fi

for ((i = 0; i < innerFirstIter; i++)); do
    alpha=${alphaGlobalVec[$i]}
    mach=${machGlobalVec[$i]}
    re=${reGlobalVec[$i]}
    echo $i
    time ./shellScripts/runRANSCoarse.sh "$alpha" "$mach" "$re" "$nCoresCoarse" & 
done
count=1
FILENUM=0
while [ $FILENUM -ne $nTotSimCoarse ]; do
    if [ $FILENUM -ge $count -a $i -lt $nTotSimCoarse ]
    then        
        alpha=${alphaGlobalVec[$i]}
        mach=${machGlobalVec[$i]}
        re=${reGlobalVec[$i]}
        echo $alpha $mach $re $i $count $FILENUM
        time ./shellScripts/runRANSCoarse.sh "$alpha" "$mach" "$re" "$nCoresCoarse" & 
        count=$(($count+1))
        i=$(($i+1))
    fi
    sleep 4
    FILENUM=$(ls -1q imfinished/log* | wc -l)
done

