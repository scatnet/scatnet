% TEST_CONV_SUB_1D Test case for CONV_SUB_1D
%
% See also
%   CONV_SUB_2D, WAVELET_1D

classdef test_conv_sub_1d < matlab.unittest.TestCase
    methods (Test)
        function testBasic(testcase)
            jsig = 14;
            sig_length = 2^jsig;
            load handel;
            x = y(1:sig_length);
            xf = fft(x);
            ds = randi(jsig)-1;
            
            white_list = {'filter_format'};
            type = {'d'};
            values = ...
                {{'fourier','fourier_multires','fourier_truncated'}};
            
            filt_opt = generate_random_options(white_list,type,values)
            filters = morlet_filter_bank_1d(sig_length,filt_opt);
            filter = filters.psi.filter{randi(jsig-ds)};
            
            for j=1:jsig
                y_old = old_conv_sub_1d(xf,filter,ds); % see below
                y = conv_sub_1d(xf,filter,ds);
                difference = norm(y_old-y)
                is_different = round(10^13*difference);
                assert(is_different==false);
            end
        end
    end
end