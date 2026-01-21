pth = 'D:\Caras\Analysis\Caspase\Acquisition\acx plot profile';

groups = dir(pth);
groups(~[groups.isdir]) = [];
groups(ismember({groups.name},{'.','..'})) = [];

headers = {'Subject', 'Side','A_P','Pct_lesion'};
alldata = table('size',[1 4],...
    'variabletypes',["string","string","string","double"],...
    'variablenames',headers);

targetpct = 5;

for i = 1:length(groups)
    
    fn = fullfile(pth, groups(i).name);
    F = dir(fn);
    F(ismember({F.name},{'.','..'})) = [];
    
    for j = 1:length(F)
        
        filedata = table('size',[1 4],...
            'variabletypes',["string","string","string","double"],...
            'variablenames',headers);
        roi = F(j).name;
        fprintf('Loading %s', roi)
        PP = readtable(fullfile(F(j).folder,F(j).name));
        fprintf(' done\n')

        microns = table2array(PP(:,1));
        vals = table2array(PP(:,2));
        
        if min(vals) > 0
            vals = vals - min(vals);
        end
        
        pctileest = (targetpct / 100)*max(vals);
        
%         edges = [0:max(vals)/50:max(vals)];
%         bincounts = histcounts(vals, edges);
%         
%         bincumpcts = 100*(cumsum(bincounts)/height(vals));
%         relevantbin = find(bincumpcts >= targetpct,1);
%         
%         binstart = edges(relevantbin);
%         binsize = edges(relevantbin+1) - binstart;
%         pctstart = bincumpcts(relevantbin-1);
%         pctsize = bincumpcts(relevantbin) - pctstart;
        
%         pctileest = binstart + binsize * (targetpct - pctstart) / pctsize;
        
        lesion = microns(vals < pctileest);
        pctlesion = (length(lesion)/length(microns))*100;
        
        filename = split(F(j).name, ' ');
        coords = split(filename(2), '.');
        coords = cell2mat(coords(1));
        
        filedata.Subject = filename(1);
        filedata.Side = coords(1);
        filedata.A_P = coords(2);
        filedata.Pct_lesion = pctlesion;
        
        % append to table
        alldata = [alldata; filedata];
    end
end

% delete first row
alldata(1,:) = [];