% SEPARATE_FREQ Separate first frequencies from tables into cell arrays
%
% Usage
%    Z = SEPARATE_FREQ(Y);
%
% Input
%    Y (struct or cell): The scattering layer to process, or a cell array of
%       scattering layers. These all have signals that are two-dimensional,
%       with the first dimension corresponding to the lambda1 log-frequency.
%
% Output
%    Z (struct or cell): The same scattering layers, with all coefficients
%       separated along the first dimension into different signals.
%
% Description
%    SEPARATE_FREQ undoes the action of CONCATENATE_FREQ, which takes a (set
%    of) scattering layer(s) and concatenates them along the first
%    log-frequency dimension lambda1, grouping the coefficients by the
%    remaining log-frequencies lambda2, lambda3, and so on. The SEPARATE_FREQ
%    function takes such a concatenated scattering layer and separates out the
%    different time signals corresponding to different lambda1 values.
%
%    For more details, see CONCATENATE_FREQ.
%
% See also
%    CONCATENATE_FREQ, JOINT_TF_WAVELET_LAYER_1D

function Z = separate_freq(Y)
	if iscell(Y)
		Z = {};
	
		for m = 0:length(Y)-1
			Z{m+1} = separate_freq(Y{m+1});
		end
		
		return;
	end

	Z.signal = {};
	Z.meta = struct();

	r = 1;
	for k = 1:length(Y.signal)
		if ~iscell(Y.signal{k})
			% because matlab is stupid and ignores last dim if 1
			sz_orig = size(Y.signal{k});
			if numel(sz_orig) == 2
				sz_orig(3) = 1;
			end
		else
			sz_orig = [length(Y.signal{k}) 0 size(Y.signal{k}{1},2)];
		end	
		
		for l = 1:sz_orig(1)
			if ~iscell(Y.signal{k})
				nsignal = Y.signal{k}(l,:);
			else
				nsignal = Y.signal{k}{l};
			end

			nsignal = reshape(nsignal,[numel(nsignal)/sz_orig(3) sz_orig(3)]);

			Z.signal{r} = nsignal;

			r = r+1;
		end
	end

	[temp,I] = sortrows(Y.meta.j(1:size(Y.meta.j,1),:).');
	
	Z.signal = Z.signal(I);
	
	field_names = fieldnames(Y.meta);
	for n = 1:length(field_names)
		src_value = getfield(Y.meta,field_names{n});
		Z.meta = setfield(Z.meta,field_names{n},src_value(:,I));
	end
	
	Z.signal = cellfun(@(x)(permute(x,[1 3 2])), Z.signal, ...
		'UniformOutput', false);
end
