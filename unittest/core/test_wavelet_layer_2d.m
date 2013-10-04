% TEST_WAVELET_LAYER_2D Test case for WAVELET_LAYER_2D
%
% See also
%   WAVELET_LAYER_2D
classdef test_wavelet_layer_2d < matlab.unittest.TestCase
    methods(Test)
        
        function testWithNoOptions(testcase)
            %% define
            x = rand(64, 64);
            filters = morlet_filter_bank_2d(size(x));
            U{1}.signal{1} = x;
            U{1}.meta.j = zeros(0,1);
            U{1}.meta.q = zeros(0,1);
            U{1}.meta.resolution=0;
            
            %% with no options
            [A, V] = wavelet_layer_2d(U{1}, filters);
            
            %% check number of high pass filter
            J = filters.meta.J;
            L = filters.meta.L;
            Q = filters.meta.Q;
            expected = J*L*Q;
            actual = numel(V.signal);
            
            %% assert
            testcase.assertEqual(expected, actual);
            
        end
        
        
        function testWithRandomOptions(testcase)
            for i = 1:32
                %%
                sz = 1 + floor(128*rand(1,2));
                %% define
                white_list={'x_resolution','oversampling'};
                type={'d','d'};
                values={{1,2,4,8,16},{0,1}};
                
                options_W = generate_random_options(white_list,type,values);
                
                white_list = {'Q', 'L', 'J'};
                type={'d','d','d'};
                values={{1,16},{1,16},{1,16}};
                
                options_B = generate_random_options(white_list,type,values);
                
                x = rand(sz);
                filters = morlet_filter_bank_2d(sz,options_B);
                U{1}.signal{1} = x;
                U{1}.meta.j = zeros(0,1);
                U{1}.meta.q = zeros(0,1);
                U{1}.meta.resolution=0;
                
                %% with no options
                [A, V] = wavelet_layer_2d(U{1}, filters,options_W);
                
                %% check number of high pass filter
                J = filters.meta.J;
                L = filters.meta.L;
                Q = filters.meta.Q;
                expected = J*L*Q;
                
                actual = numel(V.signal);
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
                filters = morlet_filter_bank_2d(sz);
                U{1}.signal{1} = x;
                U{1}.meta.j = zeros(0,1);
                U{1}.meta.q = zeros(0,1);
                U{1}.meta.resolution=0;
                
                %% with no options
                [A, V] = wavelet_layer_2d(U{1}, filters);
                
                %% check number of high pass filter
                J = filters.meta.J;
                L = filters.meta.L;
                Q = filters.meta.Q;
                expected = J*L*Q;
                
                actual = numel(V.signal);
                %% assert
                testcase.assertEqual(expected, actual);
                
            end
            
        end
    end
end