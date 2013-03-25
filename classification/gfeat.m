function [feat_f,outmeta,outprecomp]=gfeat(f,options,precomp)
if (ischar(f))
  try
    f = imreadBW(f);
  catch
    fprintf('could not read the image...');
    feat_f = ['could_not_read_the_image_',f];
    return;
  end
end
feat=getoptions(options,'feat','raw');
outmeta={};
outprecomp={};
if iscell(feat)
  feat = feat{end};
end

if isa(feat,'function_handle')
  feat_f = feat(f);
else
  
  switch feat
    case 'raw'
      feat_f=reshape(f,1,numel(f));
      
    case 'scatt2d_uiuc'
      options.a = sqrt(2);
      options.J = 9;
      options.L = 8;
      options.aa = 0;
      options.sigma00 = 0.8;
      options.sigma0 = 1;
      options.slant = 0.5;
      options.mirror_padding_size = [32,32];
      options.mirror_unpadding_size = [64,64];
      if (exist('precomp','var'))
        feat_f = scatt_2d_wrapper(f,options,precomp.propagators);
        outprecomp = precomp;
      else
        [feat_f,propagators] = scatt_2d_wrapper(f,options);
        outprecomp.propagators = propagators;
      end
      
    case 'jointms_uiuc_noaa_nofinalavg'
      options.slant = 0.5; 
      options.sigma00 = 0.8;
      options.J = 9;
      options.aa = 0;
      options.mirror_padding_size = getoptions(options,'mirror_padding_size',[32,32]);
      options.mirror_unpadding_size = getoptions(options,'mirror_unpadding_size',64);
      options.no_final_avg = 1;
      if (exist('precomp','var')) % use precomputed stuff if provided
        [feat_f] = scatt_3d_ms_wrapper(f,options,precomp.propagators,precomp.map);
        outprecomp = precomp;
      else
        [feat_f, propagators,map] = scatt_3d_ms_wrapper(f,options);
        outprecomp.propagators = propagators;
        outprecomp.map = map;
      end
      
      
  end
end
end
