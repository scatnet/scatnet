% this script 
% 1 - evaluates speedup of fast index-based block extraction 
%   over naive loop approach
% 2 - verifies that the fast and naive approach give same results
x = uiuc_sample;

nb_iter = 100;

nb_block = [16, 8];
block_size = size(x)./nb_block;

%% fast index-based block extraction
tic;
for iter = 1:nb_iter
  x_blocks_fast = extract_block(x, nb_block);
end
toc;

%% naive loop
tic;
for iter = 1:nb_iter
  x_blocks_slow = zeros([block_size, prod(nb_block)]);
  k = 1;
  for j = 1:nb_block(2)
    for i = 1:nb_block(1)
      x_blocks_slow(:, :, k) = ...
        x( (1:block_size(1)) + block_size(1)*(i-1), ...
        (1:block_size(2)) + block_size(2)*(j-1) );
      k = k + 1;
    end
  end
end
toc;

%% assert equality
assert(norm(x_blocks_fast(:)-x_blocks_slow(:)) == 0)