% example of unit test with matlab
classdef test_scat < matlab.unittest.TestCase
    methods(Test)
        function testArgs(testcase)
           x = rand(64, 64);
           Wop = wavelet_factory_2d_pyramid();
           [Sx, Ux] = scat(x, Wop);
           testcase.verifyEqual(numel(Sx), numel(Ux)); 
        end
    end
end