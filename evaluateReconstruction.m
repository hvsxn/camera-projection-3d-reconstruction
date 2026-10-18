function results = evaluateReconstruction(mocapJoints, camera1, camera2)
% this func evaluates reconstruction accuracy over every fully valid
% mocap frame.

    if size(mocapJoints, 2) ~= 12 || size(mocapJoints, 3) < 4
        error('mocapJoints must have size frames-by-12-by-4.');
    end

    validFrames = find(all(mocapJoints(:, :, 4) == 1, 2));

    numValidFrames = length(validFrames);
    numJoints = 12;

    jointErrors = zeros(numValidFrames, numJoints);
    reconstructedJoints = zeros(numValidFrames, numJoints, 3);

    for i = 1:numValidFrames
        frameNumber = validFrames(i);

        original3D = squeeze( ...
            mocapJoints(frameNumber, :, 1:3));

        pixels1 = myProjectPoints(original3D, camera1);
        pixels2 = myProjectPoints(original3D, camera2);

        [center1, rays1] = myPixelToRay(pixels1, camera1);
        [center2, rays2] = myPixelToRay(pixels2, camera2);

        reconstructed3D = myTriangulateRays( ...
            center1, rays1, center2, rays2);

        reconstructedJoints(i, :, :) = reconstructed3D;

        jointErrors(i, :) = sqrt(sum( ...
            (original3D - reconstructed3D).^2, 2))';

        if mod(i, 2500) == 0 || i == numValidFrames
            fprintf('Processed %d of %d valid frames\n', ...
                i, numValidFrames);
        end
    end

    totalError = sum(jointErrors, 2);

    jointNames = {
        'Right Shoulder'
        'Right Elbow'
        'Right Wrist'
        'Left Shoulder'
        'Left Elbow'
        'Left Wrist'
        'Right Hip'
        'Right Knee'
        'Right Ankle'
        'Left Hip'
        'Left Knee'
        'Left Ankle'
    };

    % 12 rows, 1 for each joint
    statistics = [
    mean(jointErrors, 1)', ...
    std(jointErrors, 0, 1)', ...
    min(jointErrors, [], 1)', ...
    median(jointErrors, 1)', ...
    max(jointErrors, [], 1)'
];

    % stats over every joint in every frame
    allErrors = jointErrors(:);

    overallStatistics = [
        mean(allErrors), ...
        std(allErrors), ...
        min(allErrors), ...
        median(allErrors), ...
        max(allErrors)
    ];

    statistics = [statistics; overallStatistics];

    rowNames = [jointNames; {'Overall'}];

    statsTable = array2table( ...
        statistics, ...
        'VariableNames', ...
        {'Mean', 'StandardDeviation', 'Minimum', 'Median', 'Maximum'}, ...
        'RowNames', rowNames);

    [minimumTotalError, minIndex] = min(totalError);
    [maximumTotalError, maxIndex] = max(totalError);

    results.validFrames = validFrames;
    results.jointErrors = jointErrors;
    results.totalError = totalError;
    results.reconstructedJoints = reconstructedJoints;
    results.statsTable = statsTable;

    results.minimumErrorFrame = validFrames(minIndex);
    results.maximumErrorFrame = validFrames(maxIndex);

    results.minimumTotalError = minimumTotalError;
    results.maximumTotalError = maximumTotalError;
end