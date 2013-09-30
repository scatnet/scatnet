% TEST_PAD_MIRROR_2D_TWOSIDED Test case for PAD_MIRROR_2D_TWOSIDED
%
% See also
%   PAD_MIRROR_2D_TWOSIDED
classdef test_pad_mirror_2d_twosided < matlab.unittest.TestCase
    methods(Test)
        
        function testBasic(testcase)
            %%
            x = rand(17,17);
            P = 3;
            pad_mirror_2d_twosided(x,P)
            
            %% assert same size
            
            
        end
        
        
        function testIllegalArg(testcase)
            %%
            x = rand(17,17);
            P = 3;
            pad_mirror_2d_twosided(x,P)
            
            %% assert same size
            
            
        end
    end
end