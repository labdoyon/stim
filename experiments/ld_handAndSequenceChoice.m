function ld_handAndSequenceChoice(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% sequence A is the default parameter, when it is used, there iscnothing to
% modify

% Left Hand is the default parameter, when it is used, there is nothing to
% modify
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
                disp('Left hand will be used');
                break
            case 2
                param.LeftOrRightHand = 2;
                disp('Right hand will be used');
                break
            case 3
                break
        end
    end

elseif mod(param.group,2) % uneven group number, half of the subjects
    
    % a group has been specified, therefore, automatic hand choice and
    % sequence choice are performed by the function, no menu is proposed
    
    % sequence A is used by default, sequence B is used if we are
    % performing the last two sessions
    if any(param.sessionNumber == param.sessions(end-1:end))
        param.seq='seqB';
    end
    
    % a quarter of the subjects use their right hand in the first of the
    % last two sessions
    % another quarter of the subjects use their right hand in the last of
    % the last two sessions
    if or(mod(param.group,4)==1 && param.sessionNumber == param.sessions(end-1),...
            mod(param.group,4)==3 && param.sessionNumber == param.sessions(end))
        param.LeftOrRightHand = 2; % Right Hand
        disp('Right hand will be used');
    elseif param.sessionNumber ~= param.sessions(end-2)
        disp('Left hand will be used');
    end

elseif ~mod(param.group,2) % even group number, half of the subjects
    
    % a group has been specified, therefore, automatic hand choice and
    % sequence choice are performed by the function, no menu is proposed
    
    % sequence B is used by default, sequence A is used if we are
    % performing the last two sessions
    if not(any(param.sessionNumber == param.sessions(end-1:end)))
        param.seq='seqB'; % sequence B will be used
    end
    
    % a quarter of the subjects use their right hand in the first of the
    % last two sessions
    % another quarter of the subjects use their right hand in the last of
    % the last two sessions
    if or(mod(param.group,4) && param.sessionNumber == param.sessions(end-1),... % (mod(param.group,4)==2) a quarter of the group subjects
            ~mod(param.group,4) && param.sessionNumber == param.sessions(end)) % (mod(param.group,4)==0) a quarter of the group subjects
        param.LeftOrRightHand = 2; % Right Hand
        disp('Right hand will be used');
    elseif param.sessionNumber ~= param.sessions(end-2)
        disp('Left hand will be used');
    end

end

% Right hand is always used in the case of the antepenultimate session
if ~isempty(param.group)
    if or(mod(param.group,2),~mod(param.group,2)) && param.sessionNumber == param.sessions(end-2)
        param.LeftOrRightHand = 2; % Right Hand
        disp('Right hand will be used');
    end
end

% if sessionNumber has been set and a start button has been pressed, launch
% experiment
if isfield(param,{'sessionNumber'}) && isfield(param,{'start'})
    ld_menuCond(param)
end