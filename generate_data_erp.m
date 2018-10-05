
%% config
epochs = struct('n', 100, 'srate', 100, 'length', 800);
lf = lf_generate_fromnyhead('montage', 'S64');
subjects = 1:10;
savedir = 'D:\TUB\088 wDD\data\erp\simulated\';

noise = utl_check_class(struct( ...
        'type', 'noise', ...
        'color', 'brown', ...
        'amplitude', 1));

erp = @(lat,amp) ...
       (utl_set_dvslope( ...
                utl_check_class(struct( ...
                        'type', 'erp', ...
                        'peakLatency', lat, ...
                        'peakLatencyDv', 50, ...
                        'peakWidth', 200, ...
                        'peakAmplitude', amp)), ...
                'dv', .2, 'overwrite', 0));

sigsources = [lf_get_source_nearest(lf, [20 -65 5]), ...
              lf_get_source_nearest(lf, [-10 20 50]), ...
              lf_get_source_nearest(lf, [-30 -20 50]), ...
              lf_get_source_nearest(lf, [45 10 15]), ...
              lf_get_source_nearest(lf, [-20 -70 20])];


%% testcase 11: two sources, one high-amplitude but low-probability, the other v.v.

%% generating signal and noise
for s = subjects
    subjsources = utl_shift_source(sigsources, 7.5, lf);
    sources = lf_get_source_spaced(lf, 64, 25, 'sourceIdx', subjsources);
    components = utl_create_component(sources, noise, lf);
    
    % class 1
    c1compnoise = components;
    c1datanoise = generate_scalpdata(c1compnoise, lf, epochs);
    
    % class 2
    c2compnoise = components;
    c2datanoise = generate_scalpdata(c2compnoise, lf, epochs);
    c2compsig = components(1:2);
    c2compsig(1) = utl_add_signal_tocomponent(erp(300, 2), c2compsig(1));
    c2compsig(2) = utl_add_signal_tocomponent(erp(300, -8), c2compsig(2));
    c2compsig(2).signal{2}.probability = .25;
    c2datasig = generate_scalpdata(c2compsig, lf, epochs);

    testcase = '11';    
    mkdir(fullfile(savedir, testcase, num2str(s)));
    save(fullfile(savedir, testcase, num2str(s), 'components.mat'), 'c1compnoise', 'c2compnoise', 'c2compsig');
    save(fullfile(savedir, testcase, num2str(s), 'data.mat'), 'c1datanoise', 'c2datanoise', 'c2datasig');
end

%% mixing data
for s = subjects
    testcase = '11';    
    load(fullfile(savedir, testcase, num2str(s), 'data.mat'));
    load(fullfile(savedir, testcase, num2str(s), 'components.mat'));
    
    % mixing 
    [~, ~, ~, c1data] = utl_mix_data(c2datasig, c1datanoise, 0.37);
    [c2data, ~, ~, ~] = utl_mix_data(c2datasig, c2datanoise, 0.37);
    
    EEG1 = utl_create_eeglabdataset(c1data, epochs, lf, 'marker', 'event1');
    EEG2 = utl_create_eeglabdataset(c2data, epochs, lf, 'marker', 'event2');
    EEG = utl_reorder_eeglabdataset(pop_mergeset(EEG1, EEG2), 'mode', 'interleave');
    
    if exist(fullfile(savedir, num2str(testcase), num2str(s), sprintf('%d.set', s)))
        % replacing data on existing file
        EEGold = pop_loadset(sprintf('%d.set', s), fullfile(savedir, testcase, num2str(s)));
        EEGold.data = EEG.data;
        pop_saveset(EEGold, 'filename', num2str(s), 'filepath', fullfile(savedir, testcase, num2str(s)));
    else
        % adding ICA decomposition and dipole model
        EEG = utl_add_icaweights_toeeglabdataset(EEG, c1compnoise, lf);

        EEG = pop_dipfit_settings( EEG, 'hdmfile','standard_vol.mat','coordformat','MNI','mrifile','standard_mri.mat','chanfile','standard_1005.elc','coord_transform',[0.72312 0.72122 -4.369 0.017371 0.0021095 -1.5722 1.0173 0.99911 1.051] ,'chansel',[1:64] );
        EEG = pop_multifit(EEG, [1:64] ,'threshold',100,'plotopt',{'normlen' 'on'});

        mkdir(fullfile(savedir, testcase, num2str(s)));
        pop_saveset(EEG, 'filename', num2str(s), 'filepath', fullfile(savedir, testcase, num2str(s)));
    end
end
