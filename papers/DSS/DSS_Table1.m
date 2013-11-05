super = 2;
opt.filter_type = {'morlet_1d','spline_1d'};
opt.B = [8 1];
opt.Q = [super*8 1];
opt.filter_format = 'fourier_truncated';
M = 3;

Js = [9:2:15];

N = 2^17;

src = phone_src('/path/to/timit');
files = src.files;
rs = RandStream.create('mt19937ar','Seed',floor(pi*1e9));
files = files(rs.randperm(length(files)));

scat_opt.M = M;
scat_opt.oversampling = 2;

for l = 1:length(Js)
	opts{l} = opt;
	
	opts{l}.J = T_to_J(2^Js(l),opts{l});

	[Wop{l},filters{l}] = wavelet_factory_1d(N, opts{l}, scat_opt); 
end

E = zeros(length(Js),M+1,length(files));

for k = 1:length(files)
	fprintf('%s\n',files{k});
	x = data_read(files{k});
	x = x(1:min(N,length(x)));
	x = [x; zeros(N-length(x),1)];	
	x = x-mean(x);
	x = x/sqrt(sum(abs(x(:)).^2));
	for l = 1:length(Js)
		[t,meta] = format_scat(scat(x,Wop{l}));
		
		t = squeeze(t);
		for m = 0:max(meta.order)
			t1 = t(meta.order==m,:);
			E(l,m+1,k) = sum(abs(t1(:)).^2);
		end
	end
	mean(E(:,:,1:k),3)
end

% At the end, we should have
%	0.0000    0.9453    0.0484    0.0023
%	0.0000    0.6800    0.2900    0.0191
%	0.0000    0.3486    0.5325    0.1156
%	0.0000    0.2772    0.5607    0.2471



