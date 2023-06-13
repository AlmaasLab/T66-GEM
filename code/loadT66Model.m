function model = loadT66Model(cobra)
%loadT66Model Loads the T66-GEM GEM
%   Load the T66-GEM model in a MATLAB environment using either COBRA
%   or RAVEN format.
%
%   Input:
%       cobra       (bool, opt) if the model should be returned in the 
%                   COBRA format, false for RAVEN format (default true)
%
%   Output:
%       model       (struct) T66-GEM
%
%   Usage: model = loadT66Model(cobra)
%
% Based on the MATLAB I/O functions in 
% https://github.com/SysBioChalmers/yeast-GEM

% Optional arguments
if nargin < 1
    cobra = true;
end

% Check if either COBRA or RAVEN is installed
hasCobra = true;
hasRaven = true;
if ~(exist('readCbModel.m', 'file') == 2)
    hasCobra = false;
end
if ~(exist('importModel.m', 'file') == 2)
    hasRaven = false;
end

% Load model using either COBRA or RAVEN format
scriptFolder = fileparts(which(mfilename));
currentDir = cd(scriptFolder);
cd(currentDir)
if cobra && hasCobra
    model = readCbModel('../model/T66-GEM.xml');
elseif cobra && ~hasCobra && hasRaven
    warning('COBRA cannot be found, using RAVEN format instead');
    model = importModel('../model/T66-GEM.xml');
elseif ~cobra && hasRaven
    model = importModel('../model/T66-GEM.xml');
elseif ~cobra && ~hasRaven && hasCobra
    warning('RAVEN cannot be found, using COBRA format instead');
    model = readCbModel('../model/T66-GEM.xml');
else
    error('Neither COBRA or RAVEN is available')
end

end