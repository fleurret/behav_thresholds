%% SET VARIABLES
% folder where your data is located - should have subfolders for each
% condition, and then sub-subfolder subject with behavior file
% e.g. Caspase > Control > SUBJ200 > behaviorfile.mat; your path will be
% C:\Users\rose\Caspase
pth = 'D:\Caras\Analysis\Caspase\Acquisition';
behavdir = 'D:\Caras\Analysis\Caspase';
savedir = 'D:\Caras\Analysis\Caspase\Behavior';

% number of days you want to analyze
maxdays = 10;

% y limit - adjust as needed to make sure all data points are visible
yl = [-20,-2];

% colors to use in your graphs. rgb values (https://www.color-hex.com/)
c = [85,214,190; 18,78,120; 217,93,57]./255;

%% BEHAVIOR PIPELINE
caraslab_behav_pipeline(savedir, behavdir, 'none', 1)

%% GRAPH AVERAGE THRESHOLDS ACROSS DAYS
% bars represent standard error

avg_threshold(pth, maxdays, yl, c)

%% SINGLE SUBJECT

pth = 'D:\Caras\Analysis\Caspase\Maintenance\Experimental\527';

% number of days you want to analyze
maxdays = 10;

% y limit - adjust as needed to make sure all data points are visible
yl = [-20,-2];

% colors to use in your graphs. rgb values (https://www.color-hex.com/)
c = [69,207,217 ; 120,57,118]./255;

one_subject_threshold(pth, maxdays, yl, c);