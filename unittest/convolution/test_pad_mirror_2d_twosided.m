% TEST_PAD_MIRROR_2D_TWOSIDED Test case for PAD_MIRROR_2D_TWOSIDED
%
% See also
%   PAD_MIRROR_2D_TWOSIDED
classdef test_pad_mirror_2d_twosided < matlab.unittest.TestCase
    methods(Test)
        
        function testBasic(testcase)
            %%
            x = rand(17,17);
            margins = [3, 3];
            x_paded = pad_mirror_2d_twosided(x, margins);
            %% Assert correct size
            actual = size(x_paded);
            expected = size(x) + 2 * margins;
            %%
            testcase.assertEqual(actual, expected);
        end
        
        
        function testIllegalArg(testcase)
            %% 
            x = rand(17,17);
            margins = 3;
            didError = 0;
            try 
               pad_mirror_2d_twosided(x, margins);
            catch
                didError = 1;
            end
            %%
            testcase.assertEqual(didError, 1);
        end
        
        function testSizeSmallerThanMargin(testcase)
            %%
            x  = rand(4,4);
            margins = [10, 10];
            x_paded = pad_mirror_2d_twosided(x, margins);
            %%
            
        end
    end
end