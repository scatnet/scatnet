% TEST_aggregate_scat Test case for aggregate_scat
%
% See also
%   SCAT, FORMAT_SCAT

classdef test_aggregate_scat < matlab.unittest.TestCase
    methods (Test)
        function testBasic(testcase)
            N1=2^14;
            sig=rand(N1,1);
            filt_opt.filter_type = {'gabor_1d','morlet_1d'};
            filt_opt.Q = [1 1];
            filt_opt.J = T_to_J(2^10,filt_opt); %371.5 ms
            
            %% set the scattering options
            scat_opt = struct();
            scat_opt.M=2;
            scat_opt.oversampling=0;
            Wop=wavelet_factory_1d(N1,filt_opt,scat_opt);
            
            S=format_scat(scat(x,Wop));
            S_ag=format_scat(aggregate_scat(scat(x,Wop),2^11));
                testcase.assertEqual(size(S_ag,1)==2*size(S,1)); 
                testcase.assertEqual(size(S_ag,2)==0.5*size(S,2));
             
        
        end
    end
end
