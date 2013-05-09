function path=generatePath(J)
%Generate a table of 2^J-1 paths. The maximum length of  a path in the scattering vector
%will be J. 
%For paths with a length strictly inferior to J, the remaining coefficients
%are replaced by -1.
%This function is typically used for the display of the figures presented in the
%paper:
% "Group Invariant Scattering", S. Mallat, 
% Comm. in Pure and Applied Mathematics, Dec. 2012, Wiley
 
 path=ones(2^J-1,J);
 path=-path;
 path(1)=J-1;
 rnb=2;
 for j1=J-2:-1:0
     path(rnb,1)=j1;
     for k=1:rnb-1
         path(rnb+k,1)=j1;
         for j=2:J
             path(rnb+k,j)=path(k,j-1);
         end
     end
     rnb=2*rnb;
 end
