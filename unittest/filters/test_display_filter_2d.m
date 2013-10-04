% TEST_DISPLAY_FILTER_2D Test case for DISPLAY_FILTER_2D
%
% See also
%   DISPLAY_FILTER_2D
classdef test_display_filter_2d < matlab.unittest.TestCase
    methods(Test)
        function testWithNoOptions(testcase)
            x=lena;
            filters = morlet_filter_bank_2d(x);
            filter = filters.psi.filter{1};
            
            [H, W] = size(filter.coefft{1});
            n = 10;
            %% define
            expected = (filt(floor(H/2)-n+1:floor(H/2)+n+1,floor(W/2)-n+1:floor(W/2)+n+1));
            
            actual=display_filter_2d(filter,'i',n);
            
            
            %% assert
            testcase.assertEqual(expected, actual);
        end
    end
end