% function Rotmat = rotation_matrix_2d(theta)
%
% input :
% - theta : <1x1 double> angle in radian
%
% output :
% - Rotmat : <2x2 double> rotation matrix corresponding to matlab's
%     convention of image coordinates

function Rotmat = rotation_matrix_2d(theta)	
	Rotmat=[cos(theta) sin(theta) ; - sin(theta) cos(theta) ];
end
