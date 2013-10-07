% EXTRACT_BLOCK extract sub block of a 2d matrix
%
% Usage 
%   x_block = EXTRACT_BLOCK(x, nb_block)
%
% Input
%   x (numeric): the 2d input matrix
%   nb_block (2x1 int): the vertical and horizontal number of block
%
% Output
%   x_block (numeric): a 3d block matrix whos third dimension corresponds
%       to block index.
%
% Description 
%   Split a 2d matrix into blocks of the same dimension whose index
%   corresponds to third dimension of the output matrix. This is used
%   to compute the inverse fourier transform of a downsampled signal
%   by first periodizing the signal.
%
% Example
%   If x contains
%      1     5     9    13
%      2     6    10    14
%      3     7    11    15
%      4     8    12    16
%   then extract_block(x, [2, 2]) will return
%   ans(:,:,1) =
%      1     5
%      2     6
% 
%   ans(:,:,2) =
%      3     7
%      4     8
% 
%   ans(:,:,3) =
%      9    13
%     10    14
% 
%   ans(:,:,4) =
%     11    15
%     12    16
%
% See also
%   CONV_SUB_2D


function x_block = extract_block(x, nb_block)
	
	[N, M] = size(x);
	
	% assert that input's size is a multiple of nb_block
	assert(mod(N,nb_block(1)) == 0);
	assert(mod(M,nb_block(2)) == 0);
	
	block_size = [N, M]./nb_block;
	x_block = reshape(permute(reshape(x,...
		block_size(1), nb_block(1), block_size(2), nb_block(2)), [1 3 2 4]),...
		block_size(1), block_size(2), prod(nb_block));
end