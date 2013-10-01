% TEST_MORLET_FILTER_BANK_2D_PYRAMID Test case for MORLET_FILTER_BANK_2D_PYRAMID
%
% See also
%   MORLET_FILTER_BANK_2D_PYRAMID
classdef test_morlet_filter_bank_2d_pyramid < matlab.unittest.TestCase
    methods(Test)
        function testWithNoOptions(testcase)
            %% define
            filters = morlet_filter_bank_2d_pyramid();
            
            expected=8;
            actual=length(filters.g.filter);
            
            %% assert
            testcase.assertEqual(expected, actual);
        end
    end
end