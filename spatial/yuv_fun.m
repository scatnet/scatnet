%function feat = rgb_fun(filename, fun)
% apply function handler fun separately to all rgb channel of image located
% in filename
function feat = yuv_fun(filename, fun)
rgbx = imread(filename);

feat = [];
if (numel(size(rgbx)) ~= 3)
    rgbx = repmat(rgbx,[1,1,3]);
end
yuvx = rgb2yuv(rgbx);
feat = [];
for c = 1:3
    cx = single(squeeze(yuvx(:,:,c)));
    feat = [feat, fun(cx)];
end
end


