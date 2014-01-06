function output = query(numQuery, numRetrieve),
querySet = struct();

% parameters for query
if ~exist('numQuery'),
    numQuery = 1;
end
if ~exist('numRetrieve'),
    numRetrieve = 10;
end

% load data from indexed database, dictionary
clear database;
db = load('database.mat')
database = db.database;
clear db;
load dictionary_L1_b512_30600sampling_20140103T010408.mat
Dic = B;

% parameters for sampling patches
windowSize = 14;% the window size of a patch
num_totalSamples = 153;% the number for sampling total patches
num_thresholdSamples = 5;% the number of samples to decide a threshold
rand_values = struct();

% query and read the data from "queries"
path = 'queries/*.*g';
imgs = dir(path);
for i = 1 : numQuery, 
    img_path = sprintf('queries/%s',imgs(i).name);
    img = imread(img_path);
    img = filter_whiten(img);

    % get image patches for the query
    [X_patches rand_values]= getdata_imagepatch(img, windowSize, num_totalSamples);
    X = X_patches';

    % Dictioanry projection
    display 'Dictionary Projection:'
    re = X*Dic; % 153x512

    % Binary code
    Y = zeros(size(re));
    Y(re>=0) = 1;

    % Compact bits
    Y = reshape(Y, 1, size(Y,1)*size(Y,2));
    Y = compactbit(Y);
    
    % storing data to querySet
    querySet(i).name = imgs(i).name;
    querySet(i).category = getCategory( imgs(i).name );
    querySet(i).code = Y;
    
    % Hamming distance
    display 'Hamming Distance:'
    querySet(i).diffenence = zeros( length(database),1);
    for j = 1 : length(database),
       B1 = querySet(i).code;
       B2 = database(j).code;
       querySet(i).difference(j,1) = hammingDist(B1, B2);% calculate hamming distance
       display( sprintf('Checking Database: [%d/%d]', j,length(database)) );
    end
    [querySet(i).sortedValues querySet(i).sortedIndex] = sort(querySet(i).difference);
    
    % show query image
    im = imread(img_path);
    figure; imshow(im);title(sprintf('Query Image %d %s', i, querySet(i).name));
    
    % show retrieved images
    topNumber = 10;
    for j = 1 : topNumber,
        index = querySet(i).sortedIndex(j);
        db = database(index);
        path = sprintf('dictionary_dataset/%s', db.name);
        im = imread(path);
        figure; imshow(im);title(sprintf('Retrieved Image %d %s', j, db.name));
        
    end
    
    display( sprintf('Query Done: [%d/%d]', i,length(imgs)) );
end

end