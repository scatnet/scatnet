function [] = scattergram(U,S1,layerNb,j1,eps1,eps2,eps3)

%This function returns the set of three tables to be used for the
% the display of scalograms.

imgU1=scattergram_1(U,layerNb,eps1);
imgS1=scattergram_1(S1,layerNb,eps2);


imgS2_j1=scattergram_2(S1,layerNb+1,j1,eps3);figure;

subplot(3,1,1);imagesc(imgU1);
subplot(3,1,2);imagesc(imgS1); 
subplot(3,1,3);imagesc(imgS2_j1);
end



function img = scattergram_1(U, layerNb, epsilon)
%dcompute of associated to the layer layerNb. Note that the
%order of the scattering coefficient is equal to layerNb-1

nbFreqPt=length(U{layerNb}.signal);
nbTimePt=length(U{layerNb}.signal{1}); % this value may vary with time

img=zeros(nbFreqPt,nbTimePt);
for k=1:nbFreqPt
    
    p=U{layerNb}.meta.j(k)+1;
    
    if length(U{layerNb}.signal{k}) < nbTimePt
        %Regularize resolution if not the same
        R= nbTimePt/length(U{layerNb}.signal{k});
        img(p,:)=(interp(U{layerNb}.signal{k},R))';
        img(p,:)=log(abs(img(p,:)+epsilon));
        
    else img(p,:)=(log(abs((U{layerNb}.signal{k})')+epsilon));
        
    end
    
    
end
end


function img=scattergram_2(U,layerNb,j1,epsilon)

%display the scattergram of associated to the layer layerNb for j1 from 
%the layer layerNb-1 fixed. Note that the
%order of the scattering coefficient is equal to layerNb-1. Here layerNb >2


rU=renorm_scat(U);

nbTimePt=length(U{layerNb}.signal{1}); % this value may vary with time
maxJ2=max(U{layerNb}.meta.j(2,:)+1);
img=zeros(maxJ2,nbTimePt);
img=log(img+epsilon);
ind=find(U{layerNb}.meta.j(1,:)==j1);

for k=1:length(ind)
   p=U{layerNb}.meta.j(2,ind(k))+1;
   img(p,:)=(log(abs(rU{layerNb}.signal{ind(k)})+epsilon))';
end


end

