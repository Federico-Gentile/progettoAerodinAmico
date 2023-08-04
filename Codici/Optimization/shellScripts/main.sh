alphaGlobalVec=("1.6263" "2.4983" "3.3703" "4.2424" "5.1144" "5.9864" "1.6263" "2.4983" "3.3703" "4.2424" "5.9864" "1.6263" "2.4983" "3.3703" "4.2424" "5.1144" "5.9864" "1.6263" "2.4983" "3.3703" "4.2424" "5.1144" "5.9864" )
machGlobalVec=("0.53252" "0.53252" "0.53252" "0.53252" "0.53252" "0.53252" "0.56436" "0.56436" "0.56436" "0.56436" "0.56436" "0.59704" "0.59704" "0.59704" "0.59704" "0.59704" "0.59704" "0.62715" "0.62715" "0.62715" "0.62715" "0.62715" "0.62715" )
reGlobalVec=("6659530.2531" "6659530.2531" "6659530.2531" "6659530.2531" "6659530.2531" "6659530.2531" "7057828.1461" "7057828.1461" "7057828.1461" "7057828.1461" "7057828.1461" "7466514.7287" "7466514.7287" "7466514.7287" "7466514.7287" "7466514.7287" "7466514.7287" "7843038.4807" "7843038.4807" "7843038.4807" "7843038.4807" "7843038.4807" "7843038.4807" )
nCoresCoarse=1
nCoresFine=6
innerIterVec=("9" "9" "5" )
alphaFine="5.1144"
machFine="0.56436"
reFine="7057828.1461"
outerCounterMax=3
. ./shellScripts/runRANSFine.sh &
start=0
for outerCounter in $(seq 1 $outerCounterMax);do
    alphaVec=${alphaGlobalVec[@]:$start:${innerIterVec[$(($outerCounter-1))]}}
    machVec=${machGlobalVec[@]:$start:${innerIterVec[$(($outerCounter-1))]}}
    reVec=${reGlobalVec[@]:$start:${innerIterVec[$(($outerCounter-1))]}}
    start=$(($start+${innerIterVec[$(($outerCounter-1))]}))
    . ./shellScripts/loopRANSCoarse.sh
done

