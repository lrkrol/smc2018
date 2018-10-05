
function dipoles = get_dipoles(EEG, varargin)

% parsing input
p = inputParser;

addRequired(p, 'EEG', @isstruct);

addOptional(p, 'maxrv', 1, @isnumeric);

parse(p, EEG, varargin{:})

EEG = p.Results.EEG;
maxrv = p.Results.maxrv;

% getting dipole array
if size([EEG.dipfit.model.posxyz], 1) > 1
    warning('EEG.dipfit.model.posxyz appears to contain more than one solution; taking first');
    for i = 1:length(EEG.dipfit.model)
        EEG.dipfit.model(i).posxyz = EEG.dipfit.model(i).posxyz(1,:);
    end
end
dipoles = reshape([EEG.dipfit.model.posxyz], 3, length(EEG.dipfit.model))';

% selection based on residual variance
    % todo: some rv are NaN
    %       selection must also apply to weights, must thus happen elsewhere
% rvidx = [EEG.dipfit.model.rv] < maxrv;
% dipoles = dipoles(rvidx,:);

end