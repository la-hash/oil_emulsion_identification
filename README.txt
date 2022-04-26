# Identifying oil emulsions in hyperspectral remote sensing data
 
This demo includes the code in Matlab language for the paper "A robust weakly-supervised model for the detection and identification of oil emulsions on the sea surface using hyperspectral imaging"
by Ming Xie, Xiurui Zhang, Zhenduo Zhang, Ying Li, and Bing Han.

For any questions, please contact the first author through: mingxie@dlmu.edu.cn.

Warning: the codes were tested using Matlab R2019a. They might be incompatible with other versions.  

The data used to test model were the hyperspectral imagery obtained from AVIRIS, which were openly provided by USGS and NASA. They can be downloaded from https://aviris.jpl.nasa.gov/alt_locator/

This model would also work for the HSI from other sources, but the user should check if the the HSI cube is correctly generated after load the data. 

The code of mean shift function is obtained from the sample code of a book chapter "Mean shift segmentation" in the book "Image Processing, Analysis, and Machine Vision: A MATLAB Companion" edited by Tomáš Svoboda, Jan Kybic, and Václav Hlaváč, and should be credited to Jan Kybic.


To use the codes:
    - Run "initial_clustering.m" and get the initial clustering results, examine the clustering results;
    - Adjust the bandwidth parameter until reaching the satisfactory clustering results, keep the two variables: "clusters" and "dataset" .
    - Pick control point labels for each category and run "refined_classification.m".