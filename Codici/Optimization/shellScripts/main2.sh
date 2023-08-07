#!/bin/bash

alphaGlobalVec=("1.6263" "2.4983" "3.3703" "4.2424" "5.1144" "5.9864" "1.6263" "2.4983" "3.3703" "4.2424" "5.9864" "1.6263" "2.4983" "3.3703" "4.2424" "5.1144" "5.9864" "1.6263" "2.4983" "3.3703" "4.2424" "5.1144" "5.9864")
machGlobalVec=("0.53252" "0.53252" "0.53252" "0.53252" "0.53252" "0.53252" "0.56436" "0.56436" "0.56436" "0.56436" "0.56436" "0.59704" "0.59704" "0.59704" "0.59704" "0.59704" "0.59704" "0.62715" "0.62715" "0.62715" "0.62715" "0.62715" "0.62715")
reGlobalVec=("6659530.2531" "6659530.2531" "6659530.2531" "6659530.2531" "6659530.2531" "6659530.2531" "7057828.1461" "7057828.1461" "7057828.1461" "7057828.1461" "7057828.1461" "7466514.7287" "7466514.7287" "7466514.7287" "7466514.7287" "7466514.7287" "7466514.7287" "7843038.4807" "7843038.4807" "7843038.4807" "7843038.4807" "7843038.4807" "7843038.4807")
nCoresCoarse=1
nCoresFine=6
innerIterVec=("9" "14")
alphaFine="5.1144"
machFine="0.56436"
reFine="7057828.1461"
outerCounterMax=2
flagSerial=1
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

# Function to run a single coarse simulation
runSingleCoarseSim() {
    local alpha="$1"
    local mach="$2"
    local re="$3"
    local nCores="$4"

    time ./shellScripts/runRANSCoarse.sh "$alpha" "$mach" "$re" "$nCores" 
}

# Function to run the coarse simulations using a thread pool
runCoarseSimThreadPool() {
    local alphaVec=($1)  # Receives alphaVec as arguments
    local machVec=($2)  # Receives machVec as arguments
    local reVec=($3)  # Receives reVec as arguments
    local nCoresCoarse="$4" 
    local numJobs=${#alphaVec[@]}
    

    # Array to store background process IDs
    local pids=()

    for ((i = 0; i < numJobs; i++)); do
        alpha=${alphaVec[$i]}
        mach=${machVec[$i]}
        re=${reVec[$i]}
        runSingleCoarseSim "$alpha" "$mach" "$re" "$nCoresCoarse" &
        pids+=($!)  # Store the process ID of the background job
    done

    # Wait for all the background jobs to finish
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
}

# Loop to run coarse simulations in parallel for the current outerCounter
start=0
for outerCounter in $(seq 1 $outerCounterMax); do
    alphaVec=(${alphaGlobalVec[@]:$start:${innerIterVec[$(($outerCounter-1))]}})
    machVec=(${machGlobalVec[@]:$start:${innerIterVec[$(($outerCounter-1))]}})
    reVec=(${reGlobalVec[@]:$start:${innerIterVec[$(($outerCounter-1))]}})
    start=$(($start+${innerIterVec[$(($outerCounter-1))]}))
    runCoarseSimThreadPool "${alphaVec[*]}" "${machVec[*]}" "${reVec[*]}" "$nCoresCoarse" 
done
