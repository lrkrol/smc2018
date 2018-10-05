function classcorrelation = get_classcorrelation_chans(EEG, targetmarkers, timewindows)

features = get_features_windowedmeans(EEG, targetmarkers, timewindows);

% getting target labels for class-correlation measure
targetidx = ismember({EEG.event.type}, targetmarkers);
target = double(ismember({EEG.event(targetidx).type}, targetmarkers(1)));
target(~target) = -1;

% getting class-correlation measure per channel and time window
classcorrelation = nan(size(features, 1), size(timewindows, 1));
for w = 1:size(timewindows, 1)
    for c = 1:size(features, 1)
        x = corrcoef(target, features(c,w,:));
        classcorrelation(c,w) = abs(x(1,2));
    end
end

end