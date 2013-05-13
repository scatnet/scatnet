super = 2;
opt.filter_type = {'morlet_1d','spline_1d'};
opt.B = [8 1];
opt.Q = [super*8 1];
opt.filter_format = 'fourier_truncated';
M = 3;

Js = [9:2:15];

N = 5*2^17;

src = gtzan_src('~/GTZAN/gtzan');
files = src.files;
rs = RandStream.create('mt19937ar','Seed',floor(pi*1e9));
files = files(rs.randperm(length(files)));

for l = 1:length(Js)
	opts{l} = opt;
	
	opts{l}.J = T_to_J(2^Js(l),opts{l}.Q,opts{l}.B);

	cascade{l} = wavelet_factory_1d(N, opts{l}, struct(), M); 
end

E = zeros(length(Js),M+1,length(files));

for k = 1:length(files)
	fprintf('%s\n',files{k});
	x = auread(files{k});
	x = x(1:N);
	x = x-mean(x);
	x = x/sqrt(sum(abs(x(:)).^2));
	for l = 1:length(Js)
		[t,meta] = format_scat(scat(x,cascade{l}));
		
		t = squeeze(t);
		for m = 0:max(meta.order)
			t1 = t(:,meta.order==m);
			E(l,m+1,k) = sum(abs(t1(:)).^2);
		end
	end
end
