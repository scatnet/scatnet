function half_bb_length = support_bounding_box(filter_spatial, options)

%%
options.null = 1;
relative_error = getoptions(options, 'relative_error', 1E-2);

[N, M] = size(filter_spatial);

% energy
eng = abs(filter_spatial).^2;

% renormalize to sum 1
eng = eng./sum(eng(:));

% center 
N2 = floor((N-1)/2);
M2 = floor((M-1)/2);
up = 1:N2+1;
down = N:-1:N-N2+1;
left = 1:M2+1;
right = M:-1:M-M2+1;
eng_ctr = zeros(numel(up), numel(left));
eng_ctr(up, left)               = eng_ctr(up, left)               + eng(up, left);
eng_ctr(up, left(2:end))        = eng_ctr(up, left(2:end))        + eng(up, right);
eng_ctr(up(2:end), left)        = eng_ctr(up(2:end), left)        + eng(down, left);
eng_ctr(up(2:end), left(2:end)) = eng_ctr(up(2:end), left(2:end)) + eng(down, right);

% cumulative sum
eng_ctr_cs = cumsum(cumsum(eng_ctr,1),2);

% extract diag
eng_ctr_cs_diag = diag(eng_ctr_cs);

% find first
half_bb_length = find(eng_ctr_cs_diag> 1-relative_error, 1, 'first');

