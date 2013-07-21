%
%
%© CMAP, Ecole Polytechnique 
%contributors: Joan Bruna and Stéphane Mallat (2010)
%bruna@cmap.polytechnique.fr
%
%This software is a computer program whose purpose is to implement
%an image classification architecture based on the Scattering Transform.
%
%This software is governed by the CeCILL  license under French law and
%abiding by the rules of distribution of free software.  You can  use, 
%modify and/ or redistribute the software under the terms of the CeCILL
%license as circulated by CEA, CNRS and INRIA at the following URL
%"http://www.cecill.info". 
%
%As a counterpart to the access to the source code and  rights to copy,
%modify and redistribute granted by the license, users are provided only
%with a limited warranty  and the software's author,  the holder of the
%economic rights,  and the successive licensors  have only  limited
%liability. 
%
%In this respect, the user's attention is drawn to the risks associated
%with loading,  using,  modifying and/or developing or reproducing the
%software by the user in light of its specific status of free software,
%that may mean  that it is complicated to manipulate,  and  that  also
%therefore means  that it is reserved for developers  and  experienced
%professionals having in-depth computer knowledge. Users are therefore
%encouraged to load and test the software's suitability as regards their
%requirements in conditions enabling the security of their systems and/or 
%data to be ensured and,  more generally, to use and operate it in the 
%same conditions as regards security. 
%
%The fact that you are presently reading this means that you have had
%knowledge of the CeCILL license and that you accept its terms.
%
%
%

function [train, test] = retrieve_mnist_data(Ltrain, Ltest, maxclasses)

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

