# Braille Letter Representations

This repository containes code for the manuscript ["The transformation of sensory to perceptual braille letter representations in the visually deprived brain"](https://doi.org/10.1101/2024.02.12.579923). 

The code has been tested using Matlab R2020b on MacOS Big Sur 11.5.2, Matlab R2021a on CentOS 7 and Matlab2023b on MacOS Sonoma 14.2.1.

The preprocessed data required for these analyses can be downloaded [here](https://osf.io/a64hp/). Please make sure the folders fMRI_preprocessed and EEG_preprocessed are located in the /data folder before starting the analyses.

You can clone this repository to local using:
```sh
git clone https://github.com/marleenhaupt/BrailleLetterRepresentations.git
```

## Requirements

- Matlab
- [LIBSVM toolbox](https://www.csie.ntu.edu.tw/~cjlin/libsvm/): no download required, the Matlab functions are provided in /toolboxes
- [R](https://cran.r-project.org/): for plotting

## Analyses

Please navigate to the code folder and then start running the analysis of interest.

```sh
cd ./code
```

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
