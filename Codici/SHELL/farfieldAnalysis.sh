######################## USER DEFINEED INPUT #############################################################

# DISCLAIMER
# THE USER SHALL CREATE A ENVIRONMENTAL VARIABLE IN WSL CALLED "ProgettoAerodinAmico" in the wsl .bashrc file.
# This variable shall be defined with the two lines reported below. The lines shall be copied at the end of the
# .bashrc file and the path shall be substituted with the one of the user. The path shall direct to the Progetto
# Aerodinamico folder on OneDrive.

# export ProgettoAerodinAmico="/mnt/c/Users/matte/OneDrive - Politecnico di Milano/MAGISTRALE/QuartoSemestre/Progetto Aerodinamico/Project"
# export PATH=$PATH:$ProgettoAerodinAmico

# Test C#
testNumber=3

# Index of the mesh that starts the sweep
meshIndexes=("1" "2" "3" "4" "5" "6")

# Core number
coreNumber=8

# Name of the template .cfg file
# Either: "EulerTemplate.cfg" or "RANSTemplate.cfg"
templateName="RANSTemplate.cfg"

########################## USER INFO #######################################################################
echo "Test condition set to C$testNumber"
echo "Number of core set to $coreNumber"
echo "Simulation type: $templateName"

########################### CODE ###########################################################################

# Template source path
templateSourcePath="$ProgettoAerodinAmico"/Simulazioni/Template

# Mesh source path
if [ "$templateName" = "EulerTemplate.cfg" ]
then
	testDir="$ProgettoAerodinAmico"/Simulazioni/FarField/Euler/C$testNumber
	meshSourcePath="$ProgettoAerodinAmico"/Simulazioni/MeshFiles/Euler
elif [ "$templateName" = "RANSTemplate.cfg" ]
then
	testDir="$ProgettoAerodinAmico"/Simulazioni/FarField/RANS/C$testNumber
	meshSourcePath="$ProgettoAerodinAmico"/Simulazioni/MeshFiles/RANS
fi

# Checking template name is correct
if [ "$templateName" = "EulerTemplate.cfg" ] || [ "$templateName" = "RANSTemplate.cfg" ]
then
	echo "Template name is correct"
else
	echo "Wrong template name"
	exit 1
fi

# Setting test conditions
if [ $testNumber -eq 1 ]
then
	alpha=8.916652417
	Ma=0.623163805
	Re=7793164.506
elif [ $testNumber -eq 2 ]
then
	alpha=9.817719984
	Ma=0.293168528
	Re=3666308.189
elif [ $testNumber -eq 3 ]
then
	alpha=2.954977324
	Ma=0.169847087
	Re=2124074.41
elif [ $testNumber -eq 4 ]
then
	alpha=6.950477947
	Ma=0.520880599	
	Re=6514030.762
fi

echo "AoA set to $alpha deg"
echo "Ma set to $Ma"
echo "Re (if necessary) set to $Re"

# Checking if C# folder already exist; create it from scratch otherwise
if [ ! -d "$testDir" ]
then
	mkdir "$testDir"
fi
cd "$testDir"

for currMeshIndex in ${meshIndexes[@]}; do

	echo "Running $templateName with meshG$curreMeshIndex ..."

	# Creating case folder
	mkdir caseG$currMeshIndex
	mkdir caseG$currMeshIndex/cfdG$currMeshIndex

	# Copying mesh into case folder
	cp -r "$meshSourcePath"/meshG$currMeshIndex caseG$currMeshIndex/

	# Copying template .cfg into cfd folder
	cp "$templateSourcePath"/$templateName caseG$currMeshIndex/cfdG$currMeshIndex

	# Modifying config with proper alpha, Ma and Re
	if [ "$templateName" = "EulerTemplate.cfg" ]
	then
		sed -i "s/MACH_NUMBER= 0.74/MACH_NUMBER= ${Ma}/" caseG$currMeshIndex/cfdG$currMeshIndex/$templateName
		sed -i "s/AOA= 6/AOA= ${alpha}/" caseG$currMeshIndex/cfdG$currMeshIndex/$templateName
	elif [ "$templateName" = "RANSTemplate.cfg" ]
	then
		sed -i "s/MACH_NUMBER= 0.7/MACH_NUMBER= ${Ma}/" caseG$currMeshIndex/cfdG$currMeshIndex/$templateName
		sed -i "s/AOA= 4.5/AOA= ${alpha}/" caseG$currMeshIndex/cfdG$currMeshIndex/$templateName
		sed -i "s/REYNOLDS_NUMBER= 490000/REYNOLDS_NUMBER= ${Re}/" caseG$currMeshIndex/cfdG$currMeshIndex/$templateName
	fi
	sed -i "s%MESH_FILENAME= ../mesh/mesh.su2%MESH_FILENAME= ../meshG${currMeshIndex}/meshG$currMeshIndex.su2%" caseG$currMeshIndex/cfdG$currMeshIndex/$templateName
	sed -i "s/CONV_FILENAME= history/CONV_FILENAME= history_G${currMeshIndex}/" caseG$currMeshIndex/cfdG$currMeshIndex/$templateName
	sed -i "s/RESTART_FILENAME= restart_flow.dat/RESTART_FILENAME= restart_flow_G${currMeshIndex}.dat/" caseG$currMeshIndex/cfdG$currMeshIndex/$templateName
	sed -i "s/VOLUME_FILENAME= flow/VOLUME_FILENAME= flow_G${currMeshIndex}/" caseG$currMeshIndex/cfdG$currMeshIndex/$templateName
	sed -i "s/SURFACE_FILENAME= surface_flow/SURFACE_FILENAME= surface_flow_G${currMeshIndex}/" caseG$currMeshIndex/cfdG$currMeshIndex/$templateName
	sed -i "s/MESH_OUT_FILENAME= mesh_out.su2/MESH_OUT_FILENAME= mesh_out_G${currMeshIndex}.su2/" caseG$currMeshIndex/cfdG$currMeshIndex/$templateName

	# Running simulation
	echo "Running ${templateName}, case C${testNumber} with grid G${currMeshIndex} ..."
	mpirun -n $coreNumber SU2_CFD caseG$currMeshIndex/cfdG$currMeshIndex/$templateName >"caseG${currMeshIndex}/cfdG${currMeshIndex}/logG${currMeshIndex}.log"

done

exit 0

