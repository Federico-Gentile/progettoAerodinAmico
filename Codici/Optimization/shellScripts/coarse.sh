
alphaVec=("0.5" "2" "3" "4" "4.5" "5" "5.5" "6" "6.5" "7")
machVec=("0.15" "0.25" "0.35" "0.4" "0.45" "0.5" "0.54" "0.58" "0.62")
reVec=("1.88E6" "3.13E6" "4.38E6" "5.00E6" "5.63E6" "6.25E6" "6.75E6" "7.25E6" "7.75E6")

# Name of the template .cfg file
templateName="RANSTemplate.cfg"


# Template source path
templateSourcePath=../configFiles/

# Mesh source path
outputDir=../CFDFiles/
meshSourcePath=../temporaryFiles/


# Checking if C# folder already exist; create it from scratch otherwise
if [ ! -d "$outputDir" ]
then
	mkdir "$outputDir"
fi

# Copy the mesh folder in the meshIndex related case folder
cp -r "$meshSourcePath" ./

# Computing arrays lengths
alphaVecLen=${#alphaVec[@]}
machVecLen=${#machVec[@]}
reVecLen=${#reVec[@]}
if [ $machVecLen -ne $reVecLen ]
then
	echo "Mach vector length and Reynolds vector lenghts are inconsistent"
	exit 1
fi

alphaLastIndex=$(($alphaVecLen - 1))
machLastIndex=$(($machVecLen - 1))


# Looping over alpha and mach
for alphaIndex in $(seq 0 $alphaLastIndex); do	
	currAoA=${alphaVec[$alphaIndex]}

	for machIndex in $(seq 0 $machLastIndex); do

	currMach=${machVec[$machIndex]}
	currRe=${reVec[$machIndex]}

	# Creating cfd folder inside case folder
	cfdFolderName="A""$currAoA""_M""$currMach"
	cfdFolderName="${cfdFolderName//"."/"_"}"
	if [ ! -d "$cfdFolderName" ]
	then
		mkdir "$cfdFolderName"
	fi

	# Moving in the cfd folder
	cd "$cfdFolderName"

	# Copying simulation template# Copying template .cfg into cfd folder
	cp "$templateSourcePath"/$templateName ./

	# Modifying config with proper alpha, Ma and Re
	if [ "$templateName" = "EulerTemplate.cfg" ]
	then
		sed -i "s/MACH_NUMBER= 0.74/MACH_NUMBER= ${currMach}/" $templateName
		sed -i "s/AOA= 6/AOA= ${currAoA}/" $templateName
	elif [ "$templateName" = "RANSTemplate.cfg" ]
	then
		sed -i "s/MACH_NUMBER= 0.7/MACH_NUMBER= ${currMach}/" $templateName
		sed -i "s/AOA= 4.5/AOA= ${currAoA}/" $templateName
		sed -i "s/REYNOLDS_NUMBER= 490000/REYNOLDS_NUMBER= ${currRe}/" $templateName
	fi
	sed -i "s%MESH_FILENAME= ../mesh/mesh.su2%MESH_FILENAME= ../meshG${meshIndex}/meshG$meshIndex.su2%" $templateName
	sed -i "s/CONV_FILENAME= history/CONV_FILENAME= history_${cfdFolderName}/" $templateName
	sed -i "s/RESTART_FILENAME= restart_flow.dat/RESTART_FILENAME= restart_flow_${cfdFolderName}.dat/" $templateName
	sed -i "s/VOLUME_FILENAME= flow/VOLUME_FILENAME= flow_${cfdFolderName}/" $templateName
	sed -i "s/SURFACE_FILENAME= surface_flow/SURFACE_FILENAME= surface_flow_${cfdFolderName}/" $templateName
	sed -i "s/MESH_OUT_FILENAME= mesh_out.su2/MESH_OUT_FILENAME= mesh_out_G${meshIndex}.su2/" $templateName
		
	if [ $restartFlag -eq 1 ] 
	then
		if [ $machIndex -gt 0 ]
		then
			sed -i "s/RESTART_SOL= NO/RESTART_SOL= YES/" $templateName
			previousSolutionName="A""$currAoA""_M""${machVec[$(($machIndex - 1))]}"
			previousSolutionName="${previousSolutionName//"."/"_"}"
			echo "|  Performing initialization with $previousSolutionName solution."
			echo "|"
			sed -i "s%SOLUTION_FILENAME= solution_flow.dat%SOLUTION_FILENAME= ../${previousSolutionName}/restart_flow_${previousSolutionName}.dat%" $templateName
		elif [ $machIndex -eq 0 -a $alphaIndex -gt 0 ]
		then
			sed -i "s/RESTART_SOL= NO/RESTART_SOL= YES/" $templateName
			previousSolutionName="A""${alphaVec[$(($alphaIndex - 1))]}""_M""$currMach"
			previousSolutionName="${previousSolutionName//"."/"_"}"
			echo "|  Performing initialization with $previousSolutionName solution."
			echo "|"
			sed -i "s%SOLUTION_FILENAME= solution_flow.dat%SOLUTION_FILENAME= ../${previousSolutionName}/restart_flow_${previousSolutionName}.dat%" $templateName
		fi
	elif [ $restartFlag -eq 2 ] 
	then 
		sed -i "s/RESTART_SOL= NO/RESTART_SOL= YES/" $templateName
		previousSolutionName="A""$currAoA""_M""$currMach"
		previousSolutionName="${previousSolutionName//"."/"_"}"
		echo "|  Performing initialization with restart_flow_$previousSolutionName.dat"
		echo "|"
		sed -i "s%SOLUTION_FILENAME= solution_flow.dat%SOLUTION_FILENAME= restart_flow_${previousSolutionName}.dat%" $templateName
	fi

	echo "|  Running ${templateName} with grid G${meshIndex} ..."
	time mpirun --oversubscribe -n $coreNumber SU2_CFD $templateName  >"logG${cfdFolderName}.log"
	echo "|"
	echo "|__________________________________________________________________"
	echo " "

	# Moving back
	cd ..

	done
done