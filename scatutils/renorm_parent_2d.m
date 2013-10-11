% RENORM_PARENT_2D Renormalization for 2d scattering
% 
% Usage
%   Sx_rn = renorm_parent_2d(Sx)
%
% Input
%   Sx (cell): output of 2d scattering
%
% Output
%   Sx_rn (cell): the renormalized 2d scattering 
%
% Description
%   This function will renormalize every 2nd order node by its parent
%   (hence his name renorm_PARENT_2d)
%
% See also
%   SCAT, REMORM_PARENT_3D

function Sx_rn = renorm_parent_2d(Sx)
    
    Sx_rn = Sx;
    
    % a function handle to find the parent node
    parent = @(p)(find(Sx{2}.meta.j(1,:) == Sx{3}.meta.j(1,p) &...
        Sx{2}.meta.theta(1,:) == Sx{3}.meta.theta(1,p) & ...
        Sx{2}.meta.q(1,:) == Sx{3}.meta.q(1,p)));
    
    % for each signal in order 2, divide by its ancestor
    for p = 1:numel(Sx{3}.signal)
        Sx_rn{3}.signal{p} = Sx_rn{3}.signal{p}./Sx{2}.signal{parent(p)};
    end
    
end
