% http://www.makegames.com/3drotation/
%
function R=RotationPhi(phi)

R = [ cos(phi)  -sin(phi)   0; ...
      sin(phi)  cos(phi)    0; ...
      0         0           1 ];