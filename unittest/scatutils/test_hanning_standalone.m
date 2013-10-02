% TEST_PHANNING_STANDALONE Test case for HANNING_STANDALONE
%
% See also
%   HANNING (Signal Processing Toolbox)

classdef test_hanning_standalone < matlab.unittest.TestCase
    methods (Test)
        function testBasic(testcase)
            maxLength = 8191;
            for window_length = 1:maxLength % lasts a few seconds
                hanning_old = hanning(window_length); % requires DSP toolbox
                hanning_new = hanning_standalone(window_length);
                testcase.assertEqual(all(hanning_old==hanning_new));
            end
        end
    end
end