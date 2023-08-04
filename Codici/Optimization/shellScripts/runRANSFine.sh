### USER DEFINED INPUT FROM main.sh ###
# alphaFine, machFine, reFine, nCoresFine

# Name of the template .cfg file
templateName="RANSTemplate.cfg"

currAoA="$alphaFine"
currMach="$machFine"
currRe="$reFine"
	
# Creating cfd folder inside case folder
cfdFolderName="coarse_A""$currAoA""_M""$currMach"
cfdFolderName="${cfdFolderName//"."/"_"}"


# Moving in the cfd folder
cd CFDFiles/
mkdir "$cfdFolderName"
cd "$cfdFolderName"

# Copying simulation template# Copying template .cfg into cfd folder
cp ../../configFiles/$templateName ./

# Substituting mach, alpha, and Re
sed -i "s/MACH_NUMBER= 0.7/MACH_NUMBER= ${currMach}/" $templateName
sed -i "s/AOA= 4.5/AOA= ${currAoA}/" $templateName
sed -i "s/REYNOLDS_NUMBER= 490000/REYNOLDS_NUMBER= ${currRe}/" $templateName

sed -i "s%MESH_FILENAME= ../mesh/mesh.su2%MESH_FILENAME= ../../temporaryFiles/Gcoarse.su2%" $templateName
sed -i "s/CONV_FILENAME= history/CONV_FILENAME= history_${cfdFolderName}/" $templateName
sed -i "s/RESTART_FILENAME= restart_flow.dat/RESTART_FILENAME= restart_flow_${cfdFolderName}.dat/" $templateName
sed -i "s/VOLUME_FILENAME= flow/VOLUME_FILENAME= flow_${cfdFolderName}/" $templateName
sed -i "s/SURFACE_FILENAME= surface_flow/SURFACE_FILENAME= surface_flow_${cfdFolderName}/" $templateName
sed -i "s/MESH_OUT_FILENAME= mesh_out.su2/MESH_OUT_FILENAME= mesh_out_G${meshIndex}.su2/" $templateName
    
if [ $nCoresFine -gt 1 ]
then
    mpirun --oversubscribe -n $nCoresFine SU2_CFD $templateName  >"logG${cfdFolderName}.log"
else
    SU2_CFD $templateName  >"logG${cfdFolderName}.log"
fi

cd ../..

## RANS FINE
previousSolutionName="$cfdFolderName"
# Creating cfd folder inside case folder
cfdFolderName="fine_A""$currAoA""_M""$currMach"
cfdFolderName="${cfdFolderName//"."/"_"}"


# Moving in the cfd folder
cd CFDFiles/
mkdir "$cfdFolderName"
cd "$cfdFolderName"

# Copying simulation template# Copying template .cfg into cfd folder
cp ../../configFiles/$templateName ./

# Substituting mach, alpha, and Re
sed -i "s/MACH_NUMBER= 0.7/MACH_NUMBER= ${currMach}/" $templateName
sed -i "s/AOA= 4.5/AOA= ${currAoA}/" $templateName
sed -i "s/REYNOLDS_NUMBER= 490000/REYNOLDS_NUMBER= ${currRe}/" $templateName
sed -i "s/RESTART_SOL= NO/RESTART_SOL= YES/" $templateName
sed -i "s%MESH_FILENAME= ../mesh/mesh.su2%MESH_FILENAME= ../../temporaryFiles/Gfine.su2%" $templateName
sed -i "s/CONV_FILENAME= history/CONV_FILENAME= history_${cfdFolderName}/" $templateName
sed -i "s/RESTART_FILENAME= restart_flow.dat/RESTART_FILENAME= restart_flow_${cfdFolderName}.dat/" $templateName
sed -i "s/VOLUME_FILENAME= flow/VOLUME_FILENAME= flow_${cfdFolderName}/" $templateName
sed -i "s/SURFACE_FILENAME= surface_flow/SURFACE_FILENAME= surface_flow_${cfdFolderName}/" $templateName
sed -i "s/MESH_OUT_FILENAME= mesh_out.su2/MESH_OUT_FILENAME= mesh_out_G${meshIndex}.su2/" $templateName
sed -i "s%SOLUTION_FILENAME= solution_flow.dat%SOLUTION_FILENAME= ../${previousSolutionName}/restart_flow_${previousSolutionName}.dat%" $templateName 
if [ $nCoresFine -gt 1 ]
then
    mpirun --oversubscribe -n $nCoresFine SU2_CFD $templateName  >"logG${cfdFolderName}.log"
else
    SU2_CFD $templateName  >"logG${cfdFolderName}.log"
fi