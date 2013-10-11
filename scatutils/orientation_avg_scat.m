% ORIENTATION_AVG_SCAT Average 2d scattering along orientations
%
% Usage
%   Sx_avg = orientation_avg_scat(Sx)
%
% Input
%   Sx (cell): the output of 2d scattering
%
% Output
%   Sx_avg (cell): the scattering averaged along its orientation parameter
%
% Description
%   Order 1 coefficient are average along there unique orientation
%   Order 2 coefficients have two orientation, theta1 and theta2. These are
%   averaged along constant theta1 - theta2 (modulo the number of
%   orientations).
%
% See also
%   SCAT, WAVELET_FACTORY_2D, WAVELET_FACTORY_2D_PYRAMID

function Sx_avg = orientation_avg_scat(Sx)
    Sx_avg{1} = Sx{1};
    for m = 2:numel(Sx)
        %% extract rotation orbit
        S = Sx{m};
        not_yet_in_an_orbit = ones(1, numel(S.signal));
        p2 = 1;
        for p = 1:numel(S.signal)
            if (not_yet_in_an_orbit(p))
                %% find the rotation orbit
                switch m
                    case 2
                        orbit = find(S.meta.j(1,p) == S.meta.j(1,:));
                    case 3
                        L = max(S.meta.theta(:));
                        orbit = find(S.meta.j(1,p) == S.meta.j(1,:) & ...
                            S.meta.j(2,p) == S.meta.j(2,:) & ...
                            (mod(S.meta.theta(2,p) - S.meta.theta(1,p), L) ==...
                            mod(S.meta.theta(2,:) - S.meta.theta(1,:), L)));
                    otherwise
                        error('not yet supported');
                end
                not_yet_in_an_orbit(orbit) = 0;
                for p_orb = 1:numel(orbit)
                    tmp(:, :, p_orb) = S.signal{orbit(p_orb)};
                end
                Sx_avg{m}.signal{p2} = sum(tmp, 3);
                switch m
                    case 2
                        Sx_avg{m}.meta.j(:,p2) = S.meta.j(:,orbit(1));
                    case 3
                        Sx_avg{m}.meta.j(:,p2) = S.meta.j(:,orbit(1));
                        Sx_avg{m}.meta.theta2(:,p2) = S.meta.theta(2, orbit(1));
                end
                p2 = p2 + 1;
            end
        end
    end
end
