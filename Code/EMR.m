function [score, model] = EMR(data,y0,opts)
% Set and parse parameters
if (~exist('opts','var'))
   opts = [];
end

p = 1000;
if isfield(opts,'p')
    p = opts.p;
end

r = 5;
if isfield(opts,'r')
   r = opts.r;
end

a = 0.99;
if isfield(opts,'a')
   a = opts.a;
end

mode = 'kmeans';
if isfield(opts,'mode')
    mode = opts.mode;
end

nSmp =size(data,1);

% Landmark selection
if strcmp(mode,'kmeans')
    kmMaxIter = 5;
    if isfield(opts,'kmMaxIter')
        kmMaxIter = opts.kmMaxIter;
    end
    kmNumRep = 1;
    if isfield(opts,'kmNumRep')
        kmNumRep = opts.kmNumRep;
    end
    [dump,landmarks]=litekmeans(data,p,'MaxIter',kmMaxIter,'Replicates',kmNumRep);
    clear kmMaxIter kmNumRep
end

model.landmarks = landmarks;
model.a = a;
model.r = r;

% Z construction
D = EuDist2(data,landmarks);
dump = zeros(nSmp,r);
idx = dump;
for i = 1:r
    [dump(:,i),idx(:,i)] = min(D,[],2);
    temp = (idx(:,i)-1)*nSmp+[1:nSmp]';
    D(temp) = 1e100;
end
dump = bsxfun(@rdivide,dump,dump(:,r));
dump = 0.75 * (1 - dump.^2);
Gsdx = dump;
Gidx = repmat([1:nSmp]',1,r);
Gjdx = idx;
Z=sparse(Gidx(:),Gjdx(:),Gsdx(:),nSmp,p);

model.Z = Z';

% Efficient Ranking
feaSum = full(sum(Z,1));
D = Z*feaSum';
D = max(D, 1e-12);
D = D.^(-.5);
H = spdiags(D,0,nSmp,nSmp)*Z;

C = speye(p);
A = H'*H-(1/a)*C;

tmp = H'*y0;
tmp = A\tmp;
score = y0 - H*tmp;