function featLines = get_feature_lines(im1, im2, N, feats)
%
% Input:
%   i0 -- Filename for Image 0
%   i1 -- Filename for Image 1
%   N  -- Number of lines to select
%   feats -- Features already selected (optional)
% Output:
%   featLines -- Matrix for selected feature lines

figure(1); clf; imshow(im1); hold on; zoom off; ax1 = axis;
figure(2); clf; imshow(im2); hold on; zoom off; ax2 = axis;
figure(1);
hold on
color = [0 1 1];
if nargin == 3
    featLines = [];
    start = 1;

elseif nargin == 4
    start = size(feats,1);
    featLines = feats;
    for i=1:start
        figure(1);
        p1 = featLines(i,1:2,1);
        p2 = featLines(i,1:2,2);
        format_figure(p1(2),p1(1),color,i);
        format_figure(p2(2),p2(1),color,i);
        line([p1(2) p2(2)],[p1(1) p2(1)], 'Color', color);

        figure(2);
        p1 = featLines(i,1:2,3);
        p2 = featLines(i,1:2,4);
        format_figure(p1(2),p1(1),color,i);
        format_figure(p2(2),p2(1),color,i);
        line([p1(2) p2(2)],[p1(1) p2(1)], 'Color', color);
        
    end
    start = start+1;
end;

figure(1);

for i=start:N
        
        figure(1);
        title('Choose a line in this view');
        [x,y,button] = ginput(1);
        format_figure(x,y,color,i);
        [x1,y1,button] = ginput(1);
        format_figure(x1,y1,color,i);
        line([x x1],[y y1], 'Color', color);
        
        featLines(i,1:2,1) = [y x];
        featLines(i,1:2,2) = [y1 x1];
        
        
        figure(2); title('Choose a line in this view');

        [x,y,button] = ginput(1);
        format_figure(x,y,color,i);
        [x1,y1,button] = ginput(1);
        format_figure(x1,y1,color,i);
        line([x x1],[y y1], 'Color', color);
        featLines(i,1:2,3) = [y x];
        featLines(i,1:2,4) = [y1 x1];

end
hold off

%
%I = getframe(gca);
%imwrite(I.cdata, 'test.jpg');
%------------------------------------------------------------------------------------------
function format_figure(x,y,color,c);
h = plot(x, y,'ro');
set(h,'MarkerSize', 5);
set(h,'LineWidth', 2);   
set(h,'Color', color);
H = text(x+4, y+4,int2str(c));
set(H,'Color',color)
set(H,'FontSize',10)