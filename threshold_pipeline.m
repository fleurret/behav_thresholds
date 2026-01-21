%% SET VARIABLES - RUN THIS FIRST!
% parent folder where your individual behavioral files are, with each subject
% stored in a separate subfolder
% e.g. Behavior > SUBJ-ID-200 > [list of mat files from individual days];
% behavdir will be C:\Users\rose\Behavior
behavdir = 'D:\Caras\Analysis\Caspase\Acquisition\Asbah cohort';

% where you are saving your data
savedir = 'D:\Caras\Analysis\Caspase\Acquisition\Asbah cohort';

% parent folder where your data is located - should have subfolders for each
% condition, and then sub-subfolder subject with behavior file
% e.g. Caspase experiment > Control > SUBJ200 > SUBJ-ID-200_allSessions.mat; pth will be
% C:\Users\rose\Caspase experiment
pth = 'D:\Caras\Analysis\Caspase\Acquisition\Asbah cohort';

% shock training folder
spth = 'D:\Caras\Analysis\Caspase\Acquisition\Shock training';

% number of days you want to analyze
maxdays = 10;

% y limit - adjust as needed to make sure all data points are visible
yl = [-25,-5];

% colors to use in your graphs. rgb values (https://www.color-hex.com/)
c = [61, 35, 87;... % saline
    153, 142, 225;... % ibotenic acid
    73, 165, 119;... % drcre + sal
    180, 219, 173;... % drcre + casp
    219, 127, 103;... % rcre + sal
    0, 0, 0]./255;

% use custom font
fontface = 'Barlow';

%% BEHAVIOR PIPELINE - REMEMBER TO RUN THIS FOR NEW DATA!
% behavior pipeline to calculate thresholds for each day
% when running, select the folder containing the
% individual files, not the each of the files
% e.g. Behavior > SUBJ-ID-200 > [list of mat files from individual days];
% you would select the SUBJ-ID-200 folder
caraslab_behav_pipeline(savedir, behavdir, 'none', 0)

%% SHOCK TRAINING GRAPHS
% shock_training_dprimes: plots d' across days of shock training
% days_to_criterion: bars comparing how many days it took to get to d' > 2
% and highest d' achieved during shock training

% shock_training_dprimes(spth, savedir, c, fontface)
days_to_criterion(spth, savedir, c, fontface, 0)

%% GRAPH AVERAGE THRESHOLDS ACROSS DAYS
% before you run this, remember to pull out the folder containing the
% allSessions.mat file out from the Behavior folder that the behavior
% pipeline automatically makes!

% error bars represent standard error

avg_threshold(pth, savedir, maxdays, yl, c, fontface)

%% GRAPH AVERAGE PERCENT IMPROVEMENT ACROSS DAYS
% before you run this, remember to pull out the folder containing the
% allSessions.mat file out from the Behavior folder that the behavior
% pipeline automatically makes!

% error bars represent standard error

pct_impr(pth, savedir, maxdays, c, fontface)

%% OUTPUT THRESHOLDS FOR STATS
% stats_output: creates a csv file with each subject's threshold and FA for
% each day

% dprime_stats_output: creates a csv file with each subject's d' and number
% of trials for each depth presented

stats_output(pth)
% dprime_stats_output(pth)

%% REPRESENTATIVE SUBJECT CURVES AND THRESHOLDS
% one_subject_threshold: 1. one animal's d' and curve for day 1; 2. one
% animal's psychometric curves across days; 3. one animal's thresholds
% across days

% y limit - adjust as needed to make sure all data points are visible
yl = [-20,-5];

one_subject_threshold(pth, savedir, maxdays, yl, fontface);
% one_subject_threshold_rep(pth, savedir, maxdays, yl, fontface);

%% CALCULATE SUJBECT LEARNING RATES
% extracts each subject's initial threshold, best threshold, and learning
% rate into a .csv file

% rerun when you get new data!

learning_rates(pth, savedir, maxdays)

%% COMPARE LEARNING RATES ACROSS GROUPS
% plots bar graphs of mean learning rates +- SEM for each experimental
% condition. 

% run learning_rates function first!

% measure: 'learningrate', 'besththreshold', 'startingthreshold',
% 'improvement'
% c: color palette defined in the first section

plot_learning_rates(savedir, 'learningrate', c)

%% ABLATION QUANTIFICATION
% plot_ablation: plots bar graphs of mean cell density/count +- SEM for each experimental
% condition
% ablation_corr: is there a correlation between IC and ACx ablations in
% each group?

% abl: 'IC', 'ACX'
% c: color palette defined in the first section

plot_ablation(savedir,'IC', c)
% ablation_corr(savedir, c)

%% BEHAVIOR VS ABLATION CORRELATION
% behavior_ablation: plots correlations between behavior and ablation
% measures for each group

% behavior_ablation_all: plots it all on one axis

% measure: 'learningrate', 'besththreshold', 'startingthreshold',
% 'improvement'
% abl: 'IC', 'ACX'
% c: color palette defined in the first section

% behavior_ablation(savedir, 'bestthreshold', 'IC', c)
behavior_ablation_all(savedir, 'improvement', 'IC', c)

%% PLOT D' FOR EACH DEPTH

dprime_depths(savedir, c)
