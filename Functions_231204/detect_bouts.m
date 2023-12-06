function [pks,plocs,bls,blocs,smoothSp] = detect_bouts(rawx,rawy,dt,fs,smoothingWin,varargin)

% virtualF = 0;
% if nargin > 5
% virtualF = varargin{6};
% end
% 
% if virtualF == 1
% 
% else

%NB CHOOSE WHETHER TO USE THE Z DIMENSION OR NOT!!! ASK LIANG:
approxSp = sqrt((fivepoint(rawx,dt)).^2+(fivepoint(rawy,dt)).^2);%+(fivepoint(rawdata.z,dt)).^2);
% order = 2; framelen = 11;
% smoothSp = sgolayfilt(approxSp,order,framelen);
smoothSp = movmean(approxSp,smoothingWin);

% % Just for plotting:
% sampleIdx = 140000:150000; % 20000:30000
% figure,hold on
% plot((0:numel(sampleIdx)-1)/fs,smoothSp(sampleIdx))
% [bls,blocs] = findpeaks(-1*smoothSp(sampleIdx),100,'MinPeakDistance',0.2,'MinPeakProminence',0.025);
% [pks,plocs] = findpeaks(smoothSp(sampleIdx),100,'MinPeakDistance',0.2,'MinPeakProminence',0.025);
% xline(blocs,'g')
% xline(plocs,'r')

% Compute peaks for the full session:
[bls,blocs] = findpeaks(-1*smoothSp,100,'MinPeakDistance',0.2,'MinPeakProminence',0.025);
[pks,plocs] = findpeaks(smoothSp,100,'MinPeakDistance',0.2,'MinPeakProminence',0.025);

%Sanity check:
BperP = mean(histcounts(blocs,plocs));
disp(['Number of bellies per peak (quality test): ',num2str(mean(histcounts(blocs,plocs)))]); %Very good!!! Almost all inter-peak-intervals have one single belly
if BperP>1.01 | BperP<0.99
    warning('Anomalous number of bellies per peak. Check corresponding file')
    % Plot the problematic region:
    % figure,
    % plot(smoothSp)
end

%both sgolay and movmean lead to good result, though far from perfect:
%- There are very small bursts that are split as separate bouts (does it make
%sense? Ask Liang)
%- Also, there are relatively often (~1/10 by eye) glide phases that are
%split in multiple bouts, but they look as parts of the same bout. Ask
%Liang.

%25 May 2023
%Introduced MinPeakProminence at 0.02, it works well for both peaks
%and bellies, with movmean at 10 and sgolay, however still some
%mistakes with small peaks. With movmean at 20 it is better.
% Increased to MinPeakProminence 0.025, with movemean at 10 is very good.
%PEAKS APPEAR TO BE MUCH MORE RELIABLE THAN BELLIES

%Save peak speed, because sometimes when tracking is lost speed seems
%crazy, e.g. 0.3; we might need to filter out those trials
