function x_block = extract_block(x, nb_block)

[N, M] = size(x);

% assert that input's size is a multiple of nb_block
assert(mod(N,nb_block(1)) == 0);
assert(mod(M,nb_block(2)) == 0);

block_size = [N, M]./nb_block;
x_block = reshape(permute(reshape(x,...
  block_size(1), nb_block(1), block_size(2), nb_block(2)), [1 3 2 4]),...
  block_size(1), block_size(2), prod(nb_block));
