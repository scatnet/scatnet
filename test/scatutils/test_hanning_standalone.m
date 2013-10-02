maxLength = 8191;

for window_length = 1:maxLength % lasts a few seconds
    hanning_old = hanning(window_length); % requires DSP toolbox
    hanning_new = hanning_standalone(window_length);
    assert(all(hanning_old==hanning_new));
end

disp('Test passed.');

tic;
hanning_old = hanning(window_length+1);
duration_old = toc;
tic;
hanning_new = hanning_standalone(window_length+1);
duration = toc;
fprintf('Length = %d ; speedup = %1.2f.\n', ...
    window_length+1,duration_old/duration);