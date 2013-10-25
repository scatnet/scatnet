% TEST_DISPLAY_FILTER_2D Test case for DISPLAY_FILTER_2D
%
% See also
%   DISPLAY_FILTER_2D
classdef test_display_filter_2d < matlab.unittest.TestCase
    methods(Test)
        function testWithNoOptions(testcase)
            x=mandrill;
            filters = morlet_filter_bank_2d(x);
            filter = filters.psi.filter{1};
            filt=filter.coefft{1};
            
            [H, W] = size(filt);
            n = 10;
            %% define
            filt = fftshift(ifft2(filt));
            expected = filt(floor(H/2)-n+1:floor(H/2)+n+1,floor(W/2)-n+1:floor(W/2)+n+1);
            
            actual=display_filter_2d(filter,'i',n);
            
            filters = morlet_filter_bank_2d_pyramid();
            filter=filters.g.filter{1};
            display_filter_2d(filter,'i');
            
            
            
            
            %% assert
            testcase.assertEqual(expected, actual);
        end
    end
end
