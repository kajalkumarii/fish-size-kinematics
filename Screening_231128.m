%% Load data
clear all,close all,clc
load('fishSizeKin_231128.mat')

%% Sanity checks
figure,hold on
histogram(fdata.gld.sp)
histogram(fdata.brs.sp)

figure,hold on
plot(fdata.gld.vx,fdata.gld.vy);
axis square

% Index only some specific stimuli:
fdata.gld.fstim = round(fdata.gld.stim-1,2);
allFlags = unique(round(fdata.gld.stim-1,2));
stims = allFlags(3:9); % Specify correct stimuli here
% stims = allFlags([3 4 5 7 8 9]); % Specify correct stimuli here

stimIdx = ismember(round(fdata.gld.stim-1,2),stims);
noCircIdx = not(fdata.gld.stim==2);
filterIdx = stimIdx & noCircIdx;

pts = -0.15:0.005:0.15;
% Compute density of VF:
N_VF = histcounts2(fdata.gld.vx(filterIdx), fdata.gld.vy(filterIdx), pts, pts);
% N_RF = histcounts2(RFx(:), RFy(:), pts, pts);
figure
subplot(1,2,1)
hist3([fdata.gld.vx(filterIdx)', fdata.gld.vy(filterIdx)'],[50 50])
% imagesc(pts,pts,(N_VF)')
colorbar
set(gca,'Ydir','normal')
xlim([-.18 .18])
ylim([-.18 .18])
axis square
title('Virtual fish')
% subplot(1,2,2)
% imagesc(pts,pts,N_RF')
% set(gca,'Ydir','normal')

subplot(1,2,2)
hist3([fdata.gld.x(filterIdx)', fdata.gld.y(filterIdx)'],[50 50])
% imagesc(pts,pts,(N_VF)')
colorbar
set(gca,'Ydir','normal')
xlim([-.18 .18])
ylim([-.18 .18])
axis square
title('Real fish')

%% Check the distribution of stimuli
figure
histogram(fdata.gld.fstim(filterIdx))

euclDist = @(RF,VF) sqrt((RF(:,1)-VF(:,1)).^2+(RF(:,2)-VF(:,2)).^2);

distanceStims = euclDist([fdata.gld.x(filterIdx)',fdata.gld.y(filterIdx)'],...
    [fdata.gld.vx(filterIdx)',fdata.gld.vy(filterIdx)']);
figure
histogram(distanceStims);

distanceOverall = euclDist([fdata.gld.x',fdata.gld.y'],[fdata.gld.vx',fdata.gld.vy']);
medStimDist = nan(numel(stims),1);
for istim = 1:numel(stims)
    stimIdx = fdata.gld.fstim==stims(istim) & filterIdx;
medStimDist(istim) = median(distanceOverall(stimIdx));
end
figure
plot(medStimDist)
