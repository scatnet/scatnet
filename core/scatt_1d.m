function [S,U] = scatt_1d(x,wavemod)
	N = size(x,1);
	nb_layer = numel(wavemod)-1;

	U{1}.signal = {x};
	U{1}.meta.bandwidth = 2*pi;
	U{1}.meta.resolution = 0;
	U{1}.meta.scale = zeros(1,0);
	
	U = pad_boundary(U,2*N,'symm');
	
	for m = 1 : nb_layer
		[S{m},U{m+1}] = wavemod{m}(U{m});
	end

	S{nb_layer+1} = wavemod{nb_layer}(U{nb_layer+1});
	
	if nargout >= 2
		U = unpad_boundary(U,N);
	end
	
	S = unpad_boundary(S,N);
end

function X = pad_boundary(X,N1,boundary)
	N0 = size(X{1}.signal{1},1);
	
	if strcmp(boundary,'symm')
		ind0 = [1:N0 N0:-1:1];
	elseif strcmp(boundary,'per')
		ind0 = [1:N0];
	else
		error('Invalid boundary conditions!');
	end
	
	ind = zeros(1,N1);
	ind(1:N0) = 1:N0;
	ind(N0+1:N0+floor((N1-N0)/2)) = ...
		ind0(mod([N0+1:N0+floor((N1-N0)/2)]-1,length(ind0))+1);
	ind(N1:-1:N0+floor((N1-N0)/2)+1) = ...
		ind0(mod([1:ceil((N1-N0)/2)]-1,length(ind0))+1);
	
	for m = 0:length(X)-1
		for j1 = 0:length(X{m+1}.signal)-1
			%X{m+1}.signal{j1+1} = [X{m+1}.signal{j1+1}; X{m+1}.signal{j1+1}(end:-1:1,:)];
			X{m+1}.signal{j1+1} = X{m+1}.signal{j1+1}(ind,:);
		end
	end
end

function X = unpad_boundary(X,N0)
	for m = 0:length(X)-1
		for j1 = 0:length(X{m+1}.signal)-1
			N2 = 1+floor((N0-1)/2^X{m+1}.meta.resolution(j1+1));
			X{m+1}.signal{j1+1} = X{m+1}.signal{j1+1}(1:N2,:);
		end
	end
end