![Alt Text](Logo.gif?raw=true "Logo")

November 5th, 2020

Yishaia Zabary & Assaf Zaritsky - yishaiaz@post.bgu.ac.il, assafzar@gmail.com

## "A Matlab pipeline for spatiotemporal quantification of monolayer cell migration"
### The repository includes Matlab source code.
### This repository is part of the book series "Neubias Bioimage Analysis"
The pipeline receives as input the raw image data in one of the following formats: tiff stack, zvi (Zeiss Vision Image) or lsm (Zeiss tiff based proprietary format). Each data file is a single time-lapse experiment. We assume label-free imaging and analyze only the first channel in multi-channel image stacks.
The pipeline includes four conceptual steps,  each depending on the previous one and thus must be executed sequentially.  The first two steps are performed at the single time-lapse level (seequantifyMonolayerMigration-Main.m).   The  rest  of  the  pipeline  is  for  the  analysis  of  multiple  experi-ments,  enabling the comparison between different experiments and con-ditions, and is not recommended for novice users (see quantifyMonolayerMigrationBulkMain.m)

- Segmenting each image to cellular (foreground) and background regions, and calculating the velocity fields. The output of this stage includes quantification of     the wound healing over time, visualizations of the foreground/background segmentation, visualization of the velocity fields, and more detailed visualization of     outputs for advanced debugging purposes.
- Calculating kymographs that capture the experiment’s spatiotemporal dynamics. The output of this stage includes visualization of the kymographs.
- Extracting spatiotemporal feature vectors from each kymograph.
- Calculating the principal components of these features across experiments.

###
- Input: single or multiple time laspe of monolayer migration experiment (phase contrast)
- Output: speed, directionality kymographs & visualizations, wound healing rate, feature extraction & PCA analysis on multiple experiments.

### Input

- Input: file name for time-lapse data, or directory name for multiple time-lapse data.

### Required parameters
- `params.timePerFrame` % Imaging frequency: time between acquired frames (minutes).
- `params.nRois` % Number of region of interest to segment, 1 - for 1-side advancing monolayer, 2 - wound healing.
- `params.pixelSize` % Phyiscal pixel size (um).
- `params.maxSpeed` % The estimated maximal speed of the inspected phenotype
- `params.minNFrames` % The index of the first frame to include in the analysis.
- `params.maxNFrames` % The frame number to end the analysis

### Sample data
- Download raw images via the link: [SampleData]() , called `https://doi.org/10.5281/zenodo.4129846`
- The default parameters in `quantifyMonolayerMigrationBulkMain.m` and `quantifyMonolayerMigrationMain.m` were set for the single expanding monolayer directory of this data.

### Output folders
- Each time-lapse has its own folder (e.g., `EXP_16HBE14o_1E_SAMPLE`). 
- Each time-lapse folder  includes the following sub-folders, each containing per-frame outputs as described next (`.mat` file):
  - `images`: raw images
  - `MF/mf`: PIV (velocity fields per frame) 
  - `ROI/roi`: segmentation (ROI per frame)

The following folders include summary for all time-lapse analyzed and are located at the parent folder (at the level of the time-lapse folders):
- `healingRate`: healing rate over time in a `.mat` file
- `kymographs`: sub-folders for speed, directionality and coordination, each one holds the kymographs in `.eps` (visualization) and `.mat` (data) formats
- `segmentation`: video showing the visualization over time
- `kymographFeatures` - quantitative features extracted from the kymographs
- `PCA_Results` - dimensionality reduction results

-----------------

### Citation

Please cite the following chapter when using this code:
TBD

Please contact Yishaia Zabary, yishaiaz@post.bgu.ac.il, for any questions / suggestions / bug reports.

-----------------

+ For more work from the Assaf Zaritsky Lab: https://www.assafzaritsky.com/

