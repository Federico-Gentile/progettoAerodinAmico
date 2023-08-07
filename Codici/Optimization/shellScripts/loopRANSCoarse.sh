### USER DEFINED INPUT FROM main.sh ###
# alphaVec, machVec, reVech, innerIterVec, outerCounter, nCoresCoarse
alphaVec=($1)
machVec=($2)
reVec=($3)
innerIterVec=($4)
echo ${alphaVec[@]}
outerCounter=$5
nCoresCoarse=$6
coreNumber=$nCoresCoarse
seqEnd=$((${innerIterVec[$outerCounter-1]} - 1))
for innerCounter in $(seq 0 $seqEnd); do	
    alpha=${alphaVec[$innerCounter]}
    mach=${machVec[$innerCounter]}
    re=${reVec[$innerCounter]}
    echo $innerCounter
    echo $alpha
    echo $mach
    echo $re
    time ./shellScripts/runRANSCoarse.sh $alpha $mach $re $coreNumber &
done
