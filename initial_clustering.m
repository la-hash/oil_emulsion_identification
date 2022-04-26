% Implements the framework presented in
% "A robust weakly-supervised model for the detection and identification of oil emulsions on the sea surface using hyperspectral imaging" 
% By Ming Xie, Xiurui Zhang, Zhenduo Zhang, Ying Li, and Bing Han.
% Consult the first author through mingxie@dlmu.edu.cn in case you have any question with the codes

%This is the first step of the model. Run this step and generate the clustering results for training data filtering before run "refined_classification" module

%load HSI and generate HSI cube,change the variables of filename and sizes.
samples=;                                                          
lines=;
bands=; 
raw_data=multibandread(filename, [lines,samples,bands], 'uint16', 0, 'bip', 'ieee-le');

%select the bands for analysis. An example of AVIRIS data is shown as below
bands=[1:104,123:149,173:224];
dataset=raw_data(:,:,bands);

%flatten the HSI cube for PCA 
flat_data=[];
for i=1:size(dataset,1)
    flat_data=cat(1,flat_data, squeeze(dataset(i,:,:)));
end

%genetrate PCA map
x=zscore(flat_data);
[coeff,score,latent,tsquare]=pca(x);
post_pca=x*coeff(:,1:3); %extract the first three principal components
post_pca2(1,:,:)=post_pca;
img_pca=[];
for j=1:size(dataset,1)
    img_pca=cat(1,img_pca, post_pca2(:,(size(dataset,2)*(j-1)+1):size(dataset,2)*j,:));
    j
end

%Mean shift image clustering
img=imresize(img_pca,1) ;
%adjust the bandwidth parameter to improve the results if necessary
clusters=meanshift(img,10,1,0.1,'gaussian') ;
 
%visualize the clustering results
figure; 
imagesc(label2rgb(clusters-1,'jet','w','shuffle')) ; 
axis image ; axis off ; 
