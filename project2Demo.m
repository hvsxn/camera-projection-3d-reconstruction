clear;
clc;
close all;

% motion-capture & cam calibration data
load('Subject4-Session3-Take4_mocapJoints.mat');
load('vue2CalibInfo.mat');
load('vue4CalibInfo.mat');

% display the variables loaded
whos

% display the size of the motion-capture dataset
[numFrames, numJoints, numValues] = size(mocapJoints);

fprintf('Number of frames: %d\n', numFrames);
fprintf('Number of joints: %d\n', numJoints);
fprintf('Values per joint: %d\n', numValues);

% find frames where all 12 joints got confidence = 1
validFrames = find(all(mocapJoints(:, :, 4) == 1, 2));

fprintf('Number of fully valid frames: %d\n', length(validFrames));
fprintf('First fully valid frame: %d\n', validFrames(1));

% display cam info
disp('Vue2 camera:');
disp(vue2);

disp('Vue4 camera:');
disp(vue4);

%% verify cam extrinsic matrices

expectedPmatVue2 = [ ...
    vue2.Rmat, -vue2.Rmat * vue2.position(:)];

expectedPmatVue4 = [ ...
    vue4.Rmat, -vue4.Rmat * vue4.position(:)];

vue2PmatDifference = norm( ...
    vue2.Pmat - expectedPmatVue2, 'fro');

vue4PmatDifference = norm( ...
    vue4.Pmat - expectedPmatVue4, 'fro');

fprintf('\nVue2 Pmat verification difference: %.12e\n', ...
    vue2PmatDifference);

fprintf('Vue4 Pmat verification difference: %.12e\n', ...
    vue4PmatDifference);

%% test forward projection on 1 valid frame

% use the 1st frame where all 12 joints are valid
mocapFnum = validFrames(1);

% extract the 12 original 3D joint locations
joints3D = squeeze(mocapJoints(mocapFnum, :, 1:3));

% project the same joints into both cam views
pointsVue2 = myProjectPoints(joints3D, vue2);
pointsVue4 = myProjectPoints(joints3D, vue4);

disp('Projected Vue2 points:');
disp(pointsVue2);

disp('Projected Vue4 points:');
disp(pointsVue4);

%% read the corresponding video frames

vue2video = VideoReader( ...
    'Subject4-Session3-24form-Full-Take4-Vue2.mp4');

vue4video = VideoReader( ...
    'Subject4-Session3-24form-Full-Take4-Vue4.mp4');

% mocap was recorded at 100 fps
videoTime = (mocapFnum - 1) / 100;

vue2video.CurrentTime = videoTime;
vid2Frame = readFrame(vue2video);

vue4video.CurrentTime = videoTime;
vid4Frame = readFrame(vue4video);

%% display projected joints over the videos

figure;

tiledlayout(1, 2);

nexttile;
image(vid2Frame);
axis image;
hold on;

drawSkeleton2D(pointsVue2);

title(['Vue2 — Mocap Frame ', num2str(mocapFnum)]);
xlabel('Pixel x');
ylabel('Pixel y');

nexttile;
image(vid4Frame);
axis image;
hold on;

drawSkeleton2D(pointsVue4);

title(['Vue4 — Mocap Frame ', num2str(mocapFnum)]);
xlabel('Pixel x');
ylabel('Pixel y');

%% test inverse projection

[centerVue2, raysVue2] = myPixelToRay(pointsVue2, vue2);
[centerVue4, raysVue4] = myPixelToRay(pointsVue4, vue4);

% true directions from each cam center to the OG 3D joints
trueDirectionsVue2 = joints3D - centerVue2;
trueDirectionsVue2 = trueDirectionsVue2 ./ ...
    vecnorm(trueDirectionsVue2, 2, 2);

trueDirectionsVue4 = joints3D - centerVue4;
trueDirectionsVue4 = trueDirectionsVue4 ./ ...
    vecnorm(trueDirectionsVue4, 2, 2);

% dot product should be very close to 1 when directions match
alignmentVue2 = sum(raysVue2 .* trueDirectionsVue2, 2);
alignmentVue4 = sum(raysVue4 .* trueDirectionsVue4, 2);

fprintf('\nSmallest Vue2 ray alignment: %.12f\n', ...
    min(alignmentVue2));

fprintf('Smallest Vue4 ray alignment: %.12f\n', ...
    min(alignmentVue4));

disp('Vue2 camera center:');
disp(centerVue2);

disp('Vue4 camera center:');
disp(centerVue4);

%% test 2-view triangulation

[reconstructed3D, rayGaps] = myTriangulateRays( ...
    centerVue2, raysVue2, centerVue4, raysVue4);

% L2 distance between each original & reconstructed joint
jointErrors = sqrt(sum( ...
    (joints3D - reconstructed3D).^2, 2));

disp('Original and reconstructed 3D joints:');
disp(table( ...
    joints3D(:, 1), joints3D(:, 2), joints3D(:, 3), ...
    reconstructed3D(:, 1), ...
    reconstructed3D(:, 2), ...
    reconstructed3D(:, 3), ...
    jointErrors, ...
    'VariableNames', { ...
    'OriginalX', 'OriginalY', 'OriginalZ', ...
    'RecoveredX', 'RecoveredY', 'RecoveredZ', ...
    'L2Error'}));

fprintf('\nMean reconstruction error: %.12e\n', ...
    mean(jointErrors));

fprintf('Maximum reconstruction error: %.12e\n', ...
    max(jointErrors));

fprintf('Maximum gap between rays: %.12e\n', ...
    max(rayGaps));

%% display OG & reconstructed 3D skeletons

figure;
hold on;

originalHandle = drawSkeleton3D( ...
    joints3D, 'b', '-', 'o');

reconstructedHandle = drawSkeleton3D( ...
    reconstructed3D, 'r', '--', 'x');

xlabel('World X');
ylabel('World Y');
zlabel('World Z');

title(['3D Reconstruction — Frame ', num2str(mocapFnum)]);

legend( ...
    [originalHandle, reconstructedHandle], ...
    {'Original', 'Reconstructed'}, ...
    'Location', 'best');

grid on;
axis equal;
view(3);

%% evaluate all valid mocap frames

results = evaluateReconstruction(mocapJoints, vue2, vue4);

format long e;
disp(results.statsTable);

fprintf('\nMinimum-total-error frame: %d\n', ...
    results.minimumErrorFrame);

fprintf('Minimum total error: %.12e\n', ...
    results.minimumTotalError);

fprintf('\nMaximum-total-error frame: %d\n', ...
    results.maximumErrorFrame);

fprintf('Maximum total error: %.12e\n', ...
    results.maximumTotalError);

format short;

%% plot total reconstruction error across the seq

figure;

plot(results.validFrames, results.totalError, ...
    'LineWidth', 1);

hold on;

plot(results.minimumErrorFrame, ...
    results.minimumTotalError, ...
    'go', 'MarkerFaceColor', 'g');

plot(results.maximumErrorFrame, ...
    results.maximumTotalError, ...
    'ro', 'MarkerFaceColor', 'r');

xlabel('Mocap Frame Number');
ylabel('Total L2 Error Across 12 Joints');

title('Total 3D Reconstruction Error by Frame');

legend( ...
    {'Total Error', 'Minimum', 'Maximum'}, ...
    'Location', 'best');

grid on;

%% display min- & max-error frames

showErrorFrames(mocapJoints, vue2, vue4, results);

%% display epipolar lines

showEpipolarLines(mocapJoints, vue2, vue4, 23743);

%% profile the full reconstruction evaluation

profile clear;
profile on;

profileResults = evaluateReconstruction( ...
    mocapJoints, vue2, vue4);

profile off;
profile viewer;