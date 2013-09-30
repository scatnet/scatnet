% ROTATION_MATRIX_2D computes a 2-by-2 rotation matrix for a given angle
%
% Usage
%    rotmat = ROTATION_MATRIX_2D(theta)	
% 
% Input
%    theta (numeric): the angle of the rotation
%
% Ouput
%    rotmat : 2-by-2 rotation matrix corresponding to the axis convention
%    of matlab for image coordinates

function rotmat = rotation_matrix_2d(theta)	
	rotmat=[cos(theta) sin(theta) ; - sin(theta) cos(theta) ];
end
