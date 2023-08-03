### USER DEFINED INPUT FROM main.sh ###
# alphaVec, machVec, reVech, innerIterVec, outerCounter, coarseRANSCoreNumber

coreNumber=$coarseRANSCoreNumber
seqEnd=$((${innerIterVec[$outerCounter]} - 1))
for innerCounter in $(seq 0 $seqEnd); do	
    alpha=${alphaVec[$innerCounter]}
    mach=${machVec[$innerCounter]}
    re=${reVec[$innerCounter]
    . ./shellScripts/runRANSCoarse.sh &
done