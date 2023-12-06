function data = create_fish_structure(rawdata,time,pks,plocs,bls,blocs,smoothSpeed,ifile,varargin)
%NB snoothSpeed is v_smoothSp if you are creating the structure for real
%fish, smoothSp if you are creating the structure for virtual fish

% ENSURE THAT ALL GLIDES WILL PRECEDE THEIR CORRESPONDING BOUT IN THE STRUCTURE:
if plocs(1)<blocs(1)
plocs(1) = [];
pks(1) = [];
end

%Information about glides (aligned to the previous corresponding peak):

%Index of when each belly happened
bellIdx = ismember(time,blocs);
data.gld.ts = time(bellIdx); %time of belly
data.gld.sp = -1*bls';

if isfield(rawdata,'real_fish_x')
    data.gld.x = rawdata.real_fish_x(bellIdx)';
end
if isfield(rawdata,'real_fish_y')
    data.gld.y = rawdata.real_fish_y(bellIdx)';
end
if isfield(rawdata,'real_fish_z')
    data.gld.z = rawdata.real_fish_z(bellIdx)';
end
data.gld.xdiff = data.gld.x-[NaN data.gld.x(1:end-1)];
data.gld.ydiff = data.gld.y-[NaN data.gld.y(1:end-1)];
data.gld.angle = atan2(data.gld.ydiff,data.gld.xdiff); % In radiants

data.gld.vsp = smoothSpeed(bellIdx)';
data.gld.vx = rawdata.osg_fish1_x(bellIdx)';
data.gld.vy = rawdata.osg_fish1_y(bellIdx)';
data.gld.vxdiff = data.gld.vx-[NaN data.gld.vx(1:end-1)];
data.gld.vydiff = data.gld.vy-[NaN data.gld.vy(1:end-1)];
data.gld.vangle = atan2(data.gld.vydiff,data.gld.vxdiff); % In radiants

if isfield(rawdata,'Stim_Flag')
    data.gld.stim = rawdata.Stim_Flag(bellIdx)';
end
if isfield(rawdata,'Flag_Pertubation')
    data.gld.perturbWind = rawdata.Flag_Pertubation(bellIdx)'; % all the bouts during the perturbation
    data.gld.perturb = [NaN,diff(data.gld.perturbWind)==1]; % first bout of the perturbation
    data.gld.perturbID = data.gld.perturb;
    data.gld.perturbID(data.gld.perturb==1) = 1:sum(data.gld.perturb==1);
end

%% Peaks
peakIdx = ismember(time,plocs);
%Store variables relative to real fish at peaks
data.brs.sp = pks'; %fish speed at peak (SMOOTHED!)
data.brs.ts = plocs'; %time stamp of peak

if isfield(rawdata,'real_fish_x')
    data.brs.x = rawdata.real_fish_x(peakIdx)';
end
if isfield(rawdata,'real_fish_y')
    data.brs.y = rawdata.real_fish_y(peakIdx)';
end
if isfield(rawdata,'real_fish_z')
    data.brs.z = rawdata.real_fish_z(peakIdx)';
end
data.brs.xdiff = data.brs.x-[NaN data.brs.x(1:end-1)];
data.brs.ydiff = data.brs.y-[NaN data.brs.y(1:end-1)];
data.brs.angle = atan2(data.brs.ydiff,data.brs.xdiff); %In radiants

data.brs.vsp = smoothSpeed(peakIdx)'; %virtual fish speed at real fish peaks
data.brs.vx = rawdata.osg_fish1_x(peakIdx)'; %fish x position
data.brs.vy = rawdata.osg_fish1_y(peakIdx)'; %fish y position
data.brs.vxdiff = data.brs.vx-[NaN data.brs.vx(1:end-1)];
data.brs.vydiff = data.brs.vy-[NaN data.brs.vy(1:end-1)];
data.brs.vangle = atan2(data.brs.vydiff,data.brs.vxdiff); %In radiants

if isfield(rawdata,'Stim_Flag')
    data.brs.stim = rawdata.Stim_Flag(peakIdx)';
end
if isfield(rawdata,'Flag_Pertubation')
    data.brs.perturbWind = rawdata.Flag_Pertubation(peakIdx)';
    data.brs.perturb = [NaN,diff(data.brs.perturbWind)==1];
    data.brs.perturbID = data.brs.perturb;
    data.brs.perturbID(data.brs.perturb==1) = 1:sum(data.brs.perturb==1);
end

%%  Align peaks to bellies
peakPerBells = histcounts(plocs,blocs);
temp_peakID = cumsum(peakPerBells)+1; % consider only the FIRST glide after a burst, in case there are more (very few it seems, see sanity check before)
peakID = [peakPerBells(1) temp_peakID(1:end-1)];
peakID(peakID==0) = []; % Remove from bellID the early trials in case there were no bellies there;
fnames = fieldnames(data.brs);
for ifield = 1:numel(fnames)
    data.brs.(fnames{ifield}) = [data.brs.(fnames{ifield})(peakID) NaN];    % Align each field to corresponding peaks (if there are more bellies per peak, keep only the last)
    data.brs.(fnames{ifield})(peakPerBells==0) = [];    % Remove where there was no glide
    %     data.gld.(fnames{ifield})(bellPerPeaks==0) = [];    % Insert NaN where there was no glide
end
data.brs.ibi = [diff(data.brs.ts) NaN]; %Inter Bout (Burst) Interval (bout duration)

data.brs.fish = repelem(ifile,numel(data.brs.x));

if nargin==9
    data.brs.sessCode = repelem(varargin{1},numel(data.brs.x));
end

%% Align bellies to peaks

bellPerPeaks = histcounts(data.gld.ts,data.brs.ts(1:end-1));
temp_bellID = cumsum(bellPerPeaks)+1; % consider only the FIRST glide after a burst, in case there are more (very few it seems, see sanity check before)
bellID = [bellPerPeaks(1) temp_bellID(1:end-1)];
bellID(bellID==0) = []; % Remove from bellID the early trials in case there were no bellies there;
fnames = fieldnames(data.gld);
for ifield = 1:numel(fnames)
    data.gld.(fnames{ifield}) = [data.gld.(fnames{ifield})(bellID) NaN(1,2)];    % Align each field to corresponding peaks (if there are more bellies per peak, keep only the last)
    data.gld.(fnames{ifield})(bellPerPeaks==0) = [];    % Remove where there was no glide
    % N.B. two nans are added because one value is lost in the binning
    % (outside the last bin), the other was lost in the binning of bursts
    % (see line 95, where I skip the last value because it is a nan)
end
data.gld.ibi = [diff(data.gld.ts) NaN];

data.gld.fish = repelem(ifile,numel(data.gld.x));
if nargin==9
    data.gld.sessCode = repelem(varargin{1},numel(data.brs.x));
end

end