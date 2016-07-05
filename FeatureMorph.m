% 
% Feature-Based Image Metamorphosis
% http://www.hammerhead.com/thad/thad.html
function [morphImage, featLines] = FeatureMorph(i0,i1,diss, N, feats)
% Inputs:
%   i0 -- filename for image0
%   i1 -- filename for image1
%   diss -- cross-dissolve factor (between 0 and 1)
%   N -- number of feature lines to select
%   feats -- feature lines (optional)
% Outputs:
%   morphImage -- the morphed image
%   featLines -- the feature lines selected

if nargin == 5
    if N == size(feats,1)
        imageLine = feats;
    else
        imageLine = get_feature_lines(i0,i1,N,feats);
    end
else
    imageLine = get_feature_lines(i0,i1,N);
end

image0=imread(i0);
image1=imread(i1);
image0=double(image0)/255;
image1=double(image1)/255;

featLines = imageLine;

% imageLine 
imageLine(:,:,5:6) = (1-diss)*imageLine(:,:,1:2) + diss*imageLine(:,:,3:4);
imageLine = round(imageLine);


%P' = imageLine(:,:,1);
%Q' = imageLine(:,:,2);
%P = imageLine(:,:,5);
%Q = imageLine(:,:,6);

% Q - P
diffPQdest = imageLine(:,:,6) - imageLine(:,:,5);
% ||Q - P||
normPQdest = sqrt(sum((diffPQdest.^2)'))';
% ||Q - P||^2
normPQdestSq = normPQdest .* normPQdest;
% Perpendicular(Q - P)
perpPQdest = [diffPQdest(:,2) -1*diffPQdest(:,1)];
% Q' - P'
diffPQsource = imageLine(:,:,2) - imageLine(:,:,1);
% ||Q' - P'||
normPQsource = sqrt(sum((diffPQsource.^2)'))';
% Perpendicular(Q' - P')
perpPQsource = [diffPQsource(:,2) -1*diffPQsource(:,1)];

% For each pixel X in the destination
%     DSUM = (0,0)
%     weightsum = 0
%     For each line Pi Qi
%         calculate u,v based on Pi Qi
%         calculate Xi' based on u,v and Pi'Qi'
%         calculate displacement Di = Xi' - X for this line
%         dist = shortest distance from X to Pi Qi
%         weight = (length^p / (a + dist))^b
%         DSUM += Di * weight
%         weightsum += weight
%     X' = X + DSUM / weightsum
%     destinationImage(X) = sourceImage(X')

% X with i,j values
% DSUM with i,j values
%
tic
DSUM = zeros(size(image0,1),size(image0,2),2);
D = zeros(size(DSUM));
Xsource = zeros(size(DSUM));
Xdest = zeros(size(DSUM));
XP = zeros(size(DSUM));
weightsum = zeros(size(image0,1),size(image0,2));

u = zeros(size(image0,1),size(image0,2));
v = zeros(size(image0,1),size(image0,2));

X1 = ones(1,size(image0,2));
X2 = [1:1:size(image0,1)]';
Xsource(:,:,1) = X2 * X1;
Y1 = ones(size(image0,1),1);
Y2 = [1:1:size(image0,2)];
Xsource(:,:,2) = Y1 * Y2;

for k=1:N
    
    XP(:,:,1) = Xsource(:,:,1) - imageLine(k,1,5);
    XP(:,:,2) = Xsource(:,:,2) - imageLine(k,2,5);
    
    u = (XP(:,:,1) .* diffPQdest(k,1) + XP(:,:,2) .* diffPQdest(k,2))/(normPQdestSq(k,1));    
    v = (XP(:,:,1) .* perpPQdest(k,1) + XP(:,:,2) .* perpPQdest(k,2))/(normPQdest(k,1));
    
    Xdest(:,:,1) = imageLine(k,1,1) + u .* diffPQsource(k,1) + (v .* perpPQsource(k,1))/(normPQsource(k,1));
    Xdest(:,:,2) = imageLine(k,2,1) + u .* diffPQsource(k,2) + (v .* perpPQsource(k,2))/(normPQsource(k,1));
    
    D = Xdest - Xsource;
    
    Xx = Xdest(:,:,1);
    Xy = Xdest(:,:,2);
    
    dist = abs(v);
    I = find(u > 1);
    dist(I) = sqrt((Xx(I)-imageLine(k,1,6)).^2 + (Xy(I)-imageLine(k,2,6)).^2);
    I = find(u < 0);
    dist(I) = sqrt((Xx(I)-imageLine(k,1,5)).^2 + (Xy(I)-imageLine(k,2,5)).^2);
    
    weight = ((normPQdest(k).^.4)./(2 + dist)).^2;
    DSUM(:,:,1) = DSUM(:,:,1) + D(:,:,1) .* weight;
    DSUM(:,:,2) = DSUM(:,:,2) + D(:,:,2) .* weight;
    
    weightsum = weightsum + weight;
    
end 
toc

Xxs = zeros(size(DSUM));
Xxs(:,:,1) = round(Xsource(:,:,1) + DSUM(:,:,1) ./ weightsum);
Xxs(:,:,2) = round(Xsource(:,:,2) + DSUM(:,:,2) ./ weightsum);

%premorph0 = image0;
x0 = size(image0,1);
y0 = size(image0,2);

premorph0 = zeros(size(image0));

Xxs1 = Xxs(:,:,1);
Xxs1 = Xxs1(:);
Xxs2 = Xxs(:,:,2);
Xxs2 = Xxs2(:);

yes = find(Xxs1 > 0 & Xxs1 <= x0 & Xxs2 > 0 & Xxs2 <= y0);

image0a = image0(:);
premorph0a = zeros(size(image0a));
premorph0a(yes) = image0a(Xxs1(yes) + (Xxs2(yes)-1)*x0);
premorph0a(x0*y0 + yes) = image0a(x0*y0 + (Xxs1(yes) + (Xxs2(yes)-1)*x0));
premorph0a(2*x0*y0 + yes) = image0a(2*x0*y0 + (Xxs1(yes) + (Xxs2(yes)-1)*x0));

premorph0 = reshape(premorph0a, x0,y0,3);


%%%%%%%%%%%%%%%%%%%%%%%% second picture
% Q' - P'
diffPQsource = imageLine(:,:,4) - imageLine(:,:,3);
% ||Q' - P'||
normPQsource = sqrt(sum((diffPQsource.^2)'))';
% Perpendicular(Q' - P')
perpPQsource = [diffPQsource(:,2) -1*diffPQsource(:,1)];
tic
DSUM = zeros(size(image0,1),size(image0,2),2);
D = zeros(size(DSUM));
Xdest = zeros(size(DSUM));
XP = zeros(size(DSUM));
weightsum = zeros(size(image0,1),size(image0,2));

u = zeros(size(image0,1),size(image0,2));
v = zeros(size(image0,1),size(image0,2));

for k=1:N
    
    XP(:,:,1) = Xsource(:,:,1) - imageLine(k,1,5);
    XP(:,:,2) = Xsource(:,:,2) - imageLine(k,2,5);
    
    u = (XP(:,:,1) .* diffPQdest(k,1) + XP(:,:,2) .* diffPQdest(k,2))/(normPQdestSq(k,1));    
    v = (XP(:,:,1) .* perpPQdest(k,1) + XP(:,:,2) .* perpPQdest(k,2))/(normPQdest(k,1));
    
    Xdest(:,:,1) = imageLine(k,1,3) + u .* diffPQsource(k,1) + (v .* perpPQsource(k,1))/(normPQsource(k,1));
    Xdest(:,:,2) = imageLine(k,2,3) + u .* diffPQsource(k,2) + (v .* perpPQsource(k,2))/(normPQsource(k,1));
    
    D = Xdest - Xsource;
    
    Xx = Xdest(:,:,1);
    Xy = Xdest(:,:,2);
    
    dist = abs(v);
    I = find(u > 1);
    dist(I) = sqrt((Xx(I)-imageLine(k,1,6)).^2 + (Xy(I)-imageLine(k,2,6)).^2);
    I = find(u < 0);
    dist(I) = sqrt((Xx(I)-imageLine(k,1,5)).^2 + (Xy(I)-imageLine(k,2,5)).^2);
    
    weight = ((normPQdest(k).^.4)./(2 + dist)).^2;
    %weight = (normPQdest(k)^.4)./(.1 + dist);
    DSUM(:,:,1) = DSUM(:,:,1) + D(:,:,1) .* weight;
    DSUM(:,:,2) = DSUM(:,:,2) + D(:,:,2) .* weight;
    
    weightsum = weightsum + weight;
    
end 
toc

Xxs = zeros(size(DSUM));
Xxs(:,:,1) = round(Xsource(:,:,1) + DSUM(:,:,1) ./ weightsum);
Xxs(:,:,2) = round(Xsource(:,:,2) + DSUM(:,:,2) ./ weightsum);
size(image1)
premorph1 = zeros(size(image1));
%premorph1 = image1;
x0 = size(image1,1)
y0 = size(image1,2)

Xxs1 = Xxs(:,:,1);
Xxs1 = Xxs1(:);
Xxs2 = Xxs(:,:,2);
Xxs2 = Xxs2(:);

yes = find(Xxs1 > 0 & Xxs1 <= x0 & Xxs2 > 0 & Xxs2 <= y0);

image1a = image1(:);

premorph1a = zeros(size(image0a));
premorph1a(yes) = image1a(Xxs1(yes) + (Xxs2(yes)-1)*x0);
premorph1a(x0*y0 + yes) = image1a(x0*y0 + (Xxs1(yes) + (Xxs2(yes)-1)*x0));
premorph1a(2*x0*y0 + yes) = image1a(2*x0*y0 + (Xxs1(yes) + (Xxs2(yes)-1)*x0));

premorph1 = reshape(premorph1a, x0,y0,3);
%figure;
%imshow(premorph1);

morphImage = (1-diss)*premorph0 + (diss)*premorph1;
