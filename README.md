# Braille Letter Representations

This repository containes code for the manuscript ["The transformation of sensory to perceptual braille letter representations in the visually deprived brain"](https://doi.org/10.1101/2024.02.12.579923). 

All analyses have been tested using Matlab R2020b on MacOS Big Sur version 11.5.2 and Matlab R2021a on CentOS 7.

The preprocessed data required for these analyses can be downloaded [here](https://osf.io/a64hp/). Please make sure the folders fMRI_preprocessed and EEG_preprocessed are located in the /data folder before starting the analyses.

## Requirements

- Matlab
- [LIBSVM toolbox](https://www.csie.ntu.edu.tw/~cjlin/libsvm/): the functions required for Matlab are provided in /toolboxes
- [R](https://cran.r-project.org/) for plotting

## Analyses

### Decode Braille letter representations in space (runtime: ~2min) 
   
```sh
fmri_analysis.m
```

### Decode Braille letter representations in time (runtime: ~10min) 

Fast parameters (default): The fast parameters downsample the EEG time course with a 10ms resolution and 5 permutations. 

Original parameters: 100 permutations with 1ms resolution.

```sh
eeg_analysis.m
```
### Relate Braille letter representations in space to similarity ratings (runtime: <1min) 

```sh
rsa_fmri_beh.m
```

### Relate Braille letter representations in time to similarity ratings (runtime: <1min) 

Fast parameters (default): The fast parameters downsample the EEG time course with a 10ms resolution and 5 permutations. 

Original parameters: 100 permutations with 1ms resolution.

```sh
rsa_eeg_beh.m
```

Please be aware that results can differ because of the random assignment of trials to training and testing bins.
