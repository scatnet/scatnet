function [runout, Sout] = update_avg_coeffs(runin, Sin)

Sout=Sin;

runout=0*runin;
rast=1;
%first and second order coeffs
for j=2:3
for i=1:size(Sin{j}.signal,2)
runout(rast)=runin(rast)+Sin{j}.signal{i};
Sout{j}.signal{i} = runin(rast);
rast=rast+1;
end
end


