### USER DEFINED INPUT FROM main.sh ###
# alphaVec, machVec, reVech, innerIterVec, outerCounter, nCoresCoarse

coreNumber=$nCoresCoarse
seqEnd=$((${innerIterVec[$outerCounter]} - 1))
for innerCounter in $(seq 0 $seqEnd); do	
    alpha=${alphaVec[$innerCounter]}
    mach=${machVec[$innerCounter]}
    re=${reVec[$innerCounter]
    . ./shellScripts/runRANSCoarse.sh &
done