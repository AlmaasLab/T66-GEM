function model = loadT66Model(cobra)
%loadT66Model Loads the iVS1191 GEM
%   Load the iVS1191 model in a MATLAB environment using either COBRA
%   or RAVEN format.
%
%   Input:
%       cobra       (bool, opt) if the model should be returned in the 
%                   COBRA format, false for RAVEN format (default true)
%
%   Output:
%       model       (struct) iVS1191 model
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
    model = readCbModel('../model/iVS1191.xml');
elseif cobra && ~hasCobra && hasRaven
    warning('COBRA cannot be found, using RAVEN format instead');
    model = importModel('../model/iVS1191.xml');
elseif ~cobra && hasRaven
    model = importModel('../model/iVS1191.xml');
elseif ~cobra && ~hasRaven && hasCobra
    warning('RAVEN cannot be found, using COBRA format instead');
    model = readCbModel('../model/iVS1191.xml');
else
    error('Neither COBRA or RAVEN is available')
end

end