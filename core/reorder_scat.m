function [oScatt order]=reorder_scat(Scatt)
	%Provided a Scattering vector  Scatt and a scale J,this function returns an
	%array of length 2^(J) containing all the SJ[p]f arranged in a particular
	%order.
	% oScat is an array of size 2N which stores a
	% the 2^J arrays SJ [p]f
	% A scale increasing path p = {j_n }_{n <=m} satisfies j_n < j_{n+1} < J
	% and scattered signals are computed with wavelet convolutions and modulus:
	%
	%    SJ [p] f = |...|f * psi_{j_1}|* psi_{j_2}|...*| psi_{j_m}| * phi_J
	%
	% Each SJ [p]f has 2N/2^J samples and all SJ[p]f are aggregated one after the
	% other in the one-dimensional array oScatt.
	% They are ordered for increasing path length m (smaller paths first).
	% For each 0 \leq m < J there are choose{J}{m} paths of length m.
	% They are ordered in reverse lexicographic order.
	
	%The array order contains the orders of  each of the SJ[p]f.
	
	[fScatt Metax]=format_scat(Scatt,'table');
	J=length(Scatt{2}.signal); %the parameter J is the number of first order coefficients
	
	lsig=length(Scatt{1}.signal{1});
	ltot=lsig*2^J;
	oScatt=zeros(1,ltot);
	order=zeros(1,ltot);
	
	oScatt(1,1:lsig)=(Scatt{1}.signal{1})';
	order(1,1:lsig)=0;
	p=lsig+1;
	path=generate_path(J);
	
	bigmatrix = Metax.j';
		
	
	for k=1:size(path,1)
 		path_curr = path(k, :);
 		
 		path_curr_rep = repmat(path_curr, size(bigmatrix, 1), 1);
 		
 		mask = bigmatrix == path_curr_rep;
 		sum_mask = sum(mask, 2);
 		ind = find(sum_mask == size(bigmatrix,2));
% 		
		%n_path_curr = numel(path_curr);
		%ind = find( sum(Meta.j(1:n_path_curr, :) == path_curr),2) == n_path_curr);
		
		%ind = find(Metax.j(1:nk,s) ==
		%for s=1:size(Metax.j,2)
		%	if Metax.j(:,s)==(path(k,:))'
	%			ind=s;
	%		end
	%	end
		
		
		if (p<lsig*2^J)
			oScatt(1,p:p+lsig-1)=(fScatt(:,:,ind))';
			order(1,p:p+lsig-1)=Metax.order(ind);
			p=p+lsig;
		end
		
		
	end
	
end
%   oScatt=[];
%   order=[];
%
%   oScatt=[oScatt (Scatt{1}.signal{1})'];
%   order=[order 0];
%
%  path=generatePath(J);
%
%  for k=1:size(path,1)
%      for s=1:size(Metax.j,2)
%          if Metax.j(:,s)==(path(k,:))'
%      ind=s;
%          end
%      end
%     oScatt=[oScatt (fScatt(:,:,ind))'];
%      order=[order Metax.order(ind)];
%  end