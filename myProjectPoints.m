function points2D = myProjectPoints(points3D, camera)
% this func projects 3D world points into 2D pixel coordinates.
%
% inputs:
%   points3D - N-by-3 array of [X Y Z] world coordinates
%   camera   - cam calibration structure (vue2 or vue4)
%
% output:
%   points2D - N-by-2 array of [u v] pixel coordinates

    % check that the input contains 3 coordinates per point
    if size(points3D, 2) ~= 3
        error('points3D must be an N-by-3 array.');
    end

    numPoints = size(points3D, 1);

    % convert 3D points into homogeneous coordinates
    points3DH = [points3D, ones(numPoints, 1)]';

    % project world coordinates into homogeneous pixel coordinates
    projectedH = camera.Kmat * camera.Pmat * points3DH;

    % divide by the 3rd coordinate to get ordinary pixel coordinates
    u = projectedH(1, :) ./ projectedH(3, :);
    v = projectedH(2, :) ./ projectedH(3, :);

    points2D = [u', v'];
end