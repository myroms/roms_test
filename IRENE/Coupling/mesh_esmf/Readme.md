<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## Hurricane Irene: CDEPS/CMEPS Coupling

This directory includes **create_mesh.sh** script and the mesh files that
it generates to run the **DATA-ROMS** coupling for Hurricane Irene using
the **CDEPS/CMEPS** couplers, which are **NUOPC**-based.

We can run the **DATA-ROMS** coupling system with the **CDEPS** connectors
or **CMEPS** mediator.

Notice that **CMEPS** is a mesh-based mediator which can be used in
structured and unstructured grids.

### Configuration scripts:

```
  creates_mesh.sh               Script to create mesh NetCDF files components grids
```

### The output Files:

The **mesh** NetCDF files are created for you:

- **DATA** component: **ECMWF-ERA5** dataset
  
  - **era5_IRENE_ESMFmesh.nc**

- **DATA** component: **NCEP-NARR** dataset

  - **lwrad_down_narr_IRENE_ESMFmesh.nc**
  - **lwrad_narr_IRENE_ESMFmesh.nc**
  - **Pair_narr_IRENE_ESMFmesh.nc**
  - **Qair_narr_IRENE_ESMFmesh.nc**
  - **rain_narr_IRENE_ESMFmesh.nc**
  - **swrad_daily_narr_IRENE_ESMFmesh.nc**
  - **swrad_narr_IRENE_ESMFmesh.nc**
  - **Tair_narr_IRENE_ESMFmesh.nc**
  - **Uwind_narr_IRENE_ESMFmesh.nc**
  - **Vwind_narr_IRENE_ESMFmesh.nc**
  
- **ROMS** component:
  
  - **irene_roms_grid_rho_ESMFmesh.nc**

### How to Run:

It uses the data located in **`../../Data/FRC/*_IRENE.nc`** and
**`../../Data/ROMS/irene_roms_grid.nc`** to generate all the above
**mesh** NetCDF files. To execute:
```
./create_mesh.sh
```
