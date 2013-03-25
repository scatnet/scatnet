function [out,propagators] = scatt_2d_wrapper(in,options,propagators)
options.null = 1;
% mirror padd
mirror_padding_size = getoptions(options,'mirror_padding_size',[64,64]);
in_padded = mirrorize(in,mirror_padding_size);
% precompute propagators if not already done or incorrect size_in
if (~exist('propagators','var') || norm(propagators.size_in-size(in_padded))>0)
  propagators = propagators_builder_2d(size(in_padded),options);
end

% apply scattering
[S,U] = gscatt(in_padded,propagators);
%%
mirror_unpadding_size = getoptions(options,'mirror_unpadding_size',mirror_padding_size);

% margin in function of resolution
mg = @(dim,res)(floor(mirror_unpadding_size(dim)/2^res));
% unpadding
remove_margin = @(x,res)(x(1+mg(1,res):end-mg(1,res),1+mg(1,res):end-mg(1,res)));
% post processing
post_proc_kind = getoptions(options, 'post_proc_kind','mean');
switch (post_proc_kind)
  case 'mean'
    post_proc = @(x,res)( mean(mean(x)));
  case 'none'
    post_proc = @(x)(x);
  otherwise
    error('illegal post processing');
end

% rasterize
sig = [];
for m = 2:numel(S)
  for p = 1:numel(S{m}.sig)
    curr_sig =  post_proc(remove_margin(S{m}.sig{p},S{m}.meta.res(p,end)));
    sig = [sig,curr_sig];
  end
end


if getoptions(options,'output_internal_nodes',0)
  out.sig = sig;
  out.U = U;
  out.S = S;
else
  out = sig;
end


