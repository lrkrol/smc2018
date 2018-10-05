
% Example usage:
%       >> plot_weighteddipoledensity(randn(3,64), rand(1,64).^10);

function h = plot_weighteddipoledensity(dipoles, varargin)

% parsing input
p = inputParser;

addRequired(p, 'dipoles', @isnumeric);

addOptional(p, 'weights', ones(1,max(size(dipoles))), @isnumeric);
addOptional(p, 'kernel', 10, @isnumeric);
addOptional(p, 'cmax', 0, @isnumeric);
addOptional(p, 'timewindow', [], @isnumeric);
addOptional(p, 'plotfig', 1, @isnumeric);
addOptional(p, 'invisiblefig', 0, @isnumeric);
addOptional(p, 'savefilename', '', @ischar);

parse(p, dipoles, varargin{:})

dipoles = p.Results.dipoles;
weights = p.Results.weights;
kernel = p.Results.kernel;
cmax = p.Results.cmax;
timewindow = p.Results.timewindow;
plotfig = p.Results.plotfig;
invisiblefig = p.Results.invisiblefig;
savefilename = p.Results.savefilename;

% calling EEGLAB dipoledensityfunction for three views
h = figure('Visible', 'Off');
if isnumeric(h), handle = h; else handle = h.Number; end

command = '[dens3d, m] = dipoledensity(dipoles, ''weight'', weights, ''methodparam'', kernel, ''plot'', ''on'', ''plotargs'', {''mriview'', ''%s'', ''fighandle'', handle %s});';
if cmax, cmaxcommand = ', ''cmax'', cmax'; else cmaxcommand = ''; end

fprintf('Producing dipole density plots.');
evalc(sprintf(command, 'top', cmaxcommand));
top = frame2im(getframe(h)); 

fprintf('.');
evalc(sprintf(command, 'side', cmaxcommand));
side = frame2im(getframe(h)); 

fprintf('.');
evalc(sprintf(command, 'rear', cmaxcommand));
rear = frame2im(getframe(h)); 
close(h);
fprintf('\n');

color = [0 0 72/256];
h = figure('Visible', 'Off', 'Color', color, 'units', 'pixels', 'Position', [0, 0, size(top, 2), size(top, 1)]);
subplot(4,1,1:3);
sortedweights = sort(weights, 'descend');
plot(sortedweights, 'w');
title('\color{white}Dipole Weight Distribution');
set(gca, 'Color', color);
set(gca, 'XColor', 'w');
set(gca, 'YColor', 'w');
set(gca, 'ZColor', 'w');
subplot(4,1,4);
if ~isempty(timewindow), timewindowtext = sprintf('Time window: %d - %d ms.\n\n', round(timewindow(1) * 1000), round(timewindow(2) * 1000));
else, timewindowtext = ''; end
top5p = ceil(length(weights) * 0.05);
top5pweights = sum(sortedweights(1:top5p)) / sum(weights);
title(sprintf('\\color{white}%sTop 5%% of dipoles (%d) carry %2.2f%% of the weight. Kurtosis: %2.2f', timewindowtext, top5p, top5pweights*100, kurtosis(weights)), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'Position', [0 1]);
axis off
graph = frame2im(getframe(h)); 
close(h);

if ~all(size(graph) == size(top))
    warning('additional info graph was not generated in the correct size (MATLAB version issue); leaving it out');
    graph = zeros(size(top));
    graph(:,:,3) = 72;
end

if plotfig
    % plotting composite image
    if invisiblefig
        h = figure('Visible', 'Off');
    else
        h = figure;
    end
    
    image([graph, top; side, rear]);
    axis off
    set(gca, 'Position', [0 0 1 1]);
    truesize
else
    h = NaN;
end

if ~isempty(savefilename)
    % writing composite image
    imwrite([graph, top; side, rear], savefilename);
end

end