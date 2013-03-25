function map =  orbit_scale_extractor_simpler(meta1,meta2,max_delta_J)
% assumes output of classical 2d scattering
% outputs a 2d map of coefficient's postion indexed by :
% line = dj
% column = pbar


%%
% for all coefficient, find the 0:3 scale orbit and thats it

%% first layer
valid_ind = 0;
meta = meta1;
for ind = 1:size(meta.j,1)
  fn =          {'j',};
  ids =         [ 1 , 1     ];
  direction =   [ 1 , 0     ];
  minoffset = 0;
  maxoffset = max_delta_J - 1;
  orbit = generic_orbit(meta, fn, ids, ind, direction, minoffset, maxoffset);
  if (numel(orbit)==max_delta_J)
    valid_ind = valid_ind +1;
    map1(1:max_delta_J,valid_ind) = orbit';
  end
end

map{1} = map1;

%% second layer
valid_ind = 0;
meta = meta2;
for ind = 1:size(meta.j,1)
  fn =          {'j','j','j_rot','theta2'};
  ids =         [ 1 , 2 , 1     , 1      ];
  direction =   [ 1 , 1,  0     , 0      ]; 
  minoffset = 0;
  maxoffset = max_delta_J - 1;
  orbit = generic_orbit(meta, fn, ids, ind, direction, minoffset, maxoffset);
  if (numel(orbit)==max_delta_J)
    valid_ind = valid_ind +1;
    map2(1:max_delta_J,valid_ind) = orbit';
  end
end
map{2} = map2;




