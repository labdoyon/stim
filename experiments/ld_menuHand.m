function ld_menuHand(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nextMenu = 1;

if isempty(param.group)
    while nextMenu
        if param.language == 1 % langue: français
            choice = menu('Choix de main:','Main gauche','Main Droite','Quitter');
        elseif param.language == 2 % language: english
            choice = menu('Hand choice:','Left hand','Right Hand','Quit');
        end
        switch choice
            case 1
                param.LeftOrRightHand = 1;
            case 2
                param.LeftOrRightHand = 2;
            case 3
                break
        end
        ld_menuCond(param)
    end
elseif mod(param.group,2) % uneven, half of the group subjects % ALSO STRONGLY DEPENDENT ON SESSION
    
    param.LeftOrRightHand = 1; % Left Hand
    if mod(param.group,4)==1 % a quarter of the group subjects
        param.seq='seqB'; % sequence B will be used
    % elseif mod(param.group,4)==3 % another quarter of the group subjects
    % will use sequence A
    end
    ld_menuCond(param)
    
elseif ~mod(param.group,2) % even % ALSO STRONGLY DEPENDENT ON SESSION
    
    param.LeftOrRightHand = 2; % Right Hand
    if mod(param.group,4) % (==2) a quarter of the group subjects
        param.seq='seqB'; % sequence B will be used
    % elseif ~mod(param.group,4) % (==0) another quarter of the group subjects
    % will use sequence A
    end
    ld_menuCond(param)
    
end