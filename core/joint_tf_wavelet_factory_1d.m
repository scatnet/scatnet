% JOINT_TF_WAVELET_FACTORY_1D Create joint time-frequency wavelet cascade
%
% Usage
%    [Wop, time_filters, freq_filters] = joint_tf_wavelet_factory_1d( ...
%        N, time_filt_opt, freq_filt_opt, scat_opt)
%
% Input
%     N (int): The size of the signals to be transformed.
%     time_filt_opt (struct): The filter options for the time domain, same as
%        FILTER_BANK.
%     freq_filt_opt (struct): The filter options for the time domain, same as
%        FILTER BANK. These should be constructed in the same way as those used
%        when defining wavelet operators for SCAT_FREQ.
%     scat_opt (struct): The options for the scattering transform, same as
%        WAVELET_LAYER_1D and JOINT_TF_WAVELET_LAYER_1D.
%
% Output
%    Wop (cell): A cell array of wavelet layer transforms needed for the
%       scattering transform.
%    time_filters (cell): A cell array of filters used to define the time
%       domain wavelets.
%    freq_filters (cell): A cell array of filters used to define the
%       log-frequency domain wavelets.
%
% Description
%    To calculate the joint time-frequency scattering transform, we need to
%    define a set of filter banks, both in the time and log-frequency domains.
%    Given these filter banks, we can define the wavelet transforms that make
%    up the layers of the scattering transform. The filter banks are generated
%    using the FILTER_BANK function applied to the time_filt_opt and
%    freq_filt_opt structs. The first layer is then created using the
%    WAVELET_LAYER_1D function with the first time filter bank given as an
%    argument. All subsequent layers are formed using the
%    JOINT_TF_WAVELET_LAYER_1D function, which is given a pair of time domain
%    and log-frequency filter banks as an argument. The scat_opt struct is
%    given as arguments to all layers. The resulting function handles are
%    stored in the cell array Wop, where each element corresponds to a separate
%    layer of the scattering transform.
%
% See also
%    JOINT_TF_WAVELET_LAYER_1D, WAVELET_FACTORY_1D

function [Wop, time_filters, freq_filters] = ...
    joint_tf_wavelet_factory_1d(N,time_filt_opt,freq_filt_opt,scat_opt)

	time_filters = filter_bank(N, time_filt_opt);
	N_freq = 2^nextpow2(numel(time_filters{1}.psi.filter));
	freq_filters = filter_bank(N_freq, freq_filt_opt);
	scat_opt1 = scat_opt;
	scat_opt1.phi_renormalize = 0;
    
    Wop = cell(1,scat_opt.M+1);
	Wop{1} = @(X)(wavelet_layer_1d(X, time_filters{1}, scat_opt1));
	
	for m = 1:scat_opt.M
		time_filt_ind = min(numel(time_filters), m+1);
		freq_filt_ind = min(numel(freq_filters), m+1);
		Wop{1+m} = @(X)( ...
            joint_tf_wavelet_layer_1d(X, ...
            {freq_filters{freq_filt_ind},time_filters{time_filt_ind}}, ...
            scat_opt));
    end
end


