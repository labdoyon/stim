function [targets, gonogo] = ld_createGonogoMatrices(iNbTargets, iNbBlocks, iNbMaxTarget, iRatioNoGo)
% 
% 
% Arnaud Bore 2016/12/05
%   Create GoNoGo matrices
%
% 

if nargin<4, iRatioNoGo = 0.1; end
if nargin<3, iNbMaxTarget = 8;end
if nargin<2, iNbBlocks = 15; end
if nargin<1, iNbTargets = 60;end

%% List of targets
targets = [];

while size(targets, 1) ~= iNbBlocks
    tmpTargets = repmat(1:iNbMaxTarget, 1, floor(iNbTargets/8+1));
    tmpTargets = Shuffle(tmpTargets);
    while any(diff(tmpTargets,1,2) == 0)
        tmpTargets = Shuffle(tmpTargets);
    end
    targets(end+1, :) = tmpTargets(1,1:iNbTargets);
end

%% List of gonogo
gonogo = ones(iNbBlocks, iNbTargets);
B = randperm(numel(gonogo));
B = sort(B(1:iNbBlocks * iNbTargets * iRatioNoGo));
while any(diff(B,1)==1)
    B = randperm(numel(gonogo));
    B = sort(B(1:iNbBlocks * iNbTargets * iRatioNoGo));    
end
gonogo = gonogo';
gonogo(B) = 0;
gonogo = gonogo';
