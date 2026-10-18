function drawSkeleton2D(points2D)
% this func draws the 12 projected body joints as a skeleton.
%
% input:
%   points2D - 12-by-2 array containing [x y] pixel coordinates

    if size(points2D, 1) ~= 12 || size(points2D, 2) ~= 2
        error('points2D must be a 12-by-2 array.');
    end

    % joint pairs
    connections = [
        1  2;   % R shoulder to R elbow
        2  3;   % R elbow to R wrist

        4  5;   % L shoulder to L elbow
        5  6;   % L elbow to L wrist

        7  8;   % R hip to R knee
        8  9;   % R knee to R ankle

        10 11;  % L hip to L knee
        11 12;  % L knee to L ankle

        1  4;   % R shoulder to L shoulder
        7 10    % R hip to L hip
    ];

    hold on;

    % draw the regular joint connections
    for i = 1:size(connections, 1)
        joint1 = connections(i, 1);
        joint2 = connections(i, 2);

        plot( ...
            [points2D(joint1, 1), points2D(joint2, 1)], ...
            [points2D(joint1, 2), points2D(joint2, 2)], ...
            'r-', 'LineWidth', 2);
    end

    % compute the shoulder and hip midpoints for the spine
    shoulderMidpoint = ...
        (points2D(1, :) + points2D(4, :)) / 2;

    hipMidpoint = ...
        (points2D(7, :) + points2D(10, :)) / 2;

    % draw the spine
    plot( ...
        [shoulderMidpoint(1), hipMidpoint(1)], ...
        [shoulderMidpoint(2), hipMidpoint(2)], ...
        'r-', 'LineWidth', 2);

    % draw the joints on top of the lines
    plot(points2D(:, 1), points2D(:, 2), ...
        'ro', ...
        'MarkerSize', 6, ...
        'MarkerFaceColor', 'r');
end