# Supplementary information to run Stroke segmentation software
A repository for supplementary considerations required to run certain stroke segmentation algorithms

## Run environment
- Debian 9.9 Stretch
- Xeon E5-1650 v4 3.60 GHz 12-Thread
- 64GB RAM
- R 3.3.3

# LINDA
The stroke segmentation software LINDA is already well documented (https://github.com/dorianps/LINDA) and easy enough to get running for native space segmentation, but could do with a few more comments regarding.

The original paper is at: http://doi.org/10.1002/hbm.23110

A recent (anno 2019) comparison paper of LINDA with other stroke segmentation algorithms can be found at: http://doi.org/10.1002/hbm.24729

This paper found LINDA superior in most aspects, but not every aspect. Computational time was one issue, but with adequate computational power (medium end enterprise desktop anno 2019) it is not a significant issue compared to other algorithms in the neuroscience field, and considering the difficulty amassing many stroke cases for a study.

## Libraries and additional software required 
There are two instances that may prove troublesome if you haven't already installed the R package "devtools" and "ANTsR"/"ITKR".

For "devtools" a few additional libraries may be required. Which libraries exactly will be stated in the error specification in the R console. This can be tedious depending on how many libraries you are missing.

For ANTsR, ITKR and (or at least one of these?) LINDA you will require Cmake 3.10.2 or later. For Debian Stretch, you can only get 3.7.2 via the package manager. It is therefore required to download (https://cmake.org/download/) an adequate version yourself and place it under "/usr/local/cmake_3_X_X". Root access is necessary for this. Remember to export the "bin" folder inside "cmake_3_X_X" to your console and uninstall older versions to make it find this new version.

## Flipping images
To flip images we used FSL (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/Fslutils), more specifically "fslorient". The author of FSL encourages that the user has read what the function "fslorient" actually do, because it can easily make unwanted changes to original data if you are not careful.

1. Make a copy of the original nifti image, such that you can keep the original image and for bilateral stroke segment (although bilateral stroke segmentation is not recommended).
2. Call "fslorient -swaporient copied_t1w.nii.gz".

A .sh script may be the most efficient to flip the required images.

## Speed and core/thread usage comments
In the example run (done on a single core) at LINDA's GitHub page, the run took 3.5 hours. This may appear as "too much" in some situation. But, as experienced on our test rig, the computational time is at best 1/7th of this. It is unknown what Hz the CPU in the example run had.

### Test case 1 - Large stroke
Took 30.5 minutes. This ran without parallell specifications in R (lapply, etc), although many processes throughout the segmentation used all available threads. This may indicate that user specified parallell processing is not necessarily beneficial with a relatively small amount of cores (< 6 cores and < 12 threads).

The result appears fairly good for descriptive purposes when thresholded at 50% (or 0.5), but not close to voxel perfection. Prediction range was at 0 to 1.

### Test case 2 - Medium stroke



### Test case 3 - Small stroke
Took 41.6 minutes. This ran without parallell specifications in R (lapply, etc), although many processes throughout the segmentation used all available threads. Definitely slower than the Large stroke case.

It found the actual stroke site, but also found 3-4 other unrelated false positives. The one largest false positive  essensially doubled the true estimate was unfortunate, but not surprising that the algorithm thought at least parts of it was a stroke due to a local cortex cluster darkening on the T1w image. The remaining smaller errors were expected as with WMH segmentation algorithms, and were not of detrimental size.

A manually selected threshold of 5% (or 0.05) found the actual stroke site sufficiently, and the prediction range was 0 to 0.1783. This can pose a challenge for selecting a single threshold across stroke cases.

It is reasonable to expect lower estimates to be overesimates. If NULL cases are returned from the LINDA algorithm it is consequently also safe to say that it has underestimated the stroke.

## Storage consumption
Each new run/prediction is expected to use at least up to 200MB of storage. 2 out of 3 of our runs took this much space.
(Original nii.gz files use around 12MB for 176x256x256 INT16 images)
