% TEST_WAVELET_2D Test case for WAVELET_2D
%
% See also
%   WAVELET_2D
classdef test_wavelet_2d < matlab.unittest.TestCase
    methods(Test)
        
        function testWithNoOptions(testcase)
            %% define
            x = rand(64, 64);
            filters = morlet_filter_bank_2d(size(x));
            %% with no options
            [x_phi, x_psi] = ...
                wavelet_2d(x, filters);
            %% check number of high pass filter
            J = filters.meta.J;
            L = filters.meta.L;
            Q = filters.meta.Q;
            expected = J*L*Q;
            actual = numel(x_psi.signal);
            %% assert
            testcase.assertEqual(expected, actual);
            
        end
        
        function testWithRandomSize(testcase)
            for i = 1:32
                %%
                sz = 1 + floor(128*rand(1,2));            
                %% define
                x = rand(sz);
                filters = morlet_filter_bank_2d(sz);
                %% with no options
                [x_phi, x_psi] = ...
                    wavelet_2d(x, filters);
                %% check number of high pass filter
                 J = filters.meta.J;
                L = filters.meta.L;
                Q = filters.meta.Q;
                expected = J*L*Q;
                actual = numel(x_psi.signal);
                %% assert
                testcase.assertEqual(expected, actual);
                
            end
            
        end
    end
end