function dprime_stats_output(pth)

% extract groups
conditions = uigetfile_n_dir(pth, 'Select data directory');

Subjects = [];
Day = [];
Condition = [];
depths = [];
dprimes = [];
n_trials = [];

% for each subfolder
for k = 1:length(conditions)
    subjects = dir(cell2mat(conditions(k)));
    subjects(~[subjects.isdir]) = [];
    subjects(ismember({subjects.name},{'.','..'})) = [];
    [~, cond, ~] =  fileparts(conditions(k));
    
    maxdays = 10;
    
    % extract output for each subject
    for subj = 1:length(subjects)
        spth = fullfile(subjects(subj).folder,subjects(subj).name);
        d = dir(fullfile(spth,'*.mat'));
        ffn = fullfile(d.folder,d.name);
        
        fprintf('Loading subject %s ...',subjects(subj).name)
        load(ffn)
        fprintf(' done\n')
        
        d = nan(1,maxdays);
        D = nan(1,maxdays);
        
        for i = 1:length(output)
            trialdata = output(i).trialmat;
            
            % remove nogos
            trialdata(find(trialdata == -40),:) = [];
            
            d = round(output(i).dprimemat(:,1)');
            D = output(i).dprimemat(:,2)';
            n = trialdata(:,3)';
            
            Subjects = [Subjects, repelem(convertCharsToStrings(subjects(subj).name), length(d))];
            Condition = [Condition, repelem({cond}, length(d))];
            Day = [Day, repelem(i, length(d))];
            depths = [depths, d];
            dprimes = [dprimes, D];
            n_trials = [n_trials, n];

            clear d D n
        end
    end
end

% make table
output = [Subjects', Day', Condition', depths', dprimes', n_trials'];
output = array2table(output);
output.Properties.VariableNames = ["Subject", "Day", "Condition", "Depth", "dprime", "n_trials"];

% save as file
sf = fullfile(pth,'dprime_stats_output.csv');
fprintf('\n Saving file %s ...', sf)
writetable(output,sf);
fprintf(' done\n')
