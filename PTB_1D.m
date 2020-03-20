%% Berken Utku Demirel
clearvars
clc
close all
%% Load data
data_MI = load('data_MI.mat').data_MI; 
data_Normal = load('data_Normal.mat').data_Normal;
%%  Z - score normalization and labeling MI(0) and Normal(1)

for i = 1:length(data_Normal)
   
    data_Normal(i,:) = zscore(data_Normal(i,:));
    data_Normal(i,652) = 1;
    
end

for i = 1:length(data_MI)
   
    data_MI(i,:) = zscore(data_MI(i,:));
    data_MI(i,652) = 0;
    
end

%% Split data to training and testing randomly

[m,n] = size(data_MI) ;
P = 0.90 ;
idx = randperm(m)  ;
Training_and_validate_MI = data_MI(idx(1:round(P*m)),:) ; 
Testing_MI = data_MI(idx(round(P*m)+1:end),:);

% Normal signal
[m,n] = size(data_Normal) ;
P = 0.90 ;
idx = randperm(m)  ;
Training_and_validate_Normal = data_Normal(idx(1:round(P*m)),:) ; 
Testing_Normal = data_Normal(idx(round(P*m)+1:end),:);

%% Split training data to validation

% MI
[m,n] = size(Training_and_validate_MI) ;
P = 0.70 ;
idx = randperm(m)  ;
Training_MI = Training_and_validate_MI(idx(1:round(P*m)),:) ; 
Validate_MI = Training_and_validate_MI(idx(round(P*m)+1:end),:);

% Normal signal
[m,n] = size(Training_and_validate_Normal) ;
P = 0.70 ;
idx = randperm(m)  ;
Training_Normal = Training_and_validate_Normal(idx(1:round(P*m)),:) ; 
Validate_Normal = Training_and_validate_Normal(idx(round(P*m)+1:end),:);

Training_data = [Training_Normal ; Training_MI];
Validate_data = [Validate_Normal ; Validate_MI];
Test_data = [Testing_Normal ; Testing_MI];

Yvalidate = categorical(Validate_data(:,652));
XValidate = reshape(Validate_data(:,1:651),[1, 651, 1, 13696]);

YTrain = categorical(Training_data(:,652));
XTrain = reshape(Training_data(:,1:651),[1, 651, 1, 31959]);

YTest = categorical(Test_data(:,652));
XTest = reshape(Test_data(:,1:651),[1, 651, 1, 5073]);

%% Constructing CNN

layer_activation = leakyReluLayer;

layers = [imageInputLayer([1 651])
    convolution2dLayer([1 102],3,'stride',1)
    layer_activation
    maxPooling2dLayer([1 2],'stride',2)
    convolution2dLayer([1 24],10,'numChannels',3)
    layer_activation
    maxPooling2dLayer([1 2],'stride',2)
    convolution2dLayer([1 11],10,'stride',1,'numChannels',10)
    layer_activation
    maxPooling2dLayer([1 2],'stride',2)
    convolution2dLayer([1 9],10,'numChannels',10)
    layer_activation
    maxPooling2dLayer([1 2],'stride',2)
    fullyConnectedLayer(30)
    fullyConnectedLayer(10)
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];


options = trainingOptions('adam', ...
    'MiniBatchSize',128, ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',60, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{XValidate,Yvalidate}, ...
    'ValidationFrequency',10, ...
    'Verbose',true, ...
    'Plots','training-progress');

net = trainNetwork(XTrain,YTrain,layers,options);

result = predict(net,XTest,'ReturnCategorical', true);
get_my_score(double(YTest), double(result))
