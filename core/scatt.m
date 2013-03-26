function [S, U] = scatt(x, wavemod)
% function [S, U] = scatt(x, wavemod)
%
% this function implements a generic scattering
% where propagators may be different from one layer to the next
%
% intputs :
% - x : <?x? double> input signal
% - wavemod : <1xnb_layer cell> a cell of wavelet modulus operators
%   - wavemod{m} : <function_handle> the m-th wavelet-modulus operator to 
%       apply successively to the input signal
%
% outputs :
% - S : <1xnb_layer+1 cell> the output scattering nodes
%   - S{m+1} : <1x1 struct> the m-th output layer of the scattering. It 
%     corresponds to m applications of wavelet modulus operators followed 
%     by a final application of an averaging operator. It contains fields :
%     - sig{p}          : the signal of the p-th path of the m-th layer
%     - meta.k(p,:)     : the sequence of k (index of scale) 
%                         corresponding to this path
%     - meta.theta(p,:) : the sequence of theta (orientation) 
%                         corresponding to this path (for 2d scattering)
%     - meta.res(p,:)   : the sequence of log2 of resolution 
%                         corresponding to this path
%        NOTE : meta may contains different fields depending on the nature 
%        of the scattering that is being computed (1d, 2d, joint, ...)
% - U : <1xnb_layer cell+1> the inner scattering nodes. 
%   - U{m+1} : <1x1 struct> the m-th inner layer of the scattering. It 
%     corresponds to m applications of wavelet modulus operators without 
%     averaging. It has the same structure as S.
%
% NOTE : 
% wavemod can be obtained with a variety of wavemod factory such as :
%   wavemod_factory_1d.m		
%   wavemod_factory_2d.m			
%
% WARNING :
% this 'core' scattering function does not contain any 
% pre/post-processing and reformating.
% consider the use of wrappers in /scattlab/wrappers/ like
%   scatt_2d_wrapper
%   scatt_3d_wrapper
%   scatt_3d_ms_wrapper

nb_layer = numel(wavemod) - 1;

U{1} = x;

for m = 1 : nb_layer
  [U_next, S_next] = wavemod{m}(U{m});
  U{m} = U_next;
  S{m} = S_next;
end

S{nb_layer+1} = wavemod{nb_layer}(U{nb_layer+1});

end