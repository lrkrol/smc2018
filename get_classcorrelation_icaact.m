function classcorrelation = get_classcorrelation_icaact(EEG, targetmarkers, timewindows)

icafeatures = get_features_windowedmeans(EEG, targetmarkers, timewindows, 1);

% getting target labels for class-correlation measure
targetidx = ismember({EEG.event.type}, targetmarkers);
target = double(ismember({EEG.event(targetidx).type}, targetmarkers(1)));
target(~target) = -1;

% getting class-correlation measure per channel and time window
classcorrelation = nan(size(icafeatures, 1), size(timewindows, 1));
for w = 1:size(timewindows, 1)
    for c = 1:size(icafeatures, 1)
        x = corrcoef(target, icafeatures(c,w,:));
        classcorrelation(c,w) = abs(x(1,2));
    end
end

end