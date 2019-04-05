function ld_menuHand(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global GROUP;
nextMenu = 1;

if isempty(GROUP)
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
elseif mod(GROUP,2) % ALSO STRONGLY DEPENDENT ON SESSION
    param.LeftOrRightHand = 1; % Left Hand
    ld_menuCond(param)
elseif ~mod(GROUP,2) % ALSO STRONGLY DEPENDENT ON SESSION
    param.LeftOrRightHand = 2; % Right Hand
    ld_menuCond(param)
end