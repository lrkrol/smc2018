
evaluation = 11;
subjects = 1:10;

starttime = .1;
windowlength = .1;
endtime = .7;
timewindows = [starttime:windowlength:endtime-windowlength; starttime+windowlength:windowlength:endtime]';

targetmarkers = {'event1', 'event2'};

for e = evaluation
    moviefilename = ['simulated-' num2str(e) '-erp-corr'];

    alldipoles = [];
    allweights = [];
    allpatterns = [];
    for s = subjects
        % loading data
        EEG = pop_loadset(sprintf('%d.set', s), fullfile('..\data\erp\simulated', num2str(e), num2str(s)));

        % starting with all equal weights
        weights = ones(EEG.nbchan, size(timewindows, 1));

        % applying class-correlation correction on IC activations
        classcorrelation = get_classcorrelation_icaact(EEG, targetmarkers, timewindows);
        weights = weights .* classcorrelation;
        
        % normalizing across time windows
        weights = weights / sum(weights(:));

        % adding weights and dipole locations to final list
        allweights = [allweights; weights]; %#ok<AGROW>
        alldipoles = [alldipoles; get_dipoles(EEG)]; %#ok<AGROW>
        allpatterns(:,:,s) = ldapatterns; %#ok<SAGROW>
    end

    plot_weighteddipoledensity_movie(alldipoles, 'weights', allweights, 'moviefilename', moviefilename, 'playback', 1, 'timewindows', timewindows, 'maxscale', 1);
    % only time window 3:
    % plot_weighteddipoledensity(alldipoles, 'weights', allweights(:,3));
    plot_ldapatterns_movie(ldapatterns, EEG.chanlocs, 'moviefilename', [moviefilename '-patterns'], 'playback', 1);
end