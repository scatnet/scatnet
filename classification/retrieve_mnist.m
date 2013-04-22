function [train, test] = retrieve_mnist(Ltrain, Ltest, maxclasses)
	
	if nargin < 3
		D=10;
		maxclasses=[0:D-1];
	else
		if isscalar(maxclasses)
			if maxclasses>0
				maxclasses=[0:maxclasses-1];
			else
				maxclasses=[0:9];
			end
		end
		D=length(maxclasses);
	end
	
	global mpath;
	
	[labels] = readidx(fullfile(mpath,'mnist','train-labels-idx1-ubyte'),60000,60000);
	[xifres] = readidx(fullfile(mpath,'mnist','train-images-idx3-ubyte'),60000,60000);
	
	tmp32=zeros(32);
	for d=1:D
		sli=find(labels==maxclasses(d));
		for s=1:min(Ltrain,length(sli))
			tmp=xifres(:,sli(s));
			tmp32(3:30,3:30)=reshape(tmp,28,28);
			train{d}{s} = tmp32;
		end
	end
	
	clear labels;
	clear xifres;
	
	[xifres] = readidx(fullfile(mpath,'mnist','t10k-images-idx3-ubyte'),10000,10000);
	[labels] = readidx(fullfile(mpath,'mnist','t10k-labels-idx1-ubyte'),10000,10000);
	
	for d=1:D
		sli=find(labels==maxclasses(d));
		for s=1:min(Ltest,length(sli))
			tmp=xifres(:,sli(s));
			tmp32(3:30,3:30)=reshape(tmp,28,28);
			test{d}{s} = tmp32;
		end
	end
end
