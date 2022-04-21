SAS = sas -nosplash -nologo -icon -sysin

default:
	@$(SAS) ./code/cleaning.SAS
	@$(SAS) ./code/analysis.SAS

verbose:
	@echo "job started at $$(date)"
	$(SAS) ./code/cleaning.SAS
	$(SAS) ./code/analysis.SAS
	@echo "job ended at $$(date)"
	
