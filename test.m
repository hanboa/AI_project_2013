function [recall, precision] = test(X, bit, method, Dic)
%
% demo code for generating dictiaonry projection code and evaluation
% input X should be a n*d matrix, n is the number of images, d is dimension
% ''method'' is the method used to generate projection code
%

% Dictionary
sparseCoding = load('dictionary_L1_b512_30600sampling_20140103T010408.mat');
Dic = sparseCoding.B;
method = 'DIC'

% parameters
averageNumberNeighbors = 5;    % ground truth is 50 nearest neighbor
num_test = 3;                % 1000 query test point, rest are database
bit = 128;%bit;                      % bits used

%X = gist_gen(); %don't use gist
load IMAGES.mat
windowSize = 14;% the window size of a patch
num_totalSamples = 10000;% the number for sampling total patches
num_thresholdSamples = 5;% the number of samples to decide a threshold
X_patches = getdata_imagearray(IMAGES, windowSize, num_totalSamples);
X = X_patches';

% split up into training and test set
[ndata, D] = size(X);
R = randperm(ndata);
Xtest = X(R(1:num_test),:);
R(1:num_test) = [];
Xtraining = X(R,:);
num_training = size(Xtraining,1);
clear X;

% define ground-truth neighbors (this is only used for the evaluation):
R = randperm(num_training);
DtrueTraining = distMat(Xtraining(R(1:num_thresholdSamples),:),Xtraining); % sample 5 points to find a threshold
Dball = sort(DtrueTraining,2);
clear DtrueTraining;
Dball = mean(Dball(:,averageNumberNeighbors));% take "averageNumberNeighbors"th as the relative standard threshold of similarity
% scale data so that the target distance is 1
Xtraining = Xtraining / Dball;
Xtest = Xtest / Dball;
Dball = 1;
% threshold to define ground truth
DtrueTestTraining = distMat(Xtest,Xtraining);
WtrueTestTraining = DtrueTestTraining < Dball;
clear DtrueTestTraining

% generate training ans test split and the data matrix
XX = [Xtraining; Xtest];
% center the data, VERY IMPORTANT
sampleMean = mean(XX,1);
XX = (XX - repmat(sampleMean,size(XX,1),1));

% states of the methods
switch(method)
    
    % DIC, dictionary learning method proposed in our project
    case 'DIC'
        % dictionary projection
        display 'DICTIONARY'
        re = XX*Dic;
        Y = zeros(size(re));
        Y(re>=0) = 1;
        Y_compact = compactbit(Y);
        display 'Projection Done!'
        
   
    % Locality sensitive hashing (LSH)
     case 'LSH'
        XX = XX * randn(size(XX,2),bit);
        Y = zeros(size(XX));
        Y(XX>=0)=1;
        Y = compactbit(Y);
end

% compute Hamming metric and compute recall precision
B1 = Y(1:size(Xtraining,1),:);% the training data
B2 = Y(size(Xtraining,1)+1:end,:);% the testing data
display 'Hamming Distance'
Dhamm = hammingDist(B2, B1);% Hamming distance between them
display 'Hamming Distance Done!'
[recall, precision, rate] = recall_precision(WtrueTestTraining, Dhamm);% P-R curve

% plot the curve
figure;
plot(recall,precision,'-o');
xlabel('Recall');
ylabel('Precision');





