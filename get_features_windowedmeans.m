
function features = get_features_windowedmeans(EEG, targetmarkers, timewindows, icaact)

if nargin < 4
    icaact = 0;
end

% extracting epochs
EEG = pop_epoch(EEG, targetmarkers, [timewindows(1), timewindows(end) + 1/EEG.srate]);

% transforming time windows into samples
timewindows = round((timewindows - EEG.xmin) * EEG.srate) + 1;

% extracting features
if icaact
    features = nan(size(EEG.icaact, 1), size(timewindows, 1), size(EEG.icaact, 3));
    for w = 1:size(timewindows, 1)
        features(:,w,:) = mean(EEG.icaact(:,timewindows(w,1):timewindows(w,2),:), 2);
    end
else
    features = nan(size(EEG.data, 1), size(timewindows, 1), size(EEG.data, 3));
    for w = 1:size(timewindows, 1)
        features(:,w,:) = mean(EEG.data(:,timewindows(w,1):timewindows(w,2),:), 2);
    end
end

end