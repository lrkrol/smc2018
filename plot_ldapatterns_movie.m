
function plot_ldapatterns_movie(ldapatterns, chanlocs, varargin)

% parsing input
p = inputParser;

addRequired(p, 'ldapatterns', @isnumeric);
addRequired(p, 'chanlocs', @isstruct);

addOptional(p, 'showcolorbar', 1, @isnumeric);
addOptional(p, 'maxscale', 1, @isnumeric);
addOptional(p, 'timewindows', 0, @isnumeric);
addOptional(p, 'moviefilename', 'movie.avi', @ischar);
addOptional(p, 'framerate', 2, @isnumeric);
addOptional(p, 'playback', 0, @isnumeric);

parse(p, ldapatterns, chanlocs, varargin{:})

ldapatterns = p.Results.ldapatterns;
chanlocs = p.Results.chanlocs;
showcolorbar = p.Results.showcolorbar;
maxscale = p.Results.maxscale;
timewindows = p.Results.timewindows;
moviefilename = p.Results.moviefilename;
framerate = p.Results.framerate;
playback = p.Results.playback;

% mean patterns across participants
ldapatterns = mean(ldapatterns, 3);

fprintf('Rendering frames');
for w = 1:size(ldapatterns, 2)
    fprintf('.');
    h = figure('Visible', 'Off');
    if maxscale
        evalc('topoplot(ldapatterns(:,w), chanlocs, ''maplimits'', [min(ldapatterns(:)), max(ldapatterns(:))], ''shading'', ''interp'');');
    else
        evalc('topoplot(ldapatterns(:,w), chanlocs, ''shading'', ''interp'');');
    end
    if timewindows, title(sprintf('%d - %d ms', timewindows(w,1) * 1000, timewindows(w,2) * 1000)); end
    if showcolorbar, colorbar; end
    mov(w) = getframe(h);
    close(h);
end
fprintf('\n');

% adding blank frames
mov(end+1) = mov(end);
mov(end).cdata(:,:,1) = .93 * 255;
mov(end).cdata(:,:,2) = .96 * 255;
mov(end).cdata(:,:,3) = 255;
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