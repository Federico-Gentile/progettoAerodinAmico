### USER DEFINED INPUT COMING FROM loopRANSCoarse.sh ###
# alpha, mach, re, coreNumber

# Name of the template .cfg file
templateName="RANSTemplate.cfg"

currAoA="$1"
currMach="$2"
currRe="$3"
coreNumber=$4
# Creating cfd folder inside case folder
cfdFolderName="coarse_A""$currAoA""_M""$currMach"
cfdFolderName="${cfdFolderName//"."/"_"}"


# Moving in the cfd folder
cd CFDFiles/
mkdir "$cfdFolderName"
cd "$cfdFolderName"

# Copying simulation template# Copying template .cfg into cfd folder
cp ../../configFiles/$templateName ./coarse_$templateName
templateName="coarse_""$templateName"

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
    
if [ $coreNumber -gt 2 ]
then
    mpirun -bind-to socket --use-hwthread-cpus -n $coreNumber SU2_CFD $templateName  >"logG${cfdFolderName}.log"
else
    SU2_CFD $templateName  >"logG${cfdFolderName}.log"
fi

cp "logG${cfdFolderName}.log" ../../imfinished/
