% T_TO_J: Calculates the maximal wavelet scale J from T
%
% Usage
%    J = T_to_J(T, filt_opt)
%
% Input
%    T: A time interval T.
%    filt_opt: A structure containing the parameters of a filter bank.
%
% Output
%    J: The maximal wavelet scale J such that, for a filter bank created with
%       the parameters in options and this J, the largest wavelet is of band-
%       width approximately T.
%
% Description
%    J is calculated using the formula T = 4B/phi_bw_multiplier*2^((J-1)/Q), 
%    where B, phi_bw_multiplier and Q are taken from the filt_opt
%    structure.
%    Note that this function still works if T, filt_opt.Q and/or filt_opt.B
%    are vectors. In this case, it provides a vector of the same length.
%    This generalisation is useful when computing J for several layers in a
%    scattering network, each layer having a different quality factor.
%
% See also
%    DEFAULT_FILTER_OPTIONS, MORLET_FILTER_BANK_1D

function J = T_to_J(T, filt_opt)

   if  nargin ==2 && ~isstruct(filt_opt)
       error('You must provide a filter options structure as second argument!');
   end

   
	filt_opt = fill_struct(filt_opt,'Q',1);
	filt_opt = fill_struct(filt_opt,'B',filt_opt.Q);
	filt_opt = fill_struct(filt_opt,'phi_bw_multiplier', ...
		1+(filt_opt.Q==1));

	J = 1 + round(log2(T./(4*filt_opt.B./filt_opt.phi_bw_multiplier)) ...
		.*filt_opt.Q);
end