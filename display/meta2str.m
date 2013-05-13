function str = meta2str(meta,ind)
% print a string resuming the meta at index ind
str= [];
endline_str = ' ';
try
fns = fieldnames(meta);
catch
  fprintf('nometa \n')
  fns = {};
end
for ifn = 1:numel(fns)
  
  
  nonumber = 0;
  fn = fns{ifn};
  
  if ~(strcmp(fn,'res') || strcmp(fn,'res_rot'))

    vec = eval(['meta.',fn]);
    if (strcmp(fn,'theta1_downsampled'))
      fn = 'th1ds';
      nonumber = 1;
    end
    if (strcmp(fn,'theta'))
      fn = 'th';
    end
    if (strcmp(fn,'theta2'))
      fn = 'th2';
      nonumber = 1;
    end
    
    
    for i = 1:size(vec,1)
      if (nonumber)
        nb = '';
      else
        nb =int2str(i) ;
      end
      str = [str,fn,nb,'=',int2str(vec(i,ind)),endline_str];
    end
    
  end
end