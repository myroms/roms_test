# **ROMS Test Cases**

![roms_test](https://github.com/myroms/roms_test/assets/23062912/98128120-c5c8-4668-96aa-8ce88b3c947a)

# **License**

**Copyright (c) 2002-2023 The ROMS/TOMS Group**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# Overview

The Regional Ocean Modeling System (**ROMS**) framework is intended for users
interested in ocean modeling. Please check https://github.com/myroms for
instructions on registering into the **ROMS** community and downloading its source
code.

Currently, we have the following **`Test Cases`** that can be activated with
their respective **CPP** flags:

| Test Case |  Description |
| --------- | ------------ |
| **DAMEE_4** | North Atlantic Grid #4, 0.75&deg; resolution |
| **External** | **ROMS** input metadata files |
| **IRENE** | **ESMF/NUOPC** coupling for Hurricane Irene, 27-29 Aug 2011 |
| **WC13** | **ROMS** 4D-Var data assimilation, California Current System, 1/3&deg; resolution |
| **basin** | Big Bad Basin, Stommel/Munk wind-driven Western intensification |
| **benchmark** | Idealized Southern Ocean benchmark tests |
| **bio_toy** | One-dimensional (vertical) Biology Toy Tests |
| **bl_test** | Boundary Layers **KPP** Test |
| **bin** | **CSH** and **BASH** scripts |
| **canyon** | Homogeneous Coastal Form Stress Canyon Tests |
| **channel** | Idealized Uniform Periodic Channel, Optimal Perturbations Test |
| **dogbone** | Dog-bone Nesting Test Cases: Composite and Refinement Grids |
| **double_gyre** | Idealized Double-Gyre Generalized Stability Analysis Tests |
| **estuary_test** | Suspended Sediment Test in an Estuary |
| **flt_test** | Floats Lagrangian Trajectories 2D and 3D Tests |
| **grav_adj** | Gravitation Adjustment Test Problem |
| **inlet_test** | **ROMS/SWAN** coupling with **MCT** library |
| **kelvin** | Kelvin Wave Test |
| **lab_canyon** | Laboratory Canyon, A True Annulus Test in Polar Coordinates |
| **lake_jersey** | Idealized Nesting Refinement Tests |
| **lmd_test** | Large et al. (1994) **KPP** Test |
| **riverplume** | River Plume Tests |
| **seamount** | Tall Isolated Seamount Test |
| **sed_test** | Suspended Sediment Test in a Channel |
| **shoreface** | Shore Face Planar Beach Test |
| **soliton** | Equatorial Rossby Soliton Tests |
| **test_chan** | Sediment Test Channel Case |
| **test_head** | Sediment Test Headland Case |
| **upwelling** | Wind-Driven Upwelling/Downwelling over a Periodic Channel |
| **weddell** | Idealized Weddell Sea Shelf Application |
| **windbasin** | Wind-Driven Constant Coriolis Basin Test |

# Instructions

This repository contains idealized and realistic **Test Cases** that can be used
for testing different parts of **ROMS** kernels and algorithms. Use the following command to download the **ROMS Test** Cases repository:
```
git clone https://github.com/myroms/roms_test.git
```

Before downloading, ensure that your **`~/.gitconfig`** has the appropriate
**`git-lfs`** configuration for correctly downloading some test input and
observation NetCDF files. Otherwise, the **Test Cases** requiring input NetCDF
files will fail. The **Git LFS** is a command line extension and specification
for managing large files with **Git**. A sample of the configuration file looks
like this:
```
   more ~/.gitconf

   [user]
        name = GivenName MiddleName FamilyName
        email = your@email
   [credential]
        helper = cache --timeout=7200
        helper = store --file ~/.my-credentials
   [filter "lfs"]
        clean = git-lfs clean -- %f
        smudge = git-lfs smudge -- %f
        process = git-lfs filter-process
        required = true
```

Alternatively, you may execute **`git lfs pull`** at your location of this
repository to download a viable version of the **Git LFS** files from the
remote repository in **GitHub**. Also, to add the **LFS** filter to your
existing **`~/.gitconfig`** automatically, you could use **`git lfs install`**
from anywhere in your computer directory.

The **doxygen** version of **ROMS** is available at:
```
https://www.myroms.org/doxygen
```
The **WikiROMS** documentation and tutorials portal is available at:
```
https://www.myroms.org/wiki
```
