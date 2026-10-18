function [cameraCenter, rayDirections] = myPixelToRay(points2D, camera)
% this func converts 2D pixel coordinates into 3D viewing rays.
%
% inputs:
%   points2D - N-by-2 array of [u v] pixel coordinates
%   camera   - cam calibration structure
%
% outputs:
%   cameraCenter - 1-by-3 cam position in world coordinates
%   rayDirections - N-by-3 unit direction vectors in world coordinates

    if size(points2D, 2) ~= 2
        error('points2D must be an N-by-2 array.');
    end

    numPoints = size(points2D, 1);

    % pixel coordinates to homogeneous coordinates
    pixelsH = [points2D, ones(numPoints, 1)]';

    % pixels into directions in the cam coordinate system
    directionsCamera = camera.Kmat \ pixelsH;

    % rotate the directions from cam coordinates to world coordinates
    directionsWorld = camera.Rmat' * directionsCamera;

    % normalize each direction so it has length 1
    directionsWorld = directionsWorld ./ ...
        vecnorm(directionsWorld, 2, 1);

    rayDirections = directionsWorld';

    % cam center in world coordinates
    cameraCenter = camera.position(:)';
end