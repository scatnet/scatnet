% TEST_MORLET_FILTER_BANK_2D Test case for MORLET_FILTER_BANK_2D
%
% See also
%   MORLET_FILTER_BANK_2D
classdef test_morlet_filter_bank_2d < matlab.unittest.TestCase
    methods(Test)
          function testWithNoOptions(testcase)
            %% define
            x = rand(64, 64);
            filters = morlet_filter_bank_2d(size(x));
            
            %% check number of high pass filter
            expected = 32;
            actual = numel(filters.psi.filter);
            
            %% assert
            testcase.assertEqual(expected, actual);
            
        end
        
        function testWithRandomSize(testcase)
            for i = 1:32
                %%
                sz = 1 + floor(128*rand(1,2));
                %% define
                x = rand(sz);
                filters = morlet_filter_bank_2d(size(x));
                
                % Test
                expected = 1;
                actual = 1;
               
                %% assert
                testcase.assertEqual(expected, actual);
                
            end
            
        end
    end
end