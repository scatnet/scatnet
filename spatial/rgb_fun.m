%function feat = rgb_fun(filename, fun)
% apply function handler fun separately to all rgb channel of image located
% in filename
function feat = rgb_fun(filename, fun)
	rgbx = imread(filename);
	feat = [];
	if (numel(size(rgbx)) == 3)
		for c = 1:3
			cx = single(squeeze(rgbx(:,:,c)));
			feat = [feat, fun(cx)];
		end
	else
		cx = single(squeeze(rgbx(:,:)));
		feat = repmat(fun(cx),[1,3]);
	end
end

