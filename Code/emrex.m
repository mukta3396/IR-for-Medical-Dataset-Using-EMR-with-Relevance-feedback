%Ranking on the USPS and Image data set 
clear;
	

%% Initialization
load('traindata.mat');
load('ground_cat.mat');
load('img1.mat');
load('img2.mat');
load('querycnt.mat');
load('relfeed.mat');
threshold=5; % max users to include relevance feedback 
fea=fea(:,1:5);
imgitr=cat(2,img1,img2);
train_gnd = train_gnd ;%category
digit = 51; %Pick a query
idx = find(train_gnd(:,2) == digit); %finding the query
queryIdx = idx(2);%index of the query
querycnt(queryIdx)=querycnt(queryIdx)+1; % increment the number of times the image is queried
nSmp = size(fea,1);%number of ROWS
y0 = zeros(nSmp,1);%0 matrix nSmp row size and col 1

%% EMR with stored relevance feedback
if (querycnt(queryIdx)>=threshold)
   y0=y0+relfeed(queryIdx,:);
end

%% EMR ranking
y0(queryIdx) = 10;%query index is 1
img=imgitr{1,queryIdx};
%Ranking with Efficient Manifold ranking
tic;
opts = [];
opts.p = 500;
y = EMR(fea,y0,opts);
toc;
[dump,idx]=sort(-y); % sort image indices in order of ranking
index=idx(2:21); % select top images

%% Display top 20 results
k=1;
Y = ones(640,640)*-1;
Y(1:128,4*128+1:5*128) = imresize(img,[128,128]);
for i=1:4
  for j=0:4
    Y(i*128+1:(i+1)*128,j*128+1:(j+1)*128) = imresize(imgitr{1,index(k)},[128,128]);
    k=k+1;
  end
end
%imagesc(Y);colormap(gray);

%% Evaluation metrics
for i=1:20
    pred_op(i)=train_gnd(index(i),2);
    if (pred_op(i)==9)
        pred_op(i)=51;
    end
end
precision=length(find(pred_op==digit))/20*100;
fprintf(' precicion %.4f s\n', precision);


%% Ranking with Manifold Ranking
tic;
rand('twister',5489);
Woptions.k = 5;
W = constructW(fea, Woptions);
D_mhalf = full(sum(W,2).^-.5);
D_mhalf = spdiags(D_mhalf,0,nSmp,nSmp);
S = D_mhalf*W*D_mhalf;
alpha = 0.99;
S = speye(nSmp)-alpha*S; 
y = S\y0;
toc;
%Elapsed time
[dump,idx]=sort(-y);
index=idx(2:21); % select top images

%% Display top 20 results
k=1;
Y = ones(640,640)*-1;
Y(1:128,4*128+1:5*128) = imresize(img,[128,128]);
for i=1:4
  for j=0:4
    Y(i*128+1:(i+1)*128,j*128+1:(j+1)*128) = imresize(imgitr{1,index(k)},[128,128]);
    k=k+1;
  end
end
%imagesc(Y);colormap(gray);

%% Evaluation metric
for i=1:20
    pred_op(i)=train_gnd(index(i),2);
    if (pred_op(i)==9)
        pred_op(i)=51;
    end
end
precision=length(find(pred_op==digit))/20*100;
fprintf(' precicion %.4f s\n', precision);

