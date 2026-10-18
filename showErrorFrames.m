function showErrorFrames(mocapJoints, vue2, vue4, results)
% this func displays the min- & max-error frames.
% each row shows vue2, vue4, & the 3D reconstruction.

    frameNumbers = [
        results.minimumErrorFrame
        results.maximumErrorFrame
    ];

    frameLabels = {
        'Minimum Error'
        'Maximum Error'
    };

    vue2video = VideoReader( ...
        'Subject4-Session3-24form-Full-Take4-Vue2.mp4');

    vue4video = VideoReader( ...
        'Subject4-Session3-24form-Full-Take4-Vue4.mp4');

    figure('Position', [100, 100, 1500, 800]);

    tiledlayout(2, 3, ...
        'TileSpacing', 'compact', ...
        'Padding', 'compact');

    for k = 1:2
        frameNumber = frameNumbers(k);

        % locate this frame inside the valid-frame results
        resultIndex = find( ...
            results.validFrames == frameNumber, 1);

        original3D = squeeze( ...
            mocapJoints(frameNumber, :, 1:3));

        reconstructed3D = squeeze( ...
            results.reconstructedJoints(resultIndex, :, :));

        % project the joints into both images
        pointsVue2 = myProjectPoints(original3D, vue2);
        pointsVue4 = myProjectPoints(original3D, vue4);

        % read the corresponding video frames
        videoTime = (frameNumber - 1) / 100;

        vue2video.CurrentTime = videoTime;
        vid2Frame = readFrame(vue2video);

        vue4video.CurrentTime = videoTime;
        vid4Frame = readFrame(vue4video);

        % vue2 projection
        nexttile;
        image(vid2Frame);
        axis image;
        hold on;
        drawSkeleton2D(pointsVue2);

        title(sprintf('%s: Vue2 — Frame %d', ...
            frameLabels{k}, frameNumber));

        % vue4 projection
        nexttile;
        image(vid4Frame);
        axis image;
        hold on;
        drawSkeleton2D(pointsVue4);

        title(sprintf('%s: Vue4 — Frame %d', ...
            frameLabels{k}, frameNumber));

        % OG & reconstructed 3D skeletons
        nexttile;
        hold on;

        originalHandle = drawSkeleton3D( ...
            original3D, 'b', '-', 'o');

        reconstructedHandle = drawSkeleton3D( ...
            reconstructed3D, 'r', '--', 'x');

        xlabel('World X');
        ylabel('World Y');
        zlabel('World Z');

        title(sprintf('Error: %.2e', ...
            results.totalError(resultIndex)));

        grid on;
        axis equal;
        view(3);

        if k == 1
            legend( ...
                [originalHandle, reconstructedHandle], ...
                {'Original', 'Reconstructed'}, ...
                'Location', 'best');
        end
    end

    sgtitle('Minimum- and Maximum-Error Reconstruction Frames');
end