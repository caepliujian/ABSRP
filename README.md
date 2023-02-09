# **ABSRP Users Guidance** #
Automatic Bond Separation Reaction Platform, 

## Cite: ##
- Jian Liu, Runwen Wang, Jie Tian, Kai Zhong, Fude Nie, Chaoyang Zhang, Calculation of Gas-phase Standard Formation Enthalpy via Ring-Preserved Connectivity-Based Hierarchy and Automatic Bond Separation Reaction Platform, *Fuel*, Volume 327, **2022**, 125203, https://doi.org/10.1016/j.fuel.2022.125203.

## Contact: ##
- **Dr. Jian Liu** liujian-12@caep.cn Institute of Chemical Materials, CAEP

## Description:  ##
1. The software must run on Win10/Win11.
2. ABSRP.exe is the executable file of this software.
3. Folder ‘Lib’ is the enthalpy library of small molecules.
4. Lib and ABSRP.exe must be in the same folder.
5. Folder ‘Example’ provides two examples.
6. The processing objects of this software are the ‘*.log’ files calculated out by Gassuian09.
## Warning: ##
- It is best to have a kelule ‘Name.mol’ file with the same name for each ‘Prefix.Name.log’ file. If not, the software will automatically generate a mol file, but there is a risk of getting wrong results.
- Users of this software must obtain the authorization of the author, any unauthorized users are considered to be illegal users, we do not exclude legal means to protect our rights.
## Activation: ##
1. ABSRP is installation-free, but it requires offline activation before use. 
2. Run the inactive software to obtain the serial number provided by the system, and then contact the software author to obtain the activation code for the serial number.
## Usage: ##
- ABSRP is an interactive application that can be unzipped and run by clicking 'absrp. exe'.
## Example: ##
###Update Lib：###

- This software supports automatic update of ‘Lib’.
- **Step 1:** Click ‘ABSRP.exe’ to run.
- **Step 2:** Click on '~/Example/Update' to run.
### **- Computational enthalpy of formation (gas):** ###
- **Step 1:** Click ‘ABSRP.exe’ to run.
- **Step 2:** Click on '~/Example/HOFG' to run.

*The results are write to a file named ‘Out.csv’ at the selected directory, in the format of ‘Prefix.Name.log, HOF(raw), HOF(corrected)’ (in kJ/mol), as follows:*


> Mol_1.log,136.3,131.36

> Mol_2.log,93.98,100.05

…….

> Mol_n.log, ####, ####
