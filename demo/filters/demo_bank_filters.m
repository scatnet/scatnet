%% Creating a bank filter
% In this demo, we will show how to build bank filter in spatial domain or
% Fourier domain.
%
%% Reviewed functions
% The following function will be demonstrated:
%%
% 
% # haar_filter_bank_2d_pyramid
% # morlet_filter_bank_2d
% # morlet_filter_bank_2d_pyramid
%
%% Demonstration
%
% Here are shown 4 examples of filters:

x = mandrill;
filters1=morlet_filter_bank_2d(size(x));
filters2=morlet_filter_bank_2d_pyramid();
filters3=haar_filter_bank_2d_pyramid();

% Then one can access to the filters(low-pass and high-pass) by accessing 
% the fields of
filters1
filters2
filters3
