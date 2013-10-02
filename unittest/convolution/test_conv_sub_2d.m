% TEST_PAD_MIRROR_2D_TWOSIDED Test case for PAD_MIRROR_2D_TWOSIDED
%
% See also
%   PAD_MIRROR_2D_TWOSIDED
classdef test_conv_sub_2d < matlab.unittest.TestCase
    methods(Test)
        
        function testBasic(testcase)
            %%
            x = rand(17,17);
            psi.coefft = [1,2,3;4,5,6;7,8,9];
            psi.type = 'spatial_support';
            x_conv_psi = conv_sub_2d(x, psi, 0);
            
            %% assert same size
            
            
        end
    end
end