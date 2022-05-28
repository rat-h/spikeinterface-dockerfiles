function ks_master(fpath)
    try
        set(groot,'defaultFigureVisible', 'off');

        % Load channel map file
        load(fullfile(fpath, 'chanMap.mat'));

        % Load the configuration file, it builds the structure of options (ops)
        load(fullfile(fpath, 'ops.mat'));

        useGPU = ops.GPU;

        % load predefined principal components (visualization only (Phy): used for features)
        dd                  = load('PCspikes2.mat'); % you might want to recompute this from your own data
        ops.wPCA            = dd.Wi(:,1:7);   % PCs

        % This part runs the normal Kilosort processing on the simulated data
        [rez, DATA, uproj] = preprocessData(ops); % preprocess data and extract spikes for initialization
        rez                = fitTemplates(rez, DATA, uproj);  % fit templates iteratively
        rez                = fullMPMU(rez, DATA);% extract final spike times (overlapping extraction)

        rez = merge_posthoc2(rez);
        fprintf('merge_posthoc2 error. Reporting pre-merge result\n');

        % save python results file for Phy
        rezToPhy(rez, fullfile(fpath));
    catch
        fprintf('----------------------------------------');
        fprintf(lasterr());
        quit(1);
    end
    quit(0);
end

