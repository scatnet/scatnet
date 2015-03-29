% SCAT_FREQ Computes scattering transform along first frequency
%
% Usage
%    [S, U] = scat_freq(X, Wop)
%
% Input
%    X (cell): A cell array of scattering layers with, such as the output S
%       of the SCAT function.
%
% Output
%    S, U (cell): The scattering and wavelet modulus coefficients, respective-
%       ly, of the input representation X, transformed along first frequency
%       lambda1.
%
% Description
%    For each order of the input representation X, the coefficients are group-
%    ed according to higher-order frequencies lambda2, lambda3, with each
%    group ordered along lambda1, obtained by calling CONCATENATE_FREQ. Then 
%    the scattering transform defined by Wop by calling SCAT is applied along
%    this lambda1 axis. The results are then retransformed, separating the
%    different first frequencies lambda1 into different coefficients, as in 
%    the original representation.
%
%    The meta fields of the frequential scattering transform are stored in the
%    output with the prefix 'fr_', so 'order' becomes 'fr_order', 'j' becomes
%    'fr_j', and so on.
%
% See also 
%    SCAT, WAVELET_FACTORY_1D, CONCATENATE_FREQ

function [S, U] = scat_freq(X, Wop, zero_pad)
	if nargin < 3
		zero_pad = 0;
	end

	% Group all the coefficients into tables along lambda1 and t. For order 1,
	% this gives a single table containing all first-order coefficients, while
	% for order 2, each lambda2 corresponds to one table containing the 
	% second-order coefficients for that lambda2 and the different lambda1s,
	% and so on.
	Y = concatenate_freq(X);

	max_fr_count = length(X{2}.signal);

	S = {};
	U = {};
	
	for m = 0:length(X)-1
		r = 1;
		
		S{m+1} = {};
		U{m+1} = {};
		
		for k = 1:length(Y{m+1}.signal)
			% Here each signal is a table of dimension PxNxK, where P is the
			% number of frequencies lambda1, N is the number of time samples,
			% and K is the number of signals.
			signal = Y{m+1}.signal{k};
			
			% Get the table dimension, if K = 1, MATLAB will not include it in
			% the size.
			sz_orig = size(signal);
			sz_orig = [sz_orig ones(1,3-length(sz_orig))];
			
			% Compute the corresponding columns in the meta fields.
			ind = r:r+size(signal,1)-1;
			
			% Reshape so that each time sample and each signal index are
			% processed separately by putting them in the third dimension,
			% giving a table of size Px1xNK.
			signal = reshape(signal,[sz_orig(1) 1 prod(sz_orig(2:3))]);
			
			if m > 0
				fr_count0 = size(signal,1);
				
				if zero_pad
					signal = pad_signal(signal,max_fr_count,'zero');
				end
				
				if isfield(Y{m+1}.meta,'fr_resolution');
					frsc_opt.x_resolution = Y{m+1}.meta.fr_resolution(ind(1));
				else
					frsc_opt.x_resolution = 0;
				end
				
				% If we're not in the zeroth order, we can (and want to)
				% compute the scattering transform along lambda1, which is now
				% the first dimension of signal.
				[S_fr,U_fr] = scat(signal, Wop, frsc_opt);
				
				% Needed for the case of U. These are not initialized by scat.
				if ~isfield(U_fr{1}.meta,'bandwidth')
					U_fr{1}.meta.bandwidth = 2*pi;
				end
				if ~isfield(U_fr{1}.meta,'resolution')
					U_fr{1}.meta.resolution = 0;
				end
				
				if zero_pad
					unpad_layer = @(layer)(...
						cellfun(@(x,res)(unpad_signal(x,res,fr_count0)), ...
						layer.signal, num2cell(layer.meta.resolution), ...
						'UniformOutput',0));
					for mp = 1:length(S_fr)
						S_fr{mp}.signal = unpad_layer(S_fr{mp});
						U_fr{mp}.signal = unpad_layer(U_fr{mp});
					end
				end
			else
				% If we're in the zeroth order, just copy the signal.
				S_fr = {};
				
				S_fr{1}.signal = {signal};
				S_fr{1}.meta.bandwidth = 2*pi;
				S_fr{1}.meta.resolution = 0;
				S_fr{1}.meta.j = -1;
				
				U_fr = {};

				U_fr{1}.signal = {signal};
				U_fr{1}.meta.bandwidth = 2*pi;
				U_fr{1}.meta.resolution = 0;
				U_fr{1}.meta.j = -1;
			end
			
			if isempty(S{m+1})
				% If we have no signals so far, initialize S, the output.
				for mp = 0:length(S_fr)-1
					S{m+1}{mp+1}.signal = {};	% Scattering coefficients
					U{m+1}{mp+1}.signal = {};	% Wavelet modulus coefficients
					rp(mp+1) = 1;				% Index for S{m+1}{mp+1}
					rb(mp+1) = 1;				% Index for U{m+1}{mp+1}
				end
			end
			
			for mp = 0:length(S_fr)-1
				% For each order of the frequential scattering.
				for kp = 1:length(S_fr{mp+1}.signal)
					% For each of the frequential scattering coefficients.
					for t = 0:1
						% Do this for both S and U, same thing.
						if t == 0
							X_fr = S_fr;
							X = S;
							rc = rp;
						else
							X_fr = U_fr;
							X = U;
							rc = rb;
						end
					
						% Extract all the signals of this path. Again, note
						% that nsignal is a table of the size P'x1xNK, where
						% P' is the number of freqencies after downsamping.
						nsignal = X_fr{mp+1}.signal{kp};
					
						% Retrieve P' = j1_count and downsampling factor.
						j1_count = size(nsignal,1);
						ds = X_fr{mp+1}.meta.resolution(kp);
						if isfield(Y{m+1}.meta,'fr_resolution')
							ds = ds-Y{m+1}.meta.fr_resolution(ind(1));
						end
					
						% Which of the indices from the original range ind
						% have been kept after subsampling.
						inds = ind(1:2^ds:end);
					
						% Restore the P'xNxK dimension of the table.
						nsignal = reshape(nsignal,[j1_count sz_orig(2:3)]);
					
						for j1 = 1:j1_count
							% For each of the remaining frequencies lambda1,
							% copy the signal and its associated meta fields.
							X{m+1}{mp+1}.signal{rc(mp+1)} = ...
								reshape(nsignal(j1,:,:), ...
									[sz_orig(2) 1 sz_orig(3)]);
							X{m+1}{mp+1}.meta.bandwidth(1,rc(mp+1)) = ...
								Y{m+1}.meta.bandwidth(inds(j1));
							X{m+1}{mp+1}.meta.resolution(1,rc(mp+1)) = ...
								Y{m+1}.meta.resolution(inds(j1));
							X{m+1}{mp+1}.meta.j(:,rc(mp+1)) = ...
								Y{m+1}.meta.j(:,inds(j1));
							X{m+1}{mp+1}.meta.fr_bandwidth(1,rc(mp+1)) = ...
								X_fr{mp+1}.meta.bandwidth(kp);
							X{m+1}{mp+1}.meta.fr_resolution(1,rc(mp+1)) = ...
								X_fr{mp+1}.meta.resolution(kp);
							if isfield(Y{m+1}.meta,'fr_j')
								X{m+1}{mp+1}.meta.fr_j(:,rc(mp+1)) = ...
									[Y{m+1}.meta.fr_j(:,inds(j1)); X_fr{mp+1}.meta.j(:,kp)];
							else
								X{m+1}{mp+1}.meta.fr_j(:,rc(mp+1)) = ...
									X_fr{mp+1}.meta.j(:,kp);
							end
							rc(mp+1) = rc(mp+1)+1;
						end
						
						% Write the results into S or U, depending.
						if t == 0
							S_fr = X_fr;
							S = X;
							rp = rc;
						else
							U_fr = X_fr;
							U = X;
							rb = rc;
						end
					end
				end
			end
			
			r = r+length(ind);
		end
	end
	
	% For each order of temporal scattering, we have a cell array containing 
	% the different orders of frequential scattering, so we need to flatten
	% the latter to obtain the regular scattering transform format.
	for m = 0:length(S)-1
		temp = flatten_scat(S{m+1});
		temp = temp{1};
		temp.meta.fr_order = temp.meta.order;
		temp.meta = rmfield(temp.meta,'order');
		S{m+1} = temp;
		
		temp = flatten_scat(U{m+1});
		temp = temp{1};
		temp.meta.fr_order = temp.meta.order;
		temp.meta = rmfield(temp.meta,'order');
		U{m+1} = temp;
	end
end
