% LOG_SCAT Calculate the logarithm of a scattering transform.
%
% Usages
%    S = LOG_SCAT(S)
%
%    S = LOG_SCAT(S, epsilon)
%
% Input
%    S (cell): A scattering transform.
%    epsilon (real): An small constant added to each component of S in
%    order to reduce contribution of noise (default 2^-20).
%
% Output
%    S (cell): The scattering transform with the logarithm applied to each 
%       coefficient.
%
% Description
%    This function takes the logarithm of every signal component in a
%    scattering transform, while preserving the network structure. A small
%    additive constant is used to keep finite results. Note that this
%    function may also take a single layer of the whole network as an
%    argument, as it calls itself recursively layerwise.
%
% See also
%    RENORM_SCAT

function S = log_scat(S, epsilon)
    % Default value for epsilon
	if nargin < 2
		epsilon = 2^(-20); % approximately 1e-6
    end

    % Logarithm of the whole scattering network
	if iscell(S)
		for m = 0:length(S)-1
			S{m+1} = log_scat(S{m+1}, epsilon); % self-call
        end
		return;
    end
	
    % Logarithm layer per layer
	for p1 = 1:length(S.signal)
		res = 0;
		if isfield(S.meta,'resolution')
			res = S.meta.resolution(p1);
		end
		sub_multiplier = 2^(res/2);
		S.signal{p1} = log(abs(S.signal{p1})+epsilon*sub_multiplier);
	end
end
