% RENORM_PARENT_3D Renormalization for roto-translation scattering
%
% Usage
%   Sx_rn = renorm_parent_3d(Sx)
%
% Input
%   Sx (cell): output of roto-translation scattering
%
% Output
%   Sx_rn (cell): the renormalized roto-translation scattering
%
% Description
%   This function will renormalize every 2nd order node by its parent
%   (hence his name renorm_PARENT_3d)
%
% See also
%   SCAT, REMORM_PARENT_2D


function Sx_rn = renorm_parent_3d(Sx)
    Sx_rn = Sx;
    % a function handle to find the parent node
    parent = @(p)(find(Sx{2}.meta.j(1,:) == Sx{3}.meta.j(1,p) & ...
        Sx{2}.meta.q(1,:) == Sx{3}.meta.q(1,p) ));
    % a function handle to find the parent node
    for p = 1:numel(Sx{3}.signal)
        Sx_rn{3}.signal{p} = Sx_rn{3}.signal{p}./Sx{2}.signal{parent(p)};
    end
    
end
