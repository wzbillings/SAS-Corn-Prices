# Code

This folder contains all SAS code files necessary to reproduce the analysis discussed in the [manuscript](../manuscript).
Brief descriptions of the code files are as follows.

* `cleaning.SAS`: imports all raw datasets. The data sets are then cleaned and merged, and the
`grains.sas7bdat` SAS dataset is exported.
* `analysis.SAS`: loads the cleaned SAS dataset, and runs a variety of statistical analysis.

In order to reproduce my results, you should follow these steps.

* Using GNU `make`:
  1. Clone the repository (or download and unzip).
  2. Using a terminal, go to the repository and then run the `make` command.
* Using SAS on demand for Academics:
  1. Upload the raw data files and code files to the SAS server. If you want to use your
  local SAS installation instead of SAS on Demand, you can instead download the files to your local drive.
  2. Change the `libref` and `filename` statements in `cleaning.SAS` to match where you uploaded the data files.
  3. Run `cleaning.SAS`. Note where the output dataset, `grains.sas7bdat` is saved.
  4. Change the `libref` statement in `analysis.SAS` to match the location of `grains.sas7bdat`.
  5. Run `analysis.SAS`. The results displayed should match those in the manuscript.
