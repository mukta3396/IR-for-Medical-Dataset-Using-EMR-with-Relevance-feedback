%% Relevance feedback
queryIdx=idx(1);
yf=zeros(nSmp,1);
for i=1:20
yf(idx(i+1))=feedback(i);
end
yf=yf+y0;
relfeed(queryIdx,:)=(relfeed(queryIdx,:)+yf')/querycnt(queryIdx); 

%% EMR with user relevance feedback 
tic;
opts = [];
opts.p = 500;
y = EMR(fea,yf,opts);
toc;
[dump,idx]=sort(-y);
index=idx(2:50);

%% Display top 20 results after user feedback
k=1;
Y = ones(640,640)*-1;
Y(1:128,4*128+1:5*128) = imresize(img,[128,128]);
for i=1:4
  for j=0:4
    Y(i*128+1:(i+1)*128,j*128+1:(j+1)*128) = imresize(imgitr{1,index(k)},[128,128]);
    k=k+1;
  end
end
imagesc(Y);colormap(gray);

