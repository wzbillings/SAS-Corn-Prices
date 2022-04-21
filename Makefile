SAS = sas -nosplash -nologo -icon -sysin

verbose:
	@echo "job started at $$(date)"
	$(SAS) ./code/cleaning.SAS
	$(SAS) ./code/analysis.SAS
	@echo "job ended at $$(date)"
	
