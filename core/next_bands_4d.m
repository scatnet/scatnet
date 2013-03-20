function j2s = next_bands_4d(j,J,offset_j_min,delta_j,min_orbit_sz)
% for each j1, add the j2 only if the orbit corresponding
% to the point j_1,j_2 contains at least min_orbit_sz points
nb = j + offset_j_min : delta_j : J-1;
j2s = [];
for j2 = nb
  if (J-1 - (j2-j) + 1 >= min_orbit_sz )
    j2s = [j2s,j2];
  end
end
end