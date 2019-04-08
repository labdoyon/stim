function ld_handAndSequenceChoice(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nextMenu = 1;

if isempty(param.group)
    
    % no group has been specified, therefore, there is no automatic hand
    % choice or sequence choice, a menu is proposed
    while nextMenu
        if param.language == 1 % langue: français
            choice = menu('Choix de main:','Main gauche','Main Droite','Quitter');
        elseif param.language == 2 % language: english
            choice = menu('Hand choice:','Left hand','Right Hand','Quit');
        end
        switch choice
            case 1
                param.LeftOrRightHand = 1;
                break
            case 2
                param.LeftOrRightHand = 2;
                break
            case 3
                break
        end
    end

elseif mod(param.group,2) % uneven, half of the group subjects % ALSO STRONGLY DEPENDENT ON SESSION
    
    % a group has been specified, therefore, automatic hand choice and
    % sequence choice are performed by the function, no menu is proposed
    param.LeftOrRightHand = 1; % Left Hand
    if mod(param.group,4)==1 % a quarter of the group subjects
        param.seq='seqB'; % sequence B will be used
    % elseif mod(param.group,4)==3 % another quarter of the group subjects
    % will use sequence A
    end
    setappdata(0,'param', param);

elseif ~mod(param.group,2) % even % ALSO STRONGLY DEPENDENT ON SESSION
    
    % a group has been specified, therefore, automatic hand choice and
    % sequence choice are performed by the function, no menu is proposed
    param.LeftOrRightHand = 2; % Right Hand
    if mod(param.group,4) % (==2) a quarter of the group subjects
        param.seq='seqB'; % sequence B will be used
    % elseif ~mod(param.group,4) % (==0) another quarter of the group subjects
    % will use sequence A
    end
    setappdata(0,'param', param);

end

% if sessionNumber has been set and a start button has been pressed, launch
% experiment
if isfield(param,{'sessionNumber'}) && isfield(param,{'start'})
    ld_menuCond(param)
end