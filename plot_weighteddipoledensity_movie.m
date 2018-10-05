
function plot_weighteddipoledensity_movie(dipoles, varargin)

% parsing input
p = inputParser;

addRequired(p, 'dipoles', @isnumeric);

addOptional(p, 'weights', ones(1,max(size(dipoles))), @isnumeric);
addOptional(p, 'kernel', 10, @isnumeric);
addOptional(p, 'maxscale', 1, @isnumeric);
addOptional(p, 'timewindows', 0, @isnumeric);
addOptional(p, 'moviefilename', 'movie.avi', @ischar);
addOptional(p, 'framerate', 2, @isnumeric);
addOptional(p, 'playback', 0, @isnumeric);

parse(p, dipoles, varargin{:})

dipoles = p.Results.dipoles;
weights = p.Results.weights;
kernel = p.Results.kernel;
maxscale = p.Results.maxscale;
timewindows = p.Results.timewindows;
moviefilename = p.Results.moviefilename;
framerate = p.Results.framerate;
playback = p.Results.playback;

cmax = 0;
if maxscale
    % getting maximum density
    fprintf('Finding maximum density');
    for w = 1:size(weights, 2)
        fprintf('.');
        evalc('[dens3d, ~] = dipoledensity(dipoles, ''weight'', weights(:,w), ''methodparam'', kernel, ''plot'', ''off'');');
        dens3d = cell2mat(dens3d);
        wmax = max(dens3d(:));
        cmax = max([cmax, wmax]);
    end
    fprintf(' %f\n', cmax);
end

for w = 1:size(weights, 2)
    fprintf('Rendering movie frame %d of %d: ', w, size(weights, 2));
    h = plot_weighteddipoledensity(dipoles, 'weights', weights(:,w), 'kernel', kernel, 'plotfig', 1, 'invisiblefig', 1, 'savefilename', '', 'cmax', cmax, 'timewindow', timewindows(w,:));
    mov(w) = getframe(h);
end

% adding blank frames
mov(end+1) = mov(end);
mov(end).cdata(:,:,1:2) = 0;
mov(end).cdata(:,:,3) = 72;
mov(end+1) = mov(end);
mov(end+1) = mov(end);

fprintf('Writing movie... ');
v = VideoWriter(moviefilename, 'Uncompressed AVI');
v.FrameRate = framerate;
open(v);
writeVideo(v, mov);
close(v);
fprintf('Done.\n');

if playback
    system(moviefilename);
end

end