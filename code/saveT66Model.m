function saveT66Model(model, allowNoGrowth, binaryFiles)
%saveT66Model Saves the iVS1191 GEM
%   Saves the iVS1191 model as a .xml, .txt, and .yml file.
%
%   Input:
%       model         (struct) iVS1191 model to save, can be either COBRA
%                     or RAVEN format
%       allowNoGrowth (bool, opt) if saving should be allowed whenever the
%                     the model cannot grow (an)aerobically on glucose, 
%                     otherwise will error (default true)
%       binaryFiles   (bool, opt) if the model should be stored in binary
%                     file formats (default false)
%
%   Usage: saveT66Model(model, allowNoGrowth, binaryFiles)
%
% Based on the MATLAB I/O functions in 
% https://github.com/SysBioChalmers/yeast-GEM

% Optional arguments
if nargin < 2
    allowNoGrowth = true;
end
if nargin < 3
    binaryFiles = false;
end

% Check toolbox availability
hasCobra = true;
hasRaven = true;
if ~(exist('readCbModel.m', 'file') == 2)
    hasCobra = false;
end
if ~(exist('importModel.m', 'file') == 2)
    hasRaven = false;
end
if ~hasCobra && ~hasRaven
    error(['Neither COBRA or RAVEN is available. ' ...
        'Please ensure either is installed correctly.'])
end

% Use RAVEN format for saving
if isfield(model, 'rules')
    model = ravenCobraWrapper(model);
end
model.id = 'iVS1191';
model.name = 'iVS1191';

scriptFolder = fileparts(which(mfilename));
currentDir = cd(scriptFolder);
cd(currentDir)

% Check if model results in a valid SBML file
exportModel(model,'tempModel.xml',false,false,true);
[~,~,errors] = evalc('TranslateSBML(''tempModel.xml'',1,0)');
if any(strcmp({errors.severity},'Error'))
    delete('tempModel.xml');
    error(['Model should be a valid SBML structure. ' ...
        'Please fix all errors before saving.'])
end

% Create model files
copyfile('tempModel.xml','../model/iVS1191.xml')
delete('tempModel.xml');
if binaryFiles==false
    exportForGit(model,'iVS1191','../model',{'yml','txt'},false,false);
else
    exportForGit(model,'iVS1191','../model',{'yml','txt','xlsx','mat'},false,false);
end

end