% TEST_WAVELET_2D_PYRAMID Test case for WAVELET_2D_PYRAMID
%
% See also 
%   WAVELET_2D_PYRAMID
classdef test_wavelet_2d_pyramid < matlab.unittest.TestCase
    methods(Test)
        function testArgs(testcase)
           x = rand(64, 64);
           Wop = wavelet_factory_2d_spatial();
           [Sx, Ux] = scat(x, Wop);
           testcase.verifyEqual(numel(Sx), numel(Ux)); 
        end
    end
end