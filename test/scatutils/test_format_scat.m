% TEST_FORMAT_SCAT
%
% See also
%   FORMAT_SCAT

classdef test_format_scat < matlab.unittest.TestCase
    methods(Test)
        function testBasic(testcase)
            N = 65536;
            load handel;
            y = y(1:N);
            filt_opt = default_filter_options('audio', 4096);
            scat_opt.M = 2;
            [Wop, filters] = wavelet_factory_1d(N, filt_opt, scat_opt);
            S = scat(y, Wop);
            
            white_list = {'fmt'};
            values = {{'raw','table','order_table'}};
            type = {'d'};
            
            options = generate_random_options(white_list,type,values);
            fmt = options.fmt;
            
            [out,meta] = format_scat(S,fmt);
            [out_old,meta_old] = format_scat_old(S,fmt); % see below
            
            test_out = isequal(out,out_old);
            test_meta = isequal(meta,meta_old);
            assert(test_out&&test_meta,true);
        end
        
        function testIllegalArg(testcase)
            fmt = 'some_unknown_format';
            S = 'not_a_valid_scat';
            didError = 0;
            try
                [out,meta] = format_scat(S,fmt)
            catch
                didError = 1;
            end
            testcase.assertEqual(didError,1);
        end
        
        function [out,meta] = format_scat_old(X,fmt)
            if nargin < 2
                fmt = 'table';
            end
            
            if strcmp(fmt,'raw')
                out = X;
                meta = [];
            elseif strcmp(fmt,'table') || strcmp(fmt,'order_table')
                tables = {};
                metas = {};
                
                if strcmp(fmt,'table')
                    last = -1;
                    for m = 0:length(X)-1
                        if length(X{m+1}.signal) == 0
                            continue;
                        end
                        
                        if last == -1
                            last = m;
                            continue;
                        end
                        
                        if size(X{m+1}.signal{1},1) ~= size(X{last+1}.signal{1},1)
                            error(['To use ''table'' output format, all orders ' ...
                                'must be of the same resolution. Consider using ' ...
                                'the ''order_table'' output format.']);
                        end
                    end
                    
                    X = flatten_scat(X);
                end
                
                last = 0;
                for m = 0:length(X)-1
                    if length(X{m+1}.signal) == 0
                        tables{m+1} = [];
                    else
                        tables{m+1} = zeros( ...
                            [length(X{m+1}.signal) size(X{m+1}.signal{1})], ...
                            class(X{m+1}.signal{1}));
                        
                        for j1 = 0:length(X{m+1}.signal)-1
                            tables{m+1}(j1+1,1:numel(X{m+1}.signal{1})) = X{m+1}.signal{j1+1}(:);
                        end
                        
                        last = m;
                    end
                    
                    metas{m+1} = X{m+1}.meta;
                end
                
                if strcmp(fmt,'table')
                    out = tables{1};
                    meta = metas{1};
                else
                    out = tables;
                    meta = metas;
                end
            end
        end
    end
end