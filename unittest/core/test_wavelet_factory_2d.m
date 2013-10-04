% TEST_WAVELET_FACTORY_2D Test case for WAVELET_FACTORY_2D
%
% See also
%   WAVELET_FACTORY_2D
classdef test_wavelet_factory_2d < matlab.unittest.TestCase
    methods(Test)
        
        function testWithNoOptions(testcase)
            %% define
            x = rand(64, 64);
            [Wop, filters] = wavelet_factory_2d(size(x));
            
            %% check number of high pass filter
            expected = 3;
            actual = numel(Wop);
            
            %% assert
            testcase.assertEqual(expected, actual);
            
        end
        
          function testWithRandomOptions(testcase)
            for i = 1:32
                %%
                sz = 1 + floor(128*rand(1,2));
                %% define
                white_list_filt = {'Q', 'J', 'L'};
                type={'d','d','d'};
                values={{1,2,4,8,16},{0,1},{1,10}};
                options_f = generate_random_options(white_list_filt,type,values);
                
                
                white_list_scat = { 'oversampling','M'};               
                type={'d','i'};
                values={{0,1},{1,3}};
                
                options_s = generate_random_options(white_list_scat,type,values);
                
                x = rand(64, 64);
                [Wop, filters] = wavelet_factory_2d(size(x),options_f,options_s);
            
                
                actual = length(Wop);
                expected = options_s.M;
                %% assert
                testcase.assertEqual(expected, actual);
            end
            
        end
        
        
        function testWithRandomSize(testcase)
            for i = 1:32
                %%
                sz = 1 + floor(128*rand(1,2));
                %% define
                x = rand(sz);
                [Wop, filters] = wavelet_factory_2d(size(x));
                
                % Test
                expected = 3;
                actual = numel(Wop);
               
                %% assert
                testcase.assertEqual(expected, actual);
                
            end
            for i = 1:32
                %%
                sz = 1 + floor(2*rand(1,2));
                %% define
                x = rand(sz);
                [Wop, filters] = wavelet_factory_2d(size(x));
                
                % Test
                expected = 3;
                actual = numel(Wop);
               
                %% assert
                testcase.assertEqual(expected, actual);
                
            end
    end
    end
end