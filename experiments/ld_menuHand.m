function ld_menuHand(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nextMenu = 1;

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
