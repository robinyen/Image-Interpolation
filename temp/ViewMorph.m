function [pre1, pre2, Fund] = ViewMorph(im1, im2, n)
%
% Inputs:
%   im0 -- Filename for image 1
%   im2 -- Filename for image 2
%   n -- number images to make
% Outputs:
%   pre1 -- Prewarp of image 1
%   pre2 -- Prewarp of image 2
%   Fund -- Fundamental Matrix
%
% Implements View Morphing Algorithm


% Calculate Fundamental Matrix
[x1, x2] = make_polygon_model(im1, im2);
Fund =  fundamental(x1, x2);

I = double(imread(im1))/255;
I1 = double(imread(im2))/255;



% Calculate H1, H2
[H1, H2] = PreWarp1(Fund);

% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% 
% % Calculate Prewarped Images
% 
tform1 = maketform('projective',H1');
tform2 = maketform('projective',H2');
% % 

PW1 = imtransform(I, tform1);%, 'size',size(I));
% % 

PW2 = imtransform(I1, tform2);%, 'size',size(I1));
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
%prewarp images should be of same dimensions here

%saved working1.mat
% % 
% % Select 4 control points in image 1
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


%saved working.mat here
% Feature Morph the resulting images
imwrite(PW1, 'pw1.jpg');
imwrite(PW2, 'pw2.jpg');
%saved working2.mat

%does 10 view morph interpolations between the two images. if you want to
%just see half way, just run the loopfor i = 5.
ft = [];
for i=0:50
    c = 0.1*i;
    HS = H1';
   
    [Jm, ft] = FeatureMorph('pw1.jpg', 'pw2.jpg', c, 10, ft);
   
    X = (1 - c)*X1 + c*X2;
    U = (1 - c)*UPW1 + c*UPW2;
    
    tform = maketform('projective',U,X);
    Ipost = imtransform(Jm, tform);%, 'size',size(Jm));
    file_name = sprintf('anim_%d.tif', i);
    imwrite(Ipost, file_name, 'tiff');
    
    %figure
    %imshow(Ipost) 
end


% [Jm, ft] = FeatureMorph('pw1.jpg', 'pw2.jpg', c, 10, ft);
% 
% 
% for i = 0:50
%     c = (1.0/50.0)*i;
%    
%     [Jm, ft] = FeatureMorph('pw1.jpg', 'pw2.jpg', c, 5, ft);
%    
%     X = (1 - c)*X1 + c*X2;
%     U = (1 - c)*UPW1 + c*UPW2;
%     
%     tform = maketform('projective',U,X);
%     Ipost = imtransform(Jm, tform);%, 'size',size(Jm));
%     file_name = sprintf('anim_%d.png', i);
%     imwrite(Ipost, file_name, 'png');
% end
