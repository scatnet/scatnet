function orbit = generic_orbit(meta, fn, ids, ind, direction, minoffset, maxoffset)

for k = 1:numel(fn)
  position(1,k) = eval(['meta.',fn{k},'(ind,ids(k))']);
end
orbit = [];
ind_pos2 = 0;
for offset = minoffset:maxoffset
  pos2 = position + offset*direction;
  
  for k =1:numel(fn)
    curr_cond = eval(['meta.',fn{k},'(:,ids(k))==pos2(k)']);
    if (k==1)
      cond = curr_cond;
    else
      cond = cond.*curr_cond;
    end
    save_cond(:,k) = curr_cond;
  end
  ind_pos2 = find(cond == 1)';
  orbit = [orbit,ind_pos2];
end