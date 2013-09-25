path = '/Users/laurentsifre/TooBigForDropbox/Databases/cifar-10/cifar-10-batches-mat/';

batchs = {'data_batch_1.mat', ...
	'data_batch_2.mat', ...
	'data_batch_3.mat', ...
	'data_batch_4.mat', ...
	'data_batch_5.mat', ...
	'test_batch.mat'};

batch = [path,batchs{1}];

load(batch);

%%
clear x
N = 256;
for i = 1:256
	tmp = data(i,:);
	tmp = single(reshape(tmp, [32, 32, 3]));
	tmp = 1/255*(0.3*tmp(:,:,1) + 0.59*tmp(:,:,2) + 0.11*tmp(:,:,3));
	x.signal{i} = rot90(tmp,3);
end

%%
options.J = 3;
Wop = wavelet_factory_3d_pyramid(options, options);

for i = 1:N
	scatt{i} = scat(x.signal{i}, Wop);
	fprintf('done with %d \n', i);
end
%%
for i = 1:N
	tmp = format_scat(scatt{i});
	tmp = reshape(tmp, [1, numel(tmp)]);
	scatt_vec(i,:) = tmp;
end
