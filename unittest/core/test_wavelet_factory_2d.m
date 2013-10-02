% TEST_WAVELET_FACTORY_2D Test case for WAVELET_FACTORY_2D
%
% See also
%   WAVELET_FACTORY_2D
classdef test_wavelet_factory_2d < matlab.unittest.TestCase
    methods(Test)
        
        function testWithNoOptions(testcase)
            %% define
            x = rand(64, 64);
            [Wop, filters] = wavelet_factory_2d(size(x));
            
            %% check number of high pass filter
            expected = 3;
            actual = numel(Wop);
            
            %% assert
            testcase.assertEqual(expected, actual);
            
        end
        
        function testWithRandomSize(testcase)
            for i = 1:32
                %%
                sz = 1 + floor(128*rand(1,2));
                %% define
                x = rand(sz);
                [Wop, filters] = wavelet_factory_2d(size(x));
                
                % Test
                expected = 3;
                actual = numel(Wop);
               
                %% assert
                testcase.assertEqual(expected, actual);
                
            end
            
        end
    end
end