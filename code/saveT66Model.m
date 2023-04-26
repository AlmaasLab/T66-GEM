function saveT66Model(model, allowNoGrowth)
%saveT66Model Saves the iVS1191 GEM
%   Saves the iVS1191 model as a .xml, .txt, and .yml file.
%
%   Input:
%       model         (struct) iVS1191 model to save, can be either COBRA
%                     or RAVEN format
%       allowNoGrowth (bool, opt) if saving should be allowed whenever the
%                     the model cannot grow aerobically on glucose, 
%                     otherwise will error (default true)
%
%   Usage: saveT66Model(model, allowNoGrowth)
%
% Based on the MATLAB I/O functions in 
% https://github.com/SysBioChalmers/yeast-GEM

% Optional arguments
if nargin < 2
    allowNoGrowth = true;
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

% Check growth on glucose
selExc = findExcRxns(model);
excRxns = model.rxns(selExc);
simModel = changeRxnBounds(model, excRxns, 0, 'l');

% Load media
fname = '../data/physiology/min_glc_media.json';
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
val = jsondecode(str);
media = fields(val);
for i = 1:length(media)
    lb = - val.(media{i});
    simModel = changeRxnBounds(simModel, media{i}, lb, 'l');
end

% Maximize growth
sol = optimizeCbModel(simModel);
if sol.f < 1e-6
    if allowNoGrowth
        warning(['The model is unable to grow on minimal glucose media. ' ...
            'Please ensure the model can grow before opening a PR.']);
    else
        error(['The model is unable to grow on minimal glucose media.' ...
            'Please ensure the model can grow before committing.'])
    end
end

% Check if model results in a valid SBML file
exportModel(model,'tempModel.xml',false,false,true);
[~,~,errors] = evalc('TranslateSBML(''tempModel.xml'',1,0)');
if any(strcmp({errors.severity},'Error'))
    delete('tempModel.xml');
    error(['Model should be a valid SBML structure. ' ...
        'Please fix all errors before saving.'])
end

% Create model files (.xml and .yml)
copyfile('tempModel.xml','../model/iVS1191.xml')
delete('tempModel.xml');
writeYAMLmodel(model, '../model/iVS1191.yml')

% Write .txt file - based on exportForGit from RAVEN Toolbox
fid = fopen('../model/iVS1191.txt','w');
eqns = constructEquations(model, model.rxns, false, false, false);
eqns = strrep(eqns,' => ', '  -> ');
eqns = strrep(eqns,' <=> ', '  <=> ');
eqns = regexprep(eqns, '> $', '>');
grRules = regexprep(model.grRules, '\((?!\()', '( ');
grRules = regexprep(grRules, '(?<!\))\)', ' )');
fprintf(fid, 'Rxn name\tFormula\tGene-reaction association\tLB\tUB\tObjective\n');
for i = 1:numel(model.rxns)
    fprintf(fid, '%s\t', model.rxns{i});
    fprintf(fid, '%s \t', eqns{i});
    fprintf(fid, '%s\t', grRules{i});
    fprintf(fid, '%6.2f\t%6.2f\t%6.2f\n', model.lb(i), model.ub(i), model.c(i));
end
fclose(fid);

end