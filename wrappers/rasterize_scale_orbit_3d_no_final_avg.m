function [full_stack,map] = rasterize_scale_orbit_3d_no_final_avg(AS, delta_J_max,mirror_margin,options,filters,map)
options.null = 1;
a = filters.infos.a;
step_j = log2(a);
J_bar = numel(filters.phi_allscale{1}) - delta_J_max  ;
preserve_l2_norm = getoptions(options,'preserve_l2_norm',1);
% assume no norm preserve
if (preserve_l2_norm)
  error('preserve_l2_norm should be 0');
end
%% compute maps
if (~exist('map','var'))
  map = orbit_scale_extractor_simpler(AS{2}.meta,AS{3}.meta,delta_J_max);
end
%% first layer
mg = @(res)(floor(mirror_margin/2^res));
%avg = @(x,res)( mean(mean(x(1+mg(res):end-mg(res)))) / 2^res);

avg = @(x,delta_j,res)( ifft2( fft2(x) .* filters.phi_allscale{res+1}{J_bar + delta_j + 1} ) );
downsampler = @(delta_j,res)(floor(step_j*(J_bar+delta_j) - res));
ds = @(x,delta_j,res)(downsampling_2d(x,downsampler(delta_j,res),preserve_l2_norm));
remove_margin = @(x,res)(x(1+mg(res):end-mg(res),1+mg(res):end-mg(res)));


for delta_j = 0 : size(map{1},1)-1
  for n_bar = 1:size(map{1},2)
    n_bar_plus_delta_j = map{1}(delta_j+1,n_bar);
    sig = AS{2}.sig{n_bar_plus_delta_j};
    res_sig =  AS{2}.meta.res(n_bar_plus_delta_j,end);
    sigavg = avg(sig,delta_j, res_sig);
    sigavgds = ds(sigavg,delta_j,res_sig);
    sigavgdsnomg = remove_margin(sigavgds, res_sig + downsampler(delta_j,res_sig) );
    if (n_bar ==1) % lazy allocation
      s1{delta_j+1} = zeros([size(sigavgdsnomg),size(map{1},2)]);
    end
    s1{delta_j+1}(:,:,n_bar) = sigavgdsnomg;
  end
end

%% second layer
for delta_j = 0 : size(map{2},1)-1
  for n_bar = 1:size(map{2},2)
    n_bar_plus_delta_j = map{2}(delta_j+1,n_bar);
    sig = AS{3}.sig{n_bar_plus_delta_j};
    res_sig =  AS{3}.meta.res(n_bar_plus_delta_j,end);
    sigavg = avg(sig,delta_j, res_sig);
    sigavgds = ds(sigavg,delta_j,res_sig);
    sigavgdsnomg = remove_margin(sigavgds, res_sig + downsampler(delta_j,res_sig) );
    if (n_bar ==1) % lazy allocation
      s2{delta_j+1} = zeros([size(sigavgdsnomg),size(map{2},2)]);
    end
    s2{delta_j+1}(:,:,n_bar) = sigavgdsnomg;
  end
end

%%
for delta_j = 0 : size(map{2},1)-1
  % concatenate matrix along third dimension (scattering node)
  full_stack{delta_j+1} = cat(3,s1{delta_j+1},s2{delta_j+1});
end


