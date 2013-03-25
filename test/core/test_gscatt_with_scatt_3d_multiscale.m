x = uiuc_sample;


clear options;
options.L = 8;
options.J = 5;
L = options.L;
J = options.J;


% compute propagators
propagators = propagators_builder_3d_multiscale(size(x), options);

% compute scattering
[S, U] = gscatt(x, propagators);

% assert correct number of coefficients
number_of_order_1 = J;

assert(numel(S{2}.sig) == number_of_order_1);

number_of_order_2_psipsi = J*(J-1)/2 * L * 3;
number_of_order_2_psiphi = J*(J-1)/2 * L ;
number_of_order_2_phipsi = J*3;

number_of_order_2 = number_of_order_2_psipsi + ...
  number_of_order_2_psiphi + ...
  number_of_order_2_phipsi;

assert(numel(S{3}.sig) == number_of_order_2);