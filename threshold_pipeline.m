%% SET VARIABLES - RUN THIS FIRST!
% parent folder where your individual behavioral files are, with each subject
% stored in a separate subfolder
% e.g. Behavior > SUBJ-ID-200 > [list of mat files from individual days];
% behavdir will be C:\Users\rose\Behavior
behavdir = 'D:\Caras\Analysis\Fiber photometry\Behavior';

% where you are saving your data
savedir = 'D:\Caras\Analysis\Fiber photometry\Behavior';

% parent folder where your data is located - should have subfolders for each
% condition, and then sub-subfolder subject with behavior file
% e.g. Caspase experiment > Control > SUBJ200 > SUBJ-ID-200_allSessions.mat; pth will be
% C:\Users\rose\Caspase experiment
pth = 'D:\Caras\Analysis\Fiber photometry\Behavior\Behavior';

% number of days you want to analyze
maxdays = 10;

% y limit - adjust as needed to make sure all data points are visible
yl = [-20,-2];

% colors to use in your graphs. rgb values (https://www.color-hex.com/)
c = [85,214,190; 18,78,120; 217,93,57]./255;

%% BEHAVIOR PIPELINE
% behavior pipeline - when running, select the folder containing the
% individual files, not the each of the files
% e.g. Behavior > SUBJ-ID-200 > [list of mat files from individual days];
% you would select the SUBJ-ID-200 folder
caraslab_behav_pipeline(savedir, behavdir, 'none', 1)

%% GRAPH AVERAGE THRESHOLDS ACROSS DAYS
% before you run this, remember to pull out the folder containing the
% allSessions.mat file out from the Behavior folder that the behavior
% pipeline automatically makes!

% error bars represent standard error

avg_threshold(pth, maxdays, yl, c)

%% SINGLE SUBJECT
% your pth is the folder containing the allSessions.mat file for the
% subject you want to analyze
pth = 'D:\Caras\Analysis\Fiber photometry\Behavior\Behavior\Perceptual training\SUBJ-ID-989';

% number of days you want to analyze
maxdays = 10;

% y limit - adjust as needed to make sure all data points are visible
yl = [-20,-5];

% color of your graphs. rgb values (https://www.color-hex.com/)
c = [0,0,0]./255;

one_subject_threshold(pth, maxdays, yl, c);