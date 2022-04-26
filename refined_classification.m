% Implements the framework presented in
% "A robust weakly-supervised model for the detection and identification of oil emulsions on the sea surface using hyperspectral imaging" 
% By Ming Xie, Xiurui Zhang, Zhenduo Zhang, Ying Li, and Bing Han.
% Consult the first author through mingxie@dlmu.edu.cn in case you have any question with the codes

%This is the second step of the model. Run "initial clustering" module and obtain the clustering result before run this module
%The variables "clusters" (the initial clustering results) and "dataset" (preprosesed HSI) are necessary to train the model.

%assign the control points labels for classification.
WO_label=[WO];
OW_label=[OW];
SW_label=[SW];

%obtain the coordinates of potential training data
[WOy,WOx]=find(clusters==WO_label);
[OWy,OWx]=find(clusters==OW_label);
[SWy,SWx]=find(clusters==2);
WO_coord=cat(2,WOy,WOx);
OW_coord=cat(2,OWy,OWx);
SW_coord=cat(2,SWy,SWx);

%spatial filtering
WO_coord_filtered=[];
for m=2:(size(WO_coord,1)-1)
  if WO_coord(m,2)==WO_coord(m-1,2) && WO_coord(m,2)==WO_coord(m+1,2)
    WO_coord_filtered=cat(1,WO_coord_filtered,WO_coord(m,:));
  end
end

OW_coord_filtered=[];
for n=2:(size(OW_coord,1)-1)
  if OW_coord(n,2)==OW_coord(n-1,2) && OW_coord(n,2)==OW_coord(n+1,2)
    OW_coord_filtered=cat(1,OW_coord_filtered,OW_coord(n,:));
  end
end

%assign the number of training data for each category (it should be less than the number of spectra in category that has the least number of spectra) and generate the training dataset
NumSpe=5000;
WO_rand=randperm(size(WO_coord_filtered,1));
WO_coord_final=WO_coord_filtered(WO_rand(1:NumSpe),:);
OW_rand=randperm(size(OW_coord_filtered,1));
OW_coord_final=OW_coord_filtered(OW_rand(1:NumSpe),:);
SW_rand=randperm(size(SW_coord,1));
SW_coord_final=SW_coord(SW_rand(1:NumSpe),:);

WO_spe=[];
OW_spe=[];
SW_spe=[];
for i=1:NumSpe
  WO_spe=cat(2,WO_spe,squeeze(dataset(WO_coord_final(i,1),WO_coord_final(i,2),:)));
  OW_spe=cat(2,OW_spe,squeeze(dataset(OW_coord_final(i,1),OW_coord_final(i,2),:)));
  SW_spe=cat(2,SW_spe,squeeze(dataset(SW_coord_final(i,1),SW_coord_final(i,2),:)));
end
WO_spe=WO_spe';
WO_spe=cat(2,WO_spe,ones(NumSpe,1)*1);
OW_spe=OW_spe';
OW_spe=cat(2,OW_spe,ones(NumSpe,1)*2);
SW_spe=SW_spe';
SW_spe=cat(2,SW_spe,ones(NumSpe,1)*3);
filtered_data=cat(1,WO_spe,OW_spe,SW_spe);

% shuffle dataset
r=randperm(size(filtered_data,1)); 
shuffled_data=filtered_deata(r,:);

% generate training data and labels
train_data=shuffled_data(:,1:(size(filtered_data,2)-1));
train_label=shuffled_data(:,size(filtered_data,2));

train_data=train_data';
train_label=categorical(train_label); % convert to categorical label

inputSize = size(dataset,3); % dimension of input, which equals to the number of bands used for training
numHiddenUnits = 512; % number of neurons in the fully-connected layer
numClasses = 4; % number of classes, reprensents four types of oils

% setup layers
layers = [ ...
    sequenceInputLayer(inputSize)
    convolution1dLayer(3);
    reluLayer();
    maxPooling1dLayer(2,'Stride',2);
    convolution1dLayer(3);
    reluLayer();
    maxPooling1dLayer(2,'Stride',2);
    fullyConnectedLayer(numHiddenUnits);
    softmaxLayer();
    classificationLayer()];

% Setup hyperparameters
maxEpochs = 500; %maximum number of epochs
miniBatchSize = 27; % batch size

% Setup training option
options = trainingOptions('adam', ...
    'ExecutionEnvironment','cpu', ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'GradientThreshold',1, ...
    'Verbose',false, ...
    'Plots','training-progress');

% train network
net=trainNetwork(train_data,train_label,layers, options);

%model prediction
classification_results=[];
for i=1:size(dataset,1)
  for j=1:size(dataset,2)
    if dataset(i,j,1)==52991
      classification_results(i,j)=0;
    else
      test_spe=squeeze(data_cut(i,j,:));
      test_spe=test_spe';
      ypred = classify(net,test_spe, ...
        'MiniBatchSize',miniBatchSize, ...
        'SequenceLength','longest');
      classification_results(i,j)=double(ypred);
    end
  end
end

%visualize the final prediction
figure; 
imagesc(label2rgb(classification_results-1,'jet','w','shuffle')) ; 
axis image ; axis off ; 