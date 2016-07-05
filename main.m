im1 = imread('IMG_1492.JPG');
im2 = imread('IMG_1493.JPG');

%LabelPoints from 2 images, press 'enter' when the labing is over 
[xall1,yall1,xall2,yall2] = getcoords(im1,im2);
matchedPoints1 = [xall1 yall1];
matchedPoints2 = [xall2 yall2];

%LabelPoints = [matchedPoints2 matchedPoints1 ];

showMatchedFeatures(im1,im2,matchedPoints1,matchedPoints2,'montage','PlotOptions',{'ro','go','y--'});

%calculate fundamental matrix
fRANSAC = estimateFundamentalMatrix(matchedPoints1,matchedPoints2,'Method','RANSAC','NumTrials',2000,'DistanceThreshold',1e-4)


%LabelPoints = [matchedPoints2 matchedPoints1 ];
%[H12,H21,F12] = rectify(LabelPoints, fRANSAC);

%im3 = imread('desk1_rect.png');
%im4 = imread('desk2_rect.png');
%subplot(121)
%image(im3); 
%subplot(122)
%image(im4); 


%reproject images to parallel views
[H12, H21] = PreWarp1(fRANSAC);

I = double(im1)/255;
I1 = double(im2)/255;

tform1 = maketform('projective',H12');
tform2 = maketform('projective',H21');


PW1 = imtransform(I, tform1);%, 'size',size(I));
PW2 = imtransform(I1, tform2);%, 'size',size(I1));

%show images
figure
subplot(121)
image(PW1); 
subplot(122)
image(PW2); 


%

[x1 y1 z1] = size(PW1);
[x2 y2 z2] = size(PW2);

use_x = max(x1,x2);
use_y = max(y1,y2);

PW11 = double(zeros([use_x, use_y, size(PW1,3)]));
PW22 = double(zeros([use_x, use_y, size(PW1,3)]));

PW22(1:x2,1:y2,:) = PW2;
PW11(1:x1,1:y1,:) = PW1;

PW1 = PW11;
PW2 = PW22;




%  Select 4 control points in image 1
figure
imshow(I)
X1 = ginput(4);

% Select corresponding 4 control points in image 2
imshow(I1)
X2 = ginput(4);

% Select corresponding 4 control points in prewarped image 1
imshow(PW1);
UPW1 = ginput(4);

% Select corresponding 4 control points in prewarped image 2
imshow(PW2);
UPW2 = ginput(4);



% Feature Morph the resulting images
imwrite(PW1, 'pw1.jpg');
imwrite(PW2, 'pw2.jpg');


%10 view morph interpolations between the two images
ft = [];
for i=0:10
    c = 0.1*i;
 
   
    [Jm, ft] = FeatureMorph('pw1.jpg', 'pw2.jpg', c, 20, ft);
   
    X = (1 - c)*X1 + c*X2;
    U = (1 - c)*UPW1 + c*UPW2;
    
    tform = maketform('projective',U,X);
    Ipost = imtransform(Jm, tform);%, 'size',size(Jm));
    file_name = sprintf('image_%d.jpg', i);
    imwrite(Ipost, file_name, 'jpg');
    

end

