#!/bin/bash

alphaGlobalVec=("1.667" "2.5391" "3.4111" "4.2832" "5.1553" "6.0273" "1.667" "2.5391" "3.4111" "4.2832" "6.0273" "1.667" "2.5391" "3.4111" "4.2832" "5.1553" "6.0273" "1.667" "2.5391" "3.4111" "4.2832" "5.1553" "6.0273" )
machGlobalVec=("0.51361" "0.51361" "0.51361" "0.51361" "0.51361" "0.51361" "0.55116" "0.55116" "0.55116" "0.55116" "0.55116" "0.58776" "0.58776" "0.58776" "0.58776" "0.58776" "0.58776" "0.62715" "0.62715" "0.62715" "0.62715" "0.62715" "0.62715" )
reGlobalVec=("6423135.0691" "6423135.0691" "6423135.0691" "6423135.0691" "6423135.0691" "6423135.0691" "6892681.8814" "6892681.8814" "6892681.8814" "6892681.8814" "6892681.8814" "7350407.741" "7350407.741" "7350407.741" "7350407.741" "7350407.741" "7350407.741" "7843038.4807" "7843038.4807" "7843038.4807" "7843038.4807" "7843038.4807" "7843038.4807" )
nCoresCoarse=1
nCoresFine=16
innerFirstIter=12
alphaFine="5.1553"
machFine="0.55116"
reFine="6892681.8814"
nTotSimCoarse=${#alphaGlobalVec[@]}
# Directories creation
mkdir CFDFiles
rm -r CFDFiles/*
mkdir imfinished
rm imfinished/*

# Launch fine simulation in foreground
./shellScripts/runRANSFine.sh "$alphaFine" "$machFine" "$reFine" "$nCoresFine"

# Launch first set of coarse Sim
for ((i = 0; i < innerFirstIter; i++)); do
    alpha=${alphaGlobalVec[$i]}
    mach=${machGlobalVec[$i]}
    re=${reGlobalVec[$i]}
    ./shellScripts/runRANSCoarse.sh "$alpha" "$mach" "$re" "$nCoresCoarse" & 
done

count=1
FILENUM=0
while [ $FILENUM -ne $nTotSimCoarse ]; do
    if [ $FILENUM -ge $count -a $i -lt $nTotSimCoarse ]
    then        
        alpha=${alphaGlobalVec[$i]}
        mach=${machGlobalVec[$i]}
        re=${reGlobalVec[$i]}
        ./shellScripts/runRANSCoarse.sh "$alpha" "$mach" "$re" "$nCoresCoarse" & 
        count=$(($count+1))
        i=$(($i+1))
    fi
    sleep 4
    FILENUM=$(ls -1q imfinished/log* | wc -l)
done

