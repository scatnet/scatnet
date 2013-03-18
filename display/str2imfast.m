function bigimg = str2imfast(str)
load 'all_char.mat'
bigimg = zeros(11,9*numel(str));
for c = 1:numel(str);
  cc = str(c);
  ii = unicode2native(cc);
  if numel(img_db{ii}>0)
  	im = img_db{ii};
    bigimg((1:11),(1:9) + (c-1)*9) = im;
  
  end
end
