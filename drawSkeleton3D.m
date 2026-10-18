function lineHandle = drawSkeleton3D( ...
    points3D, lineColor, lineStyle, markerStyle)
% this func draws a 12-joint skeleton in 3D.
%
% inputs:
%   points3D    - 12-by-3 array of [X Y Z] coordinates
%   lineColor   - plot color, such as 'b' or 'r'
%   lineStyle   - line style, such as '-' or '--'
%   markerStyle - marker style, such as 'o' or 'x'
%
% output:
%   lineHandle - handle used for the plot legend

    if size(points3D, 1) ~= 12 || size(points3D, 2) ~= 3
        error('points3D must be a 12-by-3 array.');
    end

    connections = [
        1  2;
        2  3;

        4  5;
        5  6;

        7  8;
        8  9;

        10 11;
        11 12;

        1  4;
        7 10
    ];

    xLines = [];
    yLines = [];
    zLines = [];

    for i = 1:size(connections, 1)
        joint1 = connections(i, 1);
        joint2 = connections(i, 2);

        xLines = [xLines, ...
            points3D(joint1, 1), points3D(joint2, 1), NaN];

        yLines = [yLines, ...
            points3D(joint1, 2), points3D(joint2, 2), NaN];

        zLines = [zLines, ...
            points3D(joint1, 3), points3D(joint2, 3), NaN];
    end

    % midpoints used for the spine
    shoulderMidpoint = ...
        (points3D(1, :) + points3D(4, :)) / 2;

    hipMidpoint = ...
        (points3D(7, :) + points3D(10, :)) / 2;

    xLines = [xLines, ...
        shoulderMidpoint(1), hipMidpoint(1), NaN];

    yLines = [yLines, ...
        shoulderMidpoint(2), hipMidpoint(2), NaN];

    zLines = [zLines, ...
        shoulderMidpoint(3), hipMidpoint(3), NaN];

    hold on;

    lineHandle = plot3( ...
        xLines, yLines, zLines, ...
        'Color', lineColor, ...
        'LineStyle', lineStyle, ...
        'LineWidth', 2);

    plot3( ...
        points3D(:, 1), ...
        points3D(:, 2), ...
        points3D(:, 3), ...
        'LineStyle', 'none', ...
        'Marker', markerStyle, ...
        'MarkerEdgeColor', lineColor, ...
        'MarkerSize', 7, ...
        'LineWidth', 1.5, ...
        'HandleVisibility', 'off');
end