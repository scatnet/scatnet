% JOINT_TF_WAVELET_LAYER_1D Compute the two-dimensional, joint
% time-frequency wavelet transform from the modulus wavelet coefficients of
% the previous layer in a scattering network.
%
% Usages
%    [U_Phi,U_Psi] = joint_tf_wavelet_layer_1d(U,filters)
%
%    [U_Phi,U_Psi] = joint_tf_wavelet_layer_1d(U,filters,scat_opt)
%
% Input
%    U (struct): the input layer to be transformed.
%    filters (cell): the filters of the wavelet transform.
%       filters{1} contains the first-order temporal filters,
%       filters{2} contains the second-order temporal filters,
%       filters{3} contains the second-order log-frequential filters.
%    scat_opt (struct): the options of joint scattering transform.
%    scat_opt fields are :
%       * negative_freq (logical) : when set to true, computes scattering
%       coefficients for negative frÂ°j's, that is, chirplets going
%       downwards in log-frequency alonf time, as well as their mirrors.
%       This options is important to preserve the energy in the previous
%       layer. (default true)
%
% Description
%   This function builds a scattering layer, which performs two wavelet
%   transform at once : one over the time axis, the other on the
%   log-frequency axis. Henceforth, it is known as joint time-frequency
%   (tf) wavelet layer for 1-d signals. Starting from a scalogram U, it
%   computes a two-dimensional, low-pass filtering U_Phi of U, as well as
%   an array of two-dimensional, band-pass filtering U_Psi is required.
%   This function is called by joint_tf_wavelet_factory_1d and calls
%   wavelet_factory_1d twice, is whch most of the computation is
%   concentrated.
% See also
%   WAVELET_LAYER_1D, WAVELER_LAYER_2D, WAVELER_LAYER_3D

function [U_Phi, U_Psi] = joint_tf_wavelet_layer_1d(U, filters, scat_opt)
    % PRELUDE : as in wavelet_layer_1d, default options are managed here.
	if nargin < 3
		scat_opt = struct();
    end
	scat_opt = fill_struct(scat_opt, 'negative_freq', true);
	calc_U = (nargout>=2);
    
    % if log-frequential filters of negative center frequency are required,
    % the first-order temporal filters must be flipped to cover a
    % half-plane in the time-resolution Fourier domain.
	if scat_opt.negative_freq
		neg_filters = flip_filters(filters{1});
    end

	if ~isfield(U.meta, 'bandwidth'), U.meta.bandwidth = 2*pi; end
	if ~isfield(U.meta, 'resolution'), U.meta.resolution = 0; end
	
    
	% STEP 1 : calling wavelet_layer_1d for the scalogram U performs 
    % convolutions along time of the form (U*phi_tm) and (U*psi_tm).
	if calc_U
		[U_phi_tm, U_psi_tm] = wavelet_layer_1d(U, filters{2}, scat_opt);
	else
		% If U_Psi is not required as an output, it is not necessary to
		% perform a full wavelet transform : a low-pass filtering along
		% time is sufficient. This is achieved through calling
		% wavelet_layer_1d with one single output, namely U_phi_tm.
		U_phi_tm = wavelet_layer_1d(U, filters{2}, scat_opt);
        % In this case, U_psi_tm is just declared as a dummy layer.
		U_psi_tm.signal = {};
		U_psi_tm.meta = struct();
		U_psi_tm.meta.j = zeros(0,0);
    end
	
    
    % STEP 2 : the coefficients in U_phi_tm and U_psi_tm are lined up into
    % time-frequency tables Y_phi and Y_psi.
	Y_phi = concatenate_freq(U_phi_tm);
	Y_psi = concatenate_freq(U_psi_tm);
	
	% If this layer is the first to involve log-frequency scattering (which
    % is likely), then Y_phi.meta and Y_psi.meta do not contain fr_j fields.
    % As a consequence, we have to initialize them as dummy arrays.
	if ~isfield(Y_phi.meta,'fr_j')
		Y_phi.meta.fr_j = zeros(0,size(Y_phi.meta.j,2));
    end
	if ~isfield(Y_psi.meta,'fr_j')
		Y_psi.meta.fr_j = zeros(0,size(Y_psi.meta.j,2));
    end
	
    % Here, we declare the outputs U_Phi and U_Psi and initialize their
    % resolution indices r_phi and r_psi.
	U_Phi.signal = {};
	U_Phi.meta = struct();
	U_Psi.signal = {};
	U_Psi.meta = struct();
	U_Psi.meta.fr_j = zeros(size(Y_phi.meta.fr_j,1)+1,0);
	U_Psi.meta.j = zeros(size(Y_phi.meta.j,1)+1,0);
	r_Phi = 1;
	r_Psi = 1;
	p2 = 1;
    
    % STEP 3 : the tables Y_phi and Y_psi are respectively filtered along
    % the log-frequency axis. This step naturally divides in four
    % operations :
    %  - 3A : low-pass filtering of Y_phi
    %  - 3B : band-pass filtering of Y_phi
    %  - 3C : low-pass filtering of Y_psi
    %  - 3D : band-pass filtering of Y_psi
    % Observe that U_Phi consists in the result of 3A, whereas U_Psi
    % gathers the result of 3B, 3C and 3D.
    % In the sequel, s==1 means that we are dealing with operations 3A and
    % 3B ; conversely, s==2 means that we are dealing with 3C and 3D.
	for s = 1:2
		if s == 1
			Z = Y_phi;
		elseif s == 2
			Z = Y_psi;
        end
		
        % If the field Z.meta.fr_resolution does not already exist, there
        % has been no log-frequential subsampling prior to this layer.
        % Therefore, we must set all the log-frequential resolutions in Z
        % to zero.
        if ~isfield(Z.meta,'fr_resolution')
            Z.meta.fr_resolution = zeros(1,size(Z.meta.j,2));
        end
		
        r0 = 1; % resolution index for Z
        
        for p1 = 1:length(Z.signal)
            % p1 is the table index of the input network Z.
            % p1 remains equal to 1 is this layer is the first to include
            % log-frequency scattering.
            
            % TODO: Actually use fr_bw to calc psi_mask etc.
            % The Psi_mask logical array assesses which coefficients in
            % U_psi must be actually computed, since they carry a
            % non-negligible energy.
            % TODO : compute Psi_mask only once for all p1 and s.
            Psi_mask = calc_U&true(size(filters{1}.psi.filter));
            
            % Here, we specify scat_opt for frequency decomposition.
            scat_opt_fr = scat_opt;
            scat_opt_fr.x_resolution = Z.meta.fr_resolution(r0);
            scat_opt_fr.psi_mask = Psi_mask;
            scat_opt_fr.phi_renormalize = 0;
            
            % (i) prior reshaping
			% Get the current table and reshape it. Since we only want to 
			% transform along columns, we need to interleave these with 
			% the signal index (third), so that each column is transformed
			% independently.
			signal = Z.signal{p1};
			original_size = size(signal);
            % We append a '1' as third dimension if signal is just 2-D.
			appended_size = ...
                [original_size ones(1,3-length(original_size))];
            new_size = ...
                [appended_size(1) 1 appended_size(2)*appended_size(3)];
			signal = reshape(signal,new_size);

            % (ii) log-frequential wavelet transform
			[Z_Phi, Z_Psi, meta_Phi, meta_Psi] = ...
				wavelet_1d(signal, filters{1}, scat_opt_fr);
            
            if scat_opt.negative_freq
                % Wavelet transform with negative frequencies.
                [~, Z_neg_Psi, ~, meta_neg_Psi] = ...
                    wavelet_1d(signal, neg_filters, scat_opt_fr);
                % Append these to the set of all wavelet coefficients
                % TODO : use [Psi_mask Psi_mask(end:-1:1)] ?
                Psi_mask = [Psi_mask Psi_mask];
                Z_Psi = [Z_Psi Z_neg_Psi];
                % The fields in meta_neg_Psi are set identical as in
                % meta_Psi, except that the resolution j is mirrored
                % below zero.
                rng_neg = 1:length(Z_neg_Psi);
                rng = length(Z_Psi)-length(Z_neg_Psi)+1:length(Z_Psi);
                meta_Psi = map_meta(meta_neg_Psi,rng_neg,meta_Psi,rng,'j');
                meta_Psi.j(rng) = -meta_neg_Psi.j(rng_neg);
            end
            
			if s == 1
				% We've transformed the temporal low-pass Y_phi, so we need to
				% propertly care for the frequential low-pass Z_Phi. Put it in
				% U_Phi, that is.
				
				% a. Determine the subsampling rate along resolutions.
				ds = meta_Phi.resolution-scat_opt_fr.x_resolution;
				% b. Extract the log-frequency indices with a subsampling
				% by 2^ds.
				ind0 = r0:2^ds:r0+size(signal,1)-1;
				% c. Count the remaining indices.
				fr_count = size(Z_Phi,1);
				% d. Put Z_Phi back into "scale x signal index" format.
				% Note that there is a one-to-one correspondence between Z
				% (that is Y_phi here) and U_Phi, so p1 will do perfectly
				% as an index.
				U_Phi.signal{p1} = ...
                    reshape(Z_Phi,[size(Z_Phi,1) appended_size(2:3)]);
				% e. Determine the indices in the U_Phi output array.
				ind_Phi = r_Phi:r_Phi+fr_count-1;
				% f. Copy the meta fields of the original frequencies.
				U_Phi.meta = map_meta(Z.meta,ind0,U_Phi.meta,ind_Phi);
				% g. Assign the frequential resolutions.
				new_res = meta_Phi.resolution;
				U_Phi.meta.fr_resolution(1,ind_Phi) = ...
                    new_res*ones(1,fr_count);
				% h. Increase current running U_Phi index.
				r_Phi = r_Phi+length(ind_Phi);
			elseif s == 2
				% We've transformed the temporal band-pass Y_psi, so we
				% both care about Z_phi and Z_psi. However, to facilite the
				% treatment, we handle the low-pass Z_phi as another
				% band_pass filter of the Z_phi table. As a result,
				% we must append one logical 'true' at the end of Psi_mask.
				Z_Psi = [Z_Psi Z_Phi];
				Psi_mask = [Psi_mask true];
				meta_Psi = map_meta(meta_Phi,1,meta_Psi,length(Z_Psi),'j');
				meta_Psi.j(length(Z_Psi)) = length(filters{1}.psi.filter);
            end
		
            % (iv) every frequential band-pass filter must be reshaped back
            % into the "table x signal x index" format.
			for k = find(Psi_mask)
				% a. Determine the subsampling rate along resolutions
				ds = meta_Psi.resolution(k)-scat_opt_fr.x_resolution;
				% b. Extract the log-frequency indices, with a subsampling
                % by 2^ds.
				ind0 = r0:2^ds:r0+size(signal,1)-1;
				% c. Count the reminaing indices.
				fr_count = size(Z_Psi{k},1);
                % d. Put Z_Psi back into "scale x signal index" format.
				% This time, we need to keep track of p2 here and increase
				% it along iterations k.
				U_Psi.signal{p2} = ...
                    reshape(Z_Psi{k},[size(Z_Psi{k},1) appended_size(2:3)]);
				% e. Determine the indices in the U_phi output array.
				ind_Psi = r_Psi:r_Psi+fr_count-1;
				% f. Copy the meta fields of the original frequencies.
				U_Psi.meta = ...
                    map_meta(Z.meta,ind0,U_Psi.meta,ind_Psi,{'j','fr_j'});
				if s == 1
					% If Z is the temporal low-pass filter Y_phi, new j's
					% are all big J. This won't already be in Z.meta.j since
					% low-pass filter indices are not in there.
					U_Psi.meta.j(:,ind_Psi) = ...
                        [Z.meta.j(:,ind0); ...
                          length(filters{2}.psi.filter)*ones(1,fr_count)];
                elseif s==2
                    % If Z is the temporal band-pass filter Y_psi, all
                    % scales j are copied without modification.
					U_Psi.meta.j(:,ind_Psi) = Z.meta.j(:,ind0);
                end
				% g. Assign the frequential resolutions after getting the
				% log-frequency decomposition scale fr_j, which here is
				% given by meta.psi.j, and subsample it by 2^ds.
                fr_j = meta_Psi.j(k);
				U_Psi.meta.fr_j(:,ind_Psi) = [...
                    Z.meta.fr_j(:,ind0); fr_j*ones(1,fr_count)];
				new_res = meta_Psi.resolution(k);
				U_Psi.meta.fr_resolution(1,ind_Psi) = ...
                    new_res*ones(1,fr_count);
				% h. Increase the current running U_psi index.
				r_Psi = r_Psi+length(ind_Psi);
				% Increase the path index p2 (see d. above)
				p2 = p2+1;
			end
			
			% (v) Increase the current running Z index.
			r0 = r0+size(signal,1);
		end
	end

	% STEP 4 : transform the tables U_phi and U_psi back
	U_Phi = separate_freq(U_Phi);
	U_Psi = separate_freq(U_Psi);
end

%%% TODO
% - incorporate progressivity along log-frequency
% - use fr_bw to actually compute Psi_mask
% - compute Psi_mask only once for all p1 and logical s
