% TEST_T_TO_J Test case for T_TO_J
%

classdef test_T_to_J < matlab.unittest.TestCase
    methods (Test)
        function testBasic(testcase)
            T = 2^randi([8 14]);
            white_list = {'Q','B','phi_bw_multiplier'};
            type = {'i','i','i'};
            values = ...
                {{1,16},{1,16},{1,2}};
            filt_opt = generate_random_options(white_list,type,values);
            J = T_to_J(T,filt_opt);
            test_int = (mod(J,1)==0);
            test_positive = (J>0);
            testcase.assertEqual(test_int && test_positive,true);
            T_inv = 4*filt_opt.B/filt_opt.phi_bw_multiplier * ...
                2^((J-1)/filt_opt.Q);
            max_error = 2^(0.5/filt_opt.Q)-1;
            relative_error = (T-T_inv) / T;
            test_negligible = (abs(relative_error)<max_error);
            assert(test_negligible,true);
        end
    end
end

