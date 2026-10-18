function [points3D, rayGaps] = myTriangulateRays( ...
    center1, directions1, center2, directions2)
% this func reconstructs 3D points from corresponding viewing rays.
%
% inputs:
%   center1     - 1-by-3 center of cam 1
%   directions1 - N-by-3 unit ray directions from cam 1
%   center2     - 1-by-3 center of cam 2
%   directions2 - N-by-3 unit ray directions from cam 2
%
% outputs:
%   points3D - N-by-3 reconstructed 3D points
%   rayGaps  - N-by-1 distance between the closest points on the rays

    if size(directions1, 2) ~= 3 || size(directions2, 2) ~= 3
        error('Ray directions must be N-by-3 arrays.');
    end

    if size(directions1, 1) ~= size(directions2, 1)
        error('The two cameras must have the same number of rays.');
    end

    center1 = center1(:)';
    center2 = center2(:)';

    numPoints = size(directions1, 1);

    points3D = zeros(numPoints, 3);
    rayGaps = zeros(numPoints, 1);

    for i = 1:numPoints
        direction1 = directions1(i, :)';
        direction2 = directions2(i, :)';

        % distances along the 2 rays that produce
        % their closest pair of 3D points.
        A = [direction1, -direction2];
        b = (center2 - center1)';

        distances = A \ b;

        closestPoint1 = center1 + ...
            distances(1) * direction1';

        closestPoint2 = center2 + ...
            distances(2) * direction2';

        % use the midpoint between the 2 closest points
        points3D(i, :) = ...
            (closestPoint1 + closestPoint2) / 2;

        rayGaps(i) = norm(closestPoint1 - closestPoint2);
    end
end