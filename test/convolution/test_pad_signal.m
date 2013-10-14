Npad = 8;
N = 3;

x0 = randn(N,1);
x1 = pad_signal(x0, Npad, 'symm', 0);
x2 = x1(1:2:end,:);
x3 = unpad_signal(x2, 1, N, 0);
assert(norm(x0(1:2:end,:)-x3,'fro')<1e-14);

x0 = randn(N,2);
x1 = pad_signal(x0, Npad, 'symm', 0);
x2 = x1(1:2:end,:);
x3 = unpad_signal(x2, 1, N, 0);
assert(norm(x0(1:2:end,:)-x3,'fro')<1e-14);

x0 = randn(N,1);
x1 = pad_signal(x0, Npad, 'symm', 1);
x2 = x1(1:2:end,:);
x3 = unpad_signal(x2, 1, N, 1);
assert(norm(x0(1:2:end,:)-x3,'fro')<1e-14);

x0 = randn(N,2);
x1 = pad_signal(x0, Npad, 'symm', 1);
x2 = x1(1:2:end,:);
x3 = unpad_signal(x2, 1, N, 1);
assert(norm(x0(1:2:end,:)-x3,'fro')<1e-14);

Npad = [8 8];
N = [3 3];

x0 = randn(N);
x1 = pad_signal(x0, Npad, 'symm', 0);
x2 = x1(1:2:end,1:2:end,:);
x3 = unpad_signal(x2, 1, N, 0);
assert(norm(reshape(x0(1:2:end,1:2:end,:)-x3,[2*2*1 1]),'fro')<1e-14);

x0 = randn([N 2]);
x1 = pad_signal(x0, Npad, 'symm', 0);
x2 = x1(1:2:end,1:2:end,:);
x3 = unpad_signal(x2, 1, N, 0);
assert(norm(reshape(x0(1:2:end,1:2:end,:)-x3,[2*2*2 1]),'fro')<1e-14);

x0 = randn(N);
x1 = pad_signal(x0, Npad, 'symm', 1);
x2 = x1(1:2:end,1:2:end,:);
x3 = unpad_signal(x2, 1, N, 1);
assert(norm(reshape(x0(1:2:end,1:2:end,:)-x3,[2*2*1 1]),'fro')<1e-14);

x0 = randn([N 2]);
x1 = pad_signal(x0, Npad, 'symm', 1);
x2 = x1(1:2:end,1:2:end,:);
x3 = unpad_signal(x2, 1, N, 1);
assert(norm(reshape(x0(1:2:end,1:2:end,:)-x3,[2*2*2 1]),'fro')<1e-14);
