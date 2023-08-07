alphaGlobalVec=("1.6263" "2.4983" "3.3703" "4.2424" "5.1144" "5.9864" "1.6263" "2.4983" "3.3703" "4.2424" "5.9864" "1.6263" "2.4983" "3.3703" "4.2424" "5.1144" "5.9864" "1.6263" "2.4983" "3.3703" "4.2424" "5.1144" "5.9864" )
machGlobalVec=("0.53252" "0.53252" "0.53252" "0.53252" "0.53252" "0.53252" "0.56436" "0.56436" "0.56436" "0.56436" "0.56436" "0.59704" "0.59704" "0.59704" "0.59704" "0.59704" "0.59704" "0.62715" "0.62715" "0.62715" "0.62715" "0.62715" "0.62715" )
reGlobalVec=("6659530.2531" "6659530.2531" "6659530.2531" "6659530.2531" "6659530.2531" "6659530.2531" "7057828.1461" "7057828.1461" "7057828.1461" "7057828.1461" "7057828.1461" "7466514.7287" "7466514.7287" "7466514.7287" "7466514.7287" "7466514.7287" "7466514.7287" "7843038.4807" "7843038.4807" "7843038.4807" "7843038.4807" "7843038.4807" "7843038.4807" )
nCoresCoarse=1
nCoresFine=4
innerIterVec=("11" "11" "1" )
alphaFine="5.1144"
machFine="0.56436"
reFine="7057828.1461"
outerCounterMax=3
mkdir CFDFiles
rm -r CFDFiles/*
mkdir imfinished
rm imfinished/*
time ./shellScripts/runRANSFine.sh $alphaFine $machFine $reFine $nCoresFine &
echo "ciao"
start=0
for outerCounter in $(seq 1 $outerCounterMax);do
    alphaVec=(${alphaGlobalVec[@]:$start:${innerIterVec[$(($outerCounter-1))]}})
    machVec=(${machGlobalVec[@]:$start:${innerIterVec[$(($outerCounter-1))]}})
    reVec=(${reGlobalVec[@]:$start:${innerIterVec[$(($outerCounter-1))]}})
    start=$(($start+${innerIterVec[$(($outerCounter-1))]}))
    ./shellScripts/loopRANSCoarse.sh "${alphaVec[*]}" "${machVec[*]}" "${reVec[*]}" "${innerIterVec[*]}" $outerCounter $nCoresCoarse 

    flag=1
    while [ $flag -eq 1 ]; do
        FILENUM=$(ls -1q imfinished/log* | wc -l)
        if [ $FILENUM -eq $start ]
        then
            flag=0
        fi
        sleep 1
    done
done
echo "ciao2"
