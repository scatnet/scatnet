function [S, U] = gscatt(in, propagators)
% function [S, U] = gscatt(in, propagators)
%
% this function implements a generic scattering
% where propagators may be different from one layer to the next
%
% intputs :
% - in : <HxW double> input image
% - propagators : <1x1 struct> contains the following fields :
%   - U{m} : <function_handle> the m-th wavelet-modulus operators to apply 
%       successively to the input image 
%   - A{m+1} : <function_handle> the m-th averaging operator to apply after
%     to apply after U{m}
%
% outputs :
% - S : <1xM cell> the output scattering nodes
%   - S{m+1} : <1x1 struct> the m-th layer of the scattering. It corresponds to m
%     applications of wavelet modulus operators followed by a final
%     application of an averaging operator. It contains fields :
%     - sig{p}          : the image of the p-th path of the m-th layer
%     - meta.j(p,:)     : the sequence of j (log-a of scale) corresponding to this path
%     - meta.theta(p,:) : the sequence of theta (orientation) corresponding to this path
%     - meta.res(p,:)   : the sequence of log2 of resolution corresponding to this path
%        NOTE : meta may contains different fields depending on the nature of
%        the scattering that is being computed (1d, 2d, joint, ...)
% - U : <1xM cell> the inner scattering nodes. 
%   - U{m+1} : <1x1 struct> the m-th inner layer of the scattering. It corresponds to m
%     applications of wavelet modulus operators without averaging. It has
%     the same structure as S
%
% NOTE : 
% propagators can be obtained with a variety of propagators_builder such as :
%   propagators_builder_2d.m			
%   propagators_builder_2d_plus_scale.m		
%   propagators_builder_3d.m			
%   propagators_builder_3d_plus_scale.m
%
% WARNING :
% this 'core' scattering function does not contain any 
% pre/post-processing and reformating.
% consider the use of wrappers in /scattlab2d/wrappers/ like
%   scatt_2d_wrapper
%   scatt_3d_wrapper
%   scatt_3d_ms_wrapper.m
%
% EXAMPLE :
% to compute the 2d scattering use the following two line:
%   propagators = propagators_builder_2d(size(in),options);
%   out = gscatt(in,propagators);

U{1} = in;

for m = 1 : numel(propagators.U)
  % inner nodes : wavelet modulus operators
  U{m+1} = propagators.U{m}(U{m});
end

for m = 0 : numel(propagators.A)-1
  % outside nodes : inner nodes + averaging
  S{m+1}  = propagators.A{m+1}(U{m+1});
end



end