function A = vgg_plane_from_2P_H(P,P2,H)

Q = [P2*vgg_contreps(P(2,:)'*P(3,:) - P(3,:)'*P(2,:))
     P2*vgg_contreps(P(3,:)'*P(1,:) - P(1,:)'*P(3,:))
     P2*vgg_contreps(P(1,:)'*P(2,:) - P(2,:)'*P(1,:))];
A = (Q\H(:))';

return


P = randn(3,4);
P2 = randn(3,4);
A = randn(1,4);
H = P2*vgg_H_from_P_plane(A,P);
vgg_plane_from_2P_H(P,P2,H) ./ A
