function j2s = next_bands_4d_lowpass(j,J,offset_j_min,delta_j,min_orbit_sz)
% for each j1, add the j2 only if the orbit corresponding
% to the point j_1,j_2 contains at least min_orbit_sz points
Jbar = J - min_orbit_sz + 1;
%
nb = Jbar + mod(j,delta_j) : delta_j : J;
% and nb must be >= J-min_orbit_sz +1 = Jbar (only low pass)

j2s = [];

for j2 = nb
  if ((j2-j)>=offset_j_min)
    orbit_size = min(j2-Jbar,j) + ... % left
      1 + ... % me
      J-j2;
    if (orbit_size >= min_orbit_sz )
      j2s = [j2s,j2];
    end
  end
end
end