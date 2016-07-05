% getcoords:
% the user 
% clicks on corresponding points in two images 
% and 
% this function 
% returns the coordinates of the corresponding points.

% im1, im2 - names of the two images
% xall1, yall1 - (x,y) coordinates of points in the first image
% xall2, yall2 - corresponding (x,y) coordinates of points in the second image

function [xall1,yall1,xall2,yall2] = getcoords(im1,im2);

[ymax1,xmax1,depth1] = size(im1);
[ymax2,ymax2,depth2] = size(im2);

sub1 = subplot(1, 2, 1);
imshow(im1);
hold on;

sub2 = subplot(1, 2, 2);
imshow(im2);
hold on;

handle = helpdlg('Choose corresponding points in two images and press ENTER once you are done');
uiwait(handle);

xall1 =[];
yall1 =[];

xall2 =[];
yall2 =[];

while 1,
    [xnew1, ynew1, button1]=ginput(1);
    [xnew1, ynew1]
    xall1 = [xall1; xnew1]
    yall1 = [yall1; ynew1]
    
    if (isempty(button1)),
        break;
    end;
    
    plot(sub1, xnew1(1), ynew1(1), 'b*');
     
    [xnew2, ynew2, button2]=ginput(1);
    [xnew2, ynew2]
    xall2 = [xall2; xnew2]
    yall2 = [yall2; ynew2]
    
    if (isempty(button2)),
        break;
    end;
   
    plot(sub2, xnew2(1), ynew2(1), 'b*');
end;

sub1;
hold off;
sub2;
hold off;

end