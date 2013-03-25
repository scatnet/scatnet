function [out,propagators,map] = scatt_3d_ms_wrapper(in,options,propagators,map)
%%
options.null = 1;
% mirror padd
mirror_padding_size = getoptions(options,'mirror_padding_size',[64,64]);
in_padded = mirrorize(in,mirror_padding_size);
no_final_avg = getoptions(options,'no_final_avg',0);
if (no_final_avg)
  options.preserve_l2_norm = 0;
  options.output_filters = 1;
end

% precompute propagators if not already done
if (~exist('propagators','var') )
  propagators = propagators_builder_3d_plus_scale(size(in_padded),options);
end

% apply scattering
[AS,S] = gscatt(in_padded,propagators);

mirror_unpadding_size = getoptions(options,'mirror_unpadding_size',mirror_padding_size(1));

if (no_final_avg)
  filters = propagators.filters;
  if ~exist('map','var')
    [sig,map] = rasterize_scale_orbit_3d_no_final_avg(AS, propagators.info.delta_J_max,mirror_unpadding_size,options,filters);
  else % use precomputed map if provided
    sig= rasterize_scale_orbit_3d_no_final_avg(AS, propagators.info.delta_J_max,mirror_unpadding_size,options,filters,map);
  end
else
  % rasterize, format in matrix index by (scale,pbar) and upad
  if ~exist('map','var')
    [sig,map] = rasterize_scale_orbit_3d(AS, propagators.info.delta_J_max,mirror_unpadding_size,options);
  else % use precomputed map if provided
    sig= rasterize_scale_orbit_3d(AS, propagators.info.delta_J_max,mirror_unpadding_size,options,map);
  end
end
if getoptions(options,'output_internal_nodes',0)
  out.map = map;
  out.sig = sig;
  out.AS = AS;
  out.S = S;
  if (renorm_local || logblp || logafterU1)
    out.S_renorm_internal = S_renorm_internal;
    out.S_renorm_before_lowpass = S_renorm_before_lowpass;
  end
else
  out = sig;
end


