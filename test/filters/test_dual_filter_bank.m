filt_opt.J = 3;
filters1d = morlet_filter_bank_1d(32, filt_opt);
filters2d = morlet_filter_bank_2d([32 32], filt_opt);

dual_filters1d = dual_filter_bank(filters1d);
dual_filters2d = dual_filter_bank(filters2d);

filt_mult = @(x,y)(realize_filter(x).*realize_filter(y));

F = cellfun(filt_mult,filters1d.psi.filter,dual_filters1d.psi.filter, ...
	'UniformOutput',0);
F = reshape([F{:}],[size(F{1}) length(F)]);
Fp = feval(filt_mult, filters1d.phi.filter,dual_filters1d.phi.filter);
A = Fp+0.5*feval(@(x)(x+circshift(rot90(x,2),[1 1])),sum(F,3));
assert(norm(A-ones(size(A)),'fro')<1e-14);

F = cellfun(filt_mult,filters2d.psi.filter,dual_filters2d.psi.filter, ...
	'UniformOutput',0);
F = reshape([F{:}],[size(F{1}) length(F)]);
Fp = feval(filt_mult, filters2d.phi.filter,dual_filters2d.phi.filter);
A = Fp+0.5*feval(@(x)(x+circshift(rot90(x,2),[1 1])),sum(F,3));
assert(norm(A-ones(size(A)),'fro')<1e-14);