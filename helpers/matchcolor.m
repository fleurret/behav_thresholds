function [color] = matchcolor(fn, c)

% get name
if contains(fn, '\')
    [~, cond, ~] =  fileparts(fn);
else
    cond = fn;
end

% match
if contains(cond, 'Ibotenic') || contains(cond, 'ibo')
    color = c(2,:);
elseif contains(cond, 'Full') || contains(cond, 'rGFP')
    if contains(cond, 'Diluted') || contains(cond, 'drGFP')
        if contains(cond, 'Saline') || contains(cond, 'saline')
            color = c(3,:);
        else
            color = c(4,:);
        end
    else
        color = c(5,:);
    end
else
    color = c(1,:);
end
