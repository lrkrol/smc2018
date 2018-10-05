function ldapatterns = get_ldapatterns(EEG, ldaweights, targetmarkers, timewindows)

% channel features
chanfeatures = get_features_windowedmeans(EEG, targetmarkers, timewindows);

% covariance matrix over all features
featurecov = cov(reshape(chanfeatures, EEG.nbchan * size(timewindows, 1), [])');
ldapatterns =  reshape(featurecov * ldaweights', EEG.nbchan, []);

end