% INVERSE_WAVELET_1D Calculate the inverse wavelet transform
%
% Usage
%    x = INVERSE_WAVELET_1D(N0, x_phi, x_psi, meta_phi, meta_psi, ...
%        dual_filters, options)
%
% Input
%    N0 (numeric): The desired size of the output signal x.
%    x_phi (numeric): The lowpass filter output of WAVELET_1D.
%    x_psi (cell): The wavelet filter output of WAVELET_1D.
%    meta_phi (struct): The lowpass meta structure output of WAVELET_1D.
%    meta_psi (struct): The wavelet meta structure output of WAVELET_1D.
%    dual_filters (struct): The dual filters of the filter bank used to 
%       calculate the wavelet transform in WAVELET_1D.
%    options (struct, optional): Different parameters to the inverse wavelet
%       transform (currently unused);
%
% Output
%     x (numeric): The signal resulting from the inverse wavelet transform.
%
% Description
%    Using the dual filter bank, the wavelet transform is inverted by 
%    calculating
%        x(t) = Real(x_phi*dual_phi(t) + sum_k x_psi{k}*dual_psi{k}(t)).
%    Since x_phi and x_psi{k} might be subsampled, all signals are upsampled
%    to the resolution given by N0 and so the resulting signal x will be of
%    this resolution.
%
%    Note that this actually the pseudo-inverse of the wavelet transform,
%    since the wavelet transform is not surjective.
%
% See also 
%   DUAL_FILTER_BANK, WAVELET_1D

function [x,x_psi] = inverse_wavelet_1d(N0, x_phi, x_psi, meta_phi, meta_psi, ...
	dual_filters, options)
	
	if length(N0)>1
		error('Only 1D for the moment!')
	end
	
	if nargin < 7
		options = struct();
	end

	options = fill_struct(options, 'x_resolution', 0);
	
	temp = zeros(N0,1);

	j0 = options.x_resolution;
	
	N0_padded = dual_filters.meta.size_filter/2^j0;

	N_padded = dual_filters.meta.size_filter/2^meta_phi.resolution;
	x_phi = pad_signal(x_phi, N_padded, dual_filters.meta.boundary);

	x_phi = upsample(x_phi, N0_padded);
	
	x = conv_sub_1d(fft(x_phi), dual_filters.phi.filter, 0);
	
	for k = 1:length(x_psi)
		if isempty(x_psi{k})
			continue;
		end
		
		N_padded = dual_filters.meta.size_filter/2^meta_psi.resolution(k);
		x_psi{k} = pad_signal(x_psi{k}, N_padded, dual_filters.meta.boundary);

		% Calculate dual filter at current resolution as given by N0_padded.
		dpsi = realize_filter(dual_filters.psi.filter{k});
		dpsi = [dpsi(1:N0_padded/2); ...
			dpsi(N0_padded/2+1)/2+dpsi(end-N0_padded/2+1)/2; ...
			dpsi(end-N0_padded/2+2:end)];
		
		% Determine the energy in each of the subsampled blocks.
		n2 = sum(abs(reshape(dpsi, [N_padded N0_padded/N_padded]).^2),1);
		
		% Find the blocks with the most energy.
		[temp,ind] = sort(n2,'descend');
		if n2(ind(1)) > sum(n2)*0.9
			% Most of the energy is contained into one block; just put all the
			% frequencies into this block.
			x_psi_f = fft(x_psi{k});
			x_psi_f = [zeros((ind(1)-1)*N_padded,1); ...
				x_psi_f;  ...
				zeros(N0_padded-ind(1)*N_padded,1)];
			x_psi{k} = ifft(x_psi_f);
		else
			% Most of the energy is divided between two blocks; split the 
			% frequencies between the two blocks.
			x_psi_f = fft(x_psi{k});
			x_psi_f = fftshift(x_psi_f);
			x_psi_f = [zeros(((ind(1)+ind(2))/2-1)*N_padded,1); ...
				x_psi_f; ...
				zeros(N0_padded-((ind(1)+ind(2))/2)*N_padded,1)];
			x_psi{k} = ifft(x_psi_f);
		end
		
		% Multiply by the energy-preserving factor. Note that the zero-padding
		% of the FFT has already divided by N0_padded/N_padded.
		x_psi{k} = x_psi{k}*sqrt(N0_padded/N_padded);
		
		x = x+conv_sub_1d(fft(x_psi{k}), dual_filters.psi.filter{k}, 0);
		
		x_psi{k} = unpad_signal(x_psi{k}, 0, N0);
	end
	
	x = real(x);
	
	x = unpad_signal(x, 0, N0);
end
