<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/ad6a7ef1-1fed-4b2e-96b9-9c53615b9333">

## 4D-Var Tutorial: RBL4D-Var Forecast Cycle Observation Impacts

Computation of the observation impacts for the forecast cycle involves
multiple steps, so it is important that you follow the instructions
below carefully and perform all the steps described in the order in
which they are presented. Please do not deviate from these instructions.

**Figure 1** shows a schematic representation of a typical analysis-forecast
cycle using **ROMS**. During the analysis cycle, a background solution
(represented by the blue line) is corrected using observations that are
available during the analysis window. The analysis state estimate at the
end of the analysis window is then used as the initial condition for a forecast.
The forecast generated during the forecast cycle from the **4D-Var** analysis
is represented by the red curve. The forecast skill on any day can then be
assessed by comparing it to a new analysis that verifies on the same day,
or by comparing the forecast with new observations that have not yet
been assimilated into the model.

<img width="600" alt="image" src="https://github.com/myroms/roms_test/assets/23062912/e6e46069-f78a-4ffb-967f-4f45bf6960d2"> 

**`Figure 1:`** A schematic of a typical operational analysis-forecast cycle. 
During the analysis cycle, an ocean state estimate is computed using
4D-Var to assimilate all available observations. The blue curve represents
the background circulation, **X<sub>b</sub>**, for this cycle and is derived
from the state estimate from the previous **4D-Var** cycle. The number of 
time steps during the analysis cycle is given by **NTIMES_ANA**. At the end of
the analysis cycle, there are two possible forecasts: **FCAT** - the red forecast,
which is initialized using the state estimate at the end of the analysis cycle,
and **FCTB** - the green forecast, which extends the 4D-Var background into the
forecast cycle. The number of time steps during the forecast cycle is **NTIMES_FCT**.
These two forecasts can be verified against either a new analysis or against
new observations during the `verification interval`. The red forecast **FCTA** has
benefited from the observations assimilated during the analysis interval, while
the **green** forecast **FCTB** has not. Therefore, the difference in forecast
error between **FCTA** and **FCTB** can be used to quantify the impact of the 
observations assimilated during the analysis cycle on the subsequent forecast
skill of **FCTA**.

### Forecast Cycle Observation Impacts Steps:

You must perform the following calculations in the order shown below:

**1.** Run forecast **`FCSTAT`** - the forecast initialized from the **RBL4DVAR-RPCG** analysis
       of **Exercise 3**. Ensure that your **RB4DVAR-RPCG** output files are saved in the
       sub-directory called **`RBL4DVAR/EX3_RPCG`**. Forecast Cycle Observation Impacts will
       run the non-linear model using **BULK_FLUXES**. The computed fluxes will be used in
       Steps (**2**) and (**3**).

**2.** Run forecast **`FCSTA`** - the forecast initialized from the **RBL4DVAR-RPCG** analysis
       of **Exercise 3**, but with **BULK_FLUXES** undefined, and using the surface fluxes
       saved in Step (**1**).

**3.** Run forecast **`FCSTB`** - the forecast initialized from the background solution used
       in the **RBL4DVAR-RPCG** analysis of **Exercise 2**. Ensure that your **RBL4DVAR-RPCG**
       output files are saved in the sub-directory called **`RBL4DVAR/EX3_RPCG`**. **FCSTB**
       will run the nonlinear model with **BULK_FLUXES** undefined and use the surface fluxes
       saved in Step (**1**).

**4.** Create the impact forcing files for the adjoint model:

   - Using the verifying analysis as a surrogate for the true state -
     Go to the directory **`../Data`** and run the script **`adsen_37N_transport_fcst.m`**.
     This will create two NetCDF files called **wc13_foi_A.nc** and **wc13_foi_B.nc**.

   - Using new observations as a surrogate for the true state -
     Go to the directory **`../Data`** and run the script **`adsen_SST_fcst.m`**.
     This will overwrite two existing NetCDF files called **wc13_oifA.nc** and
     **wc13_oifB.nc**.

**5.** Run the forecast observation impact driver for the two cases in (**4**).

---

### References:

- Drake, P., C.A. Edwards, H.G. Arango, J. Wilkin, T. TajalliBakhsh, B. Powell,
  and A.M. Moore, 2023: Forecast Sensitivity-based Observation Impact (FSOI)
  in an analysis–forecast system of the California Current Circulation, *Ocean
  Model.*, 182, https://doi.org/10.1016/j.ocemod.2022.102159.

- Moore, A.M., H.G. Arango, G. Broquet, B.S. Powell, A.T. Weaver,
  and J. Zavala-Garay, **2011**: The Regional Ocean Modeling System
  (ROMS)  4-dimensional variational data assimilation systems,
  Part I - System overview and formulation, *Prog. Oceanogr.*,
  **91**, 34-49, https://doi.org/10.1016/j.pocean.2011.05.004.

- Moore, A.M., H.G. Arango, G. Broquet, C. Edward, M. Veneziani,
  B. Powell, D. Foley, J.D. Doyle, D. Costa, and P. Robinson,
  **2011**: The Regional Ocean Modeling System (ROMS) 4-dimensional
  variational data assimilations systems, Part II - Performance
  and application to the California Current System, *Prog.
  Oceanogr.*, **91**, 50-73, 
  https://doi.org/10.1016/j.pocean.2011.05.003.

- Moore, A.M., H.G. Arango, G. Broquet, C. Edward, M. Veneziani,
  B. Powell, D. Foley, J.D. Doyle, D. Costa, and P. Robinson,
  **2011**: The Regional Ocean Modeling System (ROMS) 4-dimensional
  variational data assimilations systems, Part III - Observation
  impact and observation sensitivity in the California Current
  System, *Prog. Oceanogr.*, **91**, 74-94,
  https://doi.org/10.1016/j.pocean.2011.05.005.

