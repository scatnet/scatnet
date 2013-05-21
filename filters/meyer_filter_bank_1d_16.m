function filters = meyer_filter_bank_1d_16()
	
	N = 16;
	filters.phi.filter = [1,zeros(1,N-1)];
	filters.psi.filter{3} = sqrt(2)*...
		[0,1/sqrt(2),1,1/sqrt(2), zeros(1,N-4) ];
	filters.psi.filter{2} = sqrt(2)*...
		[0,0,0,1/sqrt(2),1,1,1/sqrt(2),zeros(1,N-7)];
	filters.psi.filter{1} = ... % last filter is real so normalization
		[0,0,0,0,0,0,1/sqrt(2),1,1,1,1/sqrt(2),zeros(1,N-11)];
	
	filters.psi.meta.k(1) = 1;
	filters.psi.meta.k(2) = 2;
	filters.psi.meta.k(3) = 3;
	
end

