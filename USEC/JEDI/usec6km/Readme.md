<img width="824" alt="image" src="https://github.com/user-attachments/assets/d15ec2a4-70e3-410f-a2ae-d09682a9f0f2">

## ROMS-JEDI Data Assimilation Framework: Regional U.S. East Coast 6km Application

This directory shows how to configure the **ROMS-JEDI** Data Assimilation framework on a regional **ROMS** application. It uses our Coupled Forecast Framework (**CFF**) configuration of the :us: U.S. East Coast (**USEC**) at 6 km grid resolution during the Hurricane Dorian period (Aug 27-Sep 2, 2019). This configuration is very complex and intended for advanced users familiar with **ROMS**, **JEDI**, and data assimilation. Please check the following [ROMS-JEDI Tutorial](https://github.com/myroms/roms-jedi/wiki/ROMS%E2%80%90JEDI-Tutorial) for more information.

The **ROMS-JEDI** interface utilizes the public Joint Effort for Data Assimilation Integration (**JEDI**) framework, a set of model-agnostic building blocks hosted in the Joint Center for Satellite Data Assimilation (**JCSDA**) GitHub repositories. You do not need to download the **JEDI** repositories, as they are cloned during configuration. For more information about **JEDI**, please visit https://www.jcsda.org/jedi-academies.

| CFF-USEC 6 km    |  Mesh Zoom               |         
:-----------------:|:-------------------------:
|<a href="https://github.com/user-attachments/assets/80feced9-8733-4850-85d1-0596d7f68a1c"><img width="800" alt="Usec6km" src="https://github.com/user-attachments/assets/80feced9-8733-4850-85d1-0596d7f68a1c" /></ a> | <a href="https://github.com/user-attachments/assets/0b7af6bd-9dbd-45e2-bc38-f0df90067ae9"><img width="800" alt="Usec6km_zoom" src="https://github.com/user-attachments/assets/0b7af6bd-9dbd-45e2-bc38-f0df90067ae9" /></a> |

## Instructions

To configure, compile, and run the **ROMS-JEDI** framework for the **USEC** 6km grid, we use the **Generic** Application strategy delineated in the [tutorial](https://github.com/myroms/roms-jedi/wiki/ROMS%E2%80%90JEDI-Tutorial):

1. Clone the **ROMS-JEDI** interface from its public repository at https://github.com/myroms. Please note that only the **develop** branch is accessible. The research branches are private and in the **JCSDA** internal repositories, restricted to **JEDI** developers and partners. You only need to download **ROMS-JEDI** once per computer, but you must update it frequently with **`git pull`**. This is necessary because the **JEDI** abstract building blocks and model interfaces continually evolve and improve. As a result, the private and public **develop** branches are often updated.

   ``` d
   % cd MySourceCodeRootDir
   % git clone https://github.com/myroms/roms-jedi.git         !> It creates the roms-jedi subdirectory)
   % cd roms-jedi                                              !> ROMS-JEDI interface root directory
   ```

2. Generate **JEDI** input **YAML** files from templates using the [**`template2yaml.pl`**](https://github.com/myroms/roms-jedi/blob/develop/tools/workflow/Readme.md#creating-roms-jedi-input-yaml-files-template2yaml) **Perl** script. They are located in the `testinput` subdirectory.

   ``` d
   % ln -s <MySoureCodeRootDir>/roms-jedi/tools/workflow/template2yaml.pl <MyHomeRootDir>/bin
   % rehash
   % template2yaml.pl usec6km_yaml_parameters.dat <MySourceCodeRootDir>/roms-jedi -notest -obs t,s,sst,sss,uv_codar,adt
   ```
   Notice that I am linking the [**`template2yaml.pl`**](https://github.com/myroms/roms-jedi/blob/develop/tools/workflow/Readme.md#creating-roms-jedi-input-yaml-files-template2yaml) **Perl** script to my **<MyHomeRootDir>/bin**, so I can execute it from anywhere.

3. To configure **USEC6KM** application for **JEDI**, use the **`jedi_config.csh`** or **`jedi_config.sh`** scripts. In this context, **USEC6KM** is the CPP option that identifies this **ROMS** application. The **JEDI** configuration script also requires additional arguments for the **`ecbuild`** command in general **ROMS** applications. For more details, please refer to the [**`jedi_config`** script documentation](https://github.com/myroms/roms-jedi/tree/develop/tools/workflow/Readme.md#jedi-configuration-script-jedi_config).
   ``` d
   % jedi_config.sh usec6km -a USEC6KM <MyConfigRootDir>/ROMS/JediApps/usec6km -n 12 -n_min 4

   Current directory: <MySourceCodeRootDir>/roms-jedi

   Created subdirectory: Bundle_usec6km
   Created subdirectory: build_usec6km

   'bundle/.gitignore' -> 'Bundle_usec6km/.gitignore'
   'bundle/CMakeLists.txt' -> 'Bundle_usec6km/CMakeLists.txt'

   <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
   To configure 'ecbuild' with the 'Release' build, you need to type or copy and paste:

   cd build_usec6km;
   ecbuild -DMPIEXEC_EXECUTABLE=$MPIRUN -DMPIEXEC_NUMPROC_FLAG="-n" -DMPIEXEC_NUMPROC_MIN=4 -DMPIEXEC_NUMPROC=12 -DPython3_EXECUTABLE="`which python3`" -DROMS_APP=USEC6KM -DROMS_APP_DIR=<MyConfigRootDir>/ROMS/JediApps/usec6km -DCMAKE_BUILD_TYPE=Release ../Bundle_usec6km
   <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
   ```
> [!CAUTION]
> We recommend placing the source code **`<MySourceCodeRootDir>`** path and application configuration **`<MyConfigRootDir>`** path, containing the necessary input NetCDF files, in different locations to avoid messy, confusing setups. The source code is managed under **Git**. The **JEDI** framework works with partial paths and generates all the appropriate file links to run from **`<MySourceCodeRootDir>/roms-jedi/build_usec6km/roms-jedi/test`**.

4. To compile and link your generic **ROMS-JEDI** application, use the following **CMake** command from **`<MySourceRootDir>/roms-jedi/build_usec6km`** sub-directory:

   ``` d
   % make -j 10
   ```
   Compiling/linking the entire system will take around **30 minutes**. The code is primarily written in **C++** and **Fortran 2003**.

5. Run the **ROMS-JEDI** application. Using the **batch_tests.sh** or **slurm_tests.sh** script, as designed for the **Default Application**, you can run all available interface unit tests. Optionally, you may run specific data assimilation algorithms individually in an operational data assimilation environment.

   ``` d
   % cd roms-jedi/test
   % batch_test.sh
   ```
