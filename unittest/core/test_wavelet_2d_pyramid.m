% TEST_WAVELET_2D_PYRAMID Test case for WAVELET_2D_PYRAMID
%
% See also
%   WAVELET_2D_PYRAMID
classdef test_wavelet_2d_pyramid < matlab.unittest.TestCase
    methods(Test)
        
        function testWithNoOptions(testcase)
            %% define
            x = rand(64, 64);
            filters = morlet_filter_bank_2d_pyramid();
            %% with no options
            [x_phi, x_psi, out_options] = ...
                wavelet_2d_pyramid(x, filters);
            %% check number of high pass filter
            J = out_options.J;
            L = filters.meta.L;
            q_mask = out_options.q_mask;
            expected = J*L*sum(q_mask);
            actual = numel(x_psi.signal);
            %% assert
            testcase.assertEqual(expected, actual);
            
        end
        
        function testWithRandomSize(testcase)
            for i = 1:32
                %%
                sz = 1 + floor(128*rand(1,2))                
                %% define
                x = rand(sz);
                filters = morlet_filter_bank_2d_pyramid();
                %% with no options
                [x_phi, x_psi, out_options] = ...
                    wavelet_2d_pyramid(x, filters);
                %% check number of high pass filter
                J = out_options.J;
                L = filters.meta.L;
                q_mask = out_options.q_mask;
                expected = J*L*sum(q_mask);
                actual = numel(x_psi.signal);
                %% assert
                testcase.assertEqual(expected, actual);
                
            end
            
        end
    end
end