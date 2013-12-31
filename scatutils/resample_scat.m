% RESAMPLE_SCAT Resample a scattering transform.
%
% Usages
%    S = RESAMPLE_SCAT(S, res, preserve_energy)
%
% Input
%    S (cell): A scattering transform.
%    res (int): The desired resolution.
%    preserve_energy (bool, optional): If set, renormalizes each resampled
%       coefficient so that its energy (sum of squares) remains the same.
%
% Output
%    S (cell): The scattering transform with each coefficient resampled to
%       resolution res.
%
% Description
%    Each coefficient in S is resampled to have the proper resolution. If the
%    desired resolution is finer, the signal will be interpolated. If the 
%    resolution is coarser, it will be downsampled.
%
% See also
%    LOG_SCAT

function S = resample_scat(S, res, preserve_energy)
	if nargin < 3
		preserve_energy = true;
	end

	if iscell(S)
		for m = 0:length(S)-1
			S{m+1} = resample_scat(S{m+1}, res); % self-call
        end
		return;
    end
	
	for p1 = 1:length(S.signal)
		res1 = 0;
		if isfield(S.meta,'resolution')
			res1 = S.meta.resolution(p1);
		end
		sz_orig = size(S.signal{p1});
		S.signal{p1} = interpft(S.signal{p1}, 2^(-res+res1)*size(S.signal{p1},1));
		sz_new = sz_orig;
		sz_new(1) = sz_orig(1)*2^(-res+res1);
		S.signal{p1} = reshape(S.signal{p1}, sz_new);
		if preserve_energy
			S.signal{p1} = S.signal{p1}*2^(-(-res+res1)/2);
		end
		S.meta.resolution(p1) = res;
	end
end
