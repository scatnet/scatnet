% CONCATENATE_FREQ Concatenates first frequencies into tables
%
% Usage
%    Y = CONCATENATE_FREQ(X, fmt)
%
% Input
%    X (struct or cell): The scattering layer to process, or a cell array of
%       such scattering layers. Often S or U outputs of SCAT.
%    fmt (char, optional): Either 'table' or 'cell'. Describes how grouped
%       coefficients are assembled. See Description for more details (default
%       'table').
%
% Output
%    Y (struct or cell): The same scattering layers, with all coefficients 
%       that only differ by first frequency lambda1 grouped together.
%
% Description
%    In order to perform operations along frequency, or in the time-frequency
%    plane, scattering coefficients need to be grouped together and concate-
%    nated along the first frequency axis, lambda1. Specifically, all coef-
%    ficients that have the same frequencies lambda2, lambda3, etc are grouped
%    together. For the first order, this means that we only have one group,
%    whereas in the second order, we have one group for each lambda2, and so
%    on.
%
%    Each signal in the input is of the form Nx1xK, where N is the number of
%    time samples and K is the number of signals that are processed simulta-
%    neously. Consider one group as described above, containing P coeffi-
%    cients, with all coefficients having the same number of time samples. 
%    This is the case, for example, when the input X is a scattering transform
%    output S. Here, the coefficients can be concatenated into a single table
%    of dimension NxPxK. If the fmt parameter is set to 'table', this is in-
%    deed what happens. The P coefficients in X are therefore replaced by
%    one table in Y of the dimension described above. If fmt equals 'cell',
%    a cell array is created instead of a table, containing each of the sig-
%    nals in the group. In both cases, frequencies lambda1 are arranged in 
%    order of decreasing frequency (increasing scale).
%
%    To preserve the meta fields of the original coefficients, they are copied
%    into the output structure. They are ordered in order of increasing group
%    index, so that if the first group contains P coefficients, the first
%    P columns of a given meta field corresponds to the coefficients of the 
%    first group, and so on. Within each group, the columns are ordered in 
%    order of decreasing lambda1, just like within the groups themselves.
%
% See also
%    SEPARATE_FREQ, SCAT_FREQ, JOINT_TF_WAVELET_LAYER_1D

function Y = concatenate_freq(X, fmt)
	if nargin < 2
		fmt = 'table';
	end
	
	if iscell(X)
		% We have a complete transform - a cell array of layers - so apply it
		% to each layer.
		Y = {};
	
		for m = 0:length(X)-1
			Y{m+1} = concatenate_freq(X{m+1}, fmt);
		end
		
		return;
	end
	
	% Form equivalences between coefficients with the same j1 and group them
	% together
	if isfield(X.meta,'fr_j')
		% We have scattering along frequency, use this to group
		[temp1,temp2,assigned] = unique([X.meta.fr_j; X.meta.j(2:end,:)].','rows');
	else
		[temp1,temp2,assigned] = unique(X.meta.j(2:end,:).','rows');
	end
	
	% Prepare output and intialize meta structure.
	Y.signal = {};
	Y.meta = struct();
	field_names = fieldnames(X.meta);
	for n = 1:length(field_names)
		sz = size(getfield(X.meta,field_names{n}));
		Y.meta = setfield(Y.meta,field_names{n},zeros(sz(1),0));
	end
	
	% 1D coefficients are of the form Nx1xK, where N is the number of time
	% samples and K is the number of signals. Permute them so we have NxKx1,
	% instead, this simplifies creating tables later.
	X.signal = cellfun(@(x)(permute(x,[1 3 2])), X.signal, ...
		'UniformOutput', false);
	
	for k = 1:max(assigned)
		sz_orig = size(X.signal{1});
		
		% Select the coefficients belonging to the current group.
		ind = find(assigned==k);
		
		if strcmp(fmt,'table')
			% Each 'signal' being a table of size NxK, as described above, and
			% the cell array being arranged horizontally, the following con-
			% catenates all the signals of indices ind into a table of size
			% Nx(KP), where P is the number of coefficients in the current 
			% group.
			nsignal = [X.signal{ind}];
			
			% Unwrap the second dimension to have NxKxP
			nsignal = reshape(nsignal,[size(nsignal,1) sz_orig(2) length(ind)]);
			% Put the frequency in the first dimension and the signal index 
			% in the last dimension, giving PxNxK.
			nsignal = permute(nsignal,[3 1 2]);
		else
			% Don't make a table, just copy the cell array. Note that this is 
			% not very compatible with the normal layer structure.
			nsignal = X.signal(ind);
		end
		
		% Store the kth table in the output signal
		Y.signal{k} = nsignal;
		
		% Copy the relevant meta fields from input to output. Note that the 
		% pth column of the meta fields no longer corresponds to the pth 
		% coefficient in Y.signal{p}. Instead, the cumulative index along the
		% second dimension is used. As such, if there are P different lambda1s
		% in Y.signal{1}, so P = size(Y.signal{1},2), the first P columns of
		% meta correspond to these signals.
		for n = 1:length(field_names)
			src_value = getfield(X.meta,field_names{n});
			dst_value = getfield(Y.meta,field_names{n});
			dst_value = [dst_value src_value(:,ind)];
			Y.meta = setfield(Y.meta,field_names{n},dst_value);
		end
	end
end
