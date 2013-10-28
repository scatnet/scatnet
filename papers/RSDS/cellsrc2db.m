% CELLSRC2DB Constitute a database compatible with the ScatNet
%   convention with a cell of one object per image and a src
%
% Usage 
%   db = cellsrc2db(cell, src);
function db = cellsrc2db(cell, src)
	db.src = src;
	db.features = cell2mat(cell);
	for i = 1:numel(cell)
		db.indices{i} = i;
	end
end
