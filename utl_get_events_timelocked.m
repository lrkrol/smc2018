
function events = get_events_timelocked(EEG)

firsteventlatency = EEG.srate * abs(EEG.xmin) + 1;

events = {};
latencies = [];
for e = 1:length(EEG.event)
    if mod(EEG.event(e).latency, size(EEG.data, 2)) == firsteventlatency
        events = [events, {EEG.event(e).type}];
        idx = find(latencies == EEG.event(e).latency);
        if idx
            fprintf('event %s and %s occur at the same time at sample %d', EEG.event(e).type, events{idx}, EEG.event(e).latency);
        end
        latencies = [latencies, EEG.event(e).latency];
    end
end

events = unique(events);

end
