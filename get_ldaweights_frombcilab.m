
function [ldaweights, stats, model] = get_ldaweights_frombcilab(EEG, approach, targetmarkers, varargin)

% parsing input
p = inputParser;

addRequired(p, 'EEG', @isstruct);
addRequired(p, 'approach', @iscell);
addRequired(p, 'targetmarkers', @iscell);

addOptional(p, 'scheme', {'chron', 5, 5}, @iscell);
addOptional(p, 'evaluate', 0, @isnumeric);

parse(p, EEG, approach, targetmarkers, varargin{:})

EEG = p.Results.EEG;
approach = p.Results.approach;
targetmarkers = p.Results.targetmarkers;
scheme = p.Results.scheme;
evaluate = p.Results.evaluate;

if evaluate
    evalscheme = scheme;
else
    evalscheme = 0;
end

if size(EEG.data, 3) > 1
    EEG = epoch2continuous(EEG);
end

EEG = exp_eval(set_targetmarkers(EEG, targetmarkers));
[~, model, stats] = bci_train('Data', EEG, 'Approach', approach, 'TargetMarkers', targetmarkers, 'EvaluationScheme', evalscheme, 'OptimizationScheme', scheme);

ldaweights = model.predictivemodel.model.w;
if evaluate
    stats = [stats.TP, stats.TN, 1-stats.mcr];
else
    stats = NaN;
end

cov = model.featuremodel.cov;

end