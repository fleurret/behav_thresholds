function stats_output(pth)

conditions = dir(pth);
conditions(~[conditions.isdir]) = [];
conditions(ismember({conditions.name},{'.','..'})) = [];

Subjects = [];
Day = [];
Condition = [];
Threshold = [];

% for each subfolder
for k = 1:length(conditions)
    subjects = dir(fullfile(pth,conditions(k).name));
    subjects(~[subjects.isdir]) = [];
    subjects(ismember({subjects.name},{'.','..'})) = [];
    
    maxdays = 10;
    thresholds = nan(length(subjects),maxdays);
    
    % extract output for each subject
    for subj = 1:length(subjects)
        spth = fullfile(subjects(subj).folder,subjects(subj).name);
        d = dir(fullfile(spth,'*.mat'));
        ffn = fullfile(d.folder,d.name);
        
        fprintf('Loading subject %s ...',subjects(subj).name)
        load(ffn)
        fprintf(' done\n')
        
        t = nan(1,maxdays);
        for i = 1:length(output)
            t(i) = output(i).fitdata.threshold;
        end
        
        Subjects = [Subjects, repelem(convertCharsToStrings(subjects(subj).name), length(t))];
        Day = [Day, 1:length(t)];
        Condition = [Condition, repelem(convertCharsToStrings(conditions(k).name), length(t))];
        Threshold = [Threshold, t];   
        
        clear t
    end
end

% make table
output = [Subjects', Day', Condition', Threshold'];
output = array2table(output);
output.Properties.VariableNames = ["Subject", "Day", "Condition", "Threshold"];

% save as file
sf = fullfile(pth,'stats_output.csv');
fprintf('\n Saving file %s ...', sf)
writetable(output,sf);
fprintf(' done\n')
