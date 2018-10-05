# smc2018

Code used for the following paper:

- [Krol, L. R., Mousavi, M., de Sa, V. R. & Zander, T. O. (in print). Towards Classifier Visualisation in 3D Source Space. In _2018 IEEE International Conference on Systems Man and Cybernetics (SMC)_.](https://lrkrol.com/files/krol2018smc-classifiervisualisation.pdf)

`main_csp`, `main_erp_lda` and `main_erp_corr` are the files used to produce the results presented in the paper for the three methods respectively.

This is **not** a public release of the classifier visualisation method. This code is heavily geared towards the data used for the paper. We are still fine-tuning the method and performing additional evaluations, and will release a tool for it when this is done.

In the meantime, however, the main trick is really this:

```matlab
weights = (EEG.icaweights * EEG.icasphere) * ldapatterns;
weights = abs(weights);
```

Where `ldapatterns` contains the classifier pattern(s) to analyse, and `EEG` is an EEGLAB dataset with an ICA decomposition. `weights` then contains the relative contributions of the different ICs to the given pattern(s). 

The (similarly work-in-progress) [BeMoBIL Pipeline](https://github.com/MariusKlug/bemobil-pipeline) has implemented this in the file `bemobil_distributed_source_localization`. You can use this file for a quick analysis of your single-subject patterns.
