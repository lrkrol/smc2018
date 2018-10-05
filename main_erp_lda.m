
evaluation = 11;
subjects = 1:10;

starttime = .1;
windowlength = .1;
endtime = .7;
timewindows = [starttime:windowlength:endtime-windowlength; starttime+windowlength:windowlength:endtime]';
targetmarkers = {'event1', 'event2'};

for e = evaluation
    moviefilename = ['simulated-' num2str(e) '-erp-lda'];

    alldipoles = [];
    allweights = [];
    allpatterns = [];
    for s = subjects
        % loading data
        EEG = pop_loadset(sprintf('%d.set', s), fullfile('..\data\erp\simulated', num2str(e), num2str(s)));

        % getting LDA patterns
        features1 = get_features_windowedmeans(EEG, targetmarkers(1), timewindows);
        features2 = get_features_windowedmeans(EEG, targetmarkers(2), timewindows);
        features1 = reshape(features1, [], size(features1, 3))';
        features2 = reshape(features2, [], size(features2, 3))';
        [W, B, class_stats, sh_par] = lda_train_LW([features1; features2], [zeros(1, size(features1, 1)), ones(1, size(features2, 1))], 'LW');
        ldapatterns = reshape(class_stats.Sigma * W, EEG.nbchan, []);
        
        % getting source dipole weights by projecting LDA weights through
        % ICA unmixing matrix
        weights = (EEG.icaweights * EEG.icasphere) * ldapatterns;
        weights = abs(weights);

        % normalizing across time windows
        weights = weights / sum(weights(:));

        % adding weights and dipole locations to final list
        allweights = [allweights; weights]; %#ok<AGROW>
        alldipoles = [alldipoles; get_dipoles(EEG)]; %#ok<AGROW>
        allpatterns(:,:,s) = ldapatterns; %#ok<SAGROW>
    end

    plot_weighteddipoledensity_movie(alldipoles, 'weights', allweights, 'moviefilename', moviefilename, 'playback', 1, 'timewindows', timewindows, 'maxscale', 1);

    plot_ldapatterns_movie(ldapatterns, EEG.chanlocs, 'moviefilename', [moviefilename '-patterns'], 'playback', 1);
end