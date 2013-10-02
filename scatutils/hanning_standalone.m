% HANNING_STANDALONE Hanning window.
%
% Usage
%    window = HANNING_STANDALONE(window_length)
%
% Input
%    window_length (integer): length of the desired window.
%
% Output
%    window (numeric): Hanning window vector
%
% Description
%    This function generates a symmetric Hanning window of arbitrary
%    length, not including the first and last zero-weighted samples.

function window = hanning_standalone(window_length)
    oddity = rem(window_length,2);
	half_length = (window_length+oddity)/2;
	half_window = 0.5 * (1-cos(2*pi*(1:half_length)'/(window_length+1)));
    window = [half_window; half_window(end-oddity:-1:1)];
end

