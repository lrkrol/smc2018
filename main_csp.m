
evaluation = 8;
subjects = 1:10;

for e = evaluation
    moviefilename = ['simulated-' num2str(e) '-csp'];
    
    alldipoles = [];
    allweightsc1 = [];
    allweightsc2 = [];
    allpatternsc1 = [];
    allpatternsc2 = [];
    for s = subjects
        % loading filtered data
        EEG = pop_loadset(sprintf('%d-filt.set', s), fullfile('..\data\csp\simulated\', num2str(e), num2str(s)));
        
        % epoching
        EEGc1 = pop_epoch(EEG, {'event1'}, [0 .8]);
        EEGc2 = pop_epoch(EEG, {'event2'}, [0 .8]);
        
        % performing CSP
            % getting data in required format
        input_data = {squeeze(num2cell(EEGc1.data, [1 2])), squeeze(num2cell(EEGc2.data, [1 2]))};
        
            % training csp
        [cspfilters, csppatterns] = csp_train(input_data, 2);        
        
            % getting csp features
        [featuresc1, featuresc2] = csp_filter(EEGc1.data, EEGc2.data, cspfilters);        
        
            % training lda on csp features
        [W, B, class_stats, sh_par] = lda_train_LW([featuresc1; featuresc2], [zeros(1, size(featuresc1, 1)), ones(1, size(featuresc2, 1))], 'LW');
        
        % getting LDA forward weights
        correctedW = class_stats.Sigma * W;
        
        % weighting CSP patterns with LDA forward weights 
        patterns = csppatterns .* abs(correctedW)';
        
        % getting source dipole weights by projecting patterns through
        % ICA unmixing matrix
        weights = (EEG.icaweights * EEG.icasphere) * patterns;
        weights = abs(weights);

        % normalizing across patterns
        weights = weights / sum(weights(:));
        
        % separating weights per class
        weightsc1 = weights(:, 1:size(weights, 2)/2);
        weightsc2 = weights(:, size(weights, 2)/2+1:end);
        
        % concatenating patterns
        weightsc1 = reshape(weightsc1, [], 1);
        weightsc2 = reshape(weightsc2, [], 1);

        % adding weights and dipole locations to final list
        allweightsc1 = [allweightsc1; weightsc1]; %#ok<AGROW>
        allweightsc2 = [allweightsc2; weightsc2]; %#ok<AGROW>
        alldipoles = [alldipoles; repmat(get_dipoles(EEG), size(weights, 2)/2, 1)]; %#ok<AGROW>
                        
        % separating patterns per class for later plotting of mean patterns
        patternsc1 = patterns(:, 1:size(patterns, 2)/2);
        patternsc2 = patterns(:, size(patterns, 2)/2+1:end);
        patternsc1 = mean(patternsc1, 2);
        patternsc2 = mean(patternsc2, 2);
        allpatternsc1(:,:,s) = patternsc1; %#ok<SAGROW>
        allpatternsc2(:,:,s) = patternsc2; %#ok<SAGROW>
    end

    plot_weighteddipoledensity(alldipoles, 'weights', allweightsc1);
    plot_weighteddipoledensity(alldipoles, 'weights', allweightsc2);
    
    plot_patterns([mean(allpatternsc1, 3), mean(allpatternsc2, 3)], EEG.chanlocs);
end

