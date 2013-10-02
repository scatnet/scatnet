% TEST_HAAR_FILTER_BANK_2D_PYRAMID Test case for HAAR_FILTER_BANK_2D_PYRAMID
%
% See also
%   HAAR_FILTER_BANK_2D_PYRAMID
classdef test_haar_filter_bank_2d_pyramid < matlab.unittest.TestCase
    methods(Test)
        function testWithNoOptions(testcase)
            %% define
            filters = haar_filter_bank_2d_pyramid();
            
            expected=3;
            actual=length(filters.g.filter);
            
            %% assert
            testcase.assertEqual(expected, actual);
        end
    end
end