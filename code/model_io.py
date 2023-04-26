import cobra
import json
import pandas as pd


MODEL_PATH = 'model/iVS1191'


def read_t66_model(sanity_check: bool  = False):
    """
    Imports the T66 GEM by reading the SBML file using cobrapy. Optionally
    performs some sanity checks to ensure that the model has been imported 
    correctly.

    Parameters
    ----------
    sanity_check : bool
        True if sanity checks should be performed, False otherwise (default)

    Returns
    ------- 
    model : cobra.Model
        iVS1191 model object
    """
    # Load model
    model = cobra.io.read_sbml_model(f'{MODEL_PATH}.xml')

    if sanity_check:
        # Check for necessary attributes
        req_attrs = ['reactions', 'metabolites', 'genes']
        for attr in req_attrs:
            if not hasattr(model, attr):
                raise Warning(f'Model does not have the required attribute {attr}')
        
        # Optimize growth on minimal glucose media
        with open('data/physiology/min_glc_media.json', 'r') as fp:
            min_glc_medium = json.load(fp)
        model.medium = min_glc_medium
        model.objective = 'biomass'
        solution = model.optimize()
        if solution.objective_value < 1e-6 or solution.status != 'optimal':
            raise Warning('Model unable to grow on minimal glucose media')
    return model


def write_t66_model(model: cobra.Model):
    """
    Writes the model to file as .xml, .yml and .txt.

    Parameters
    ----------
    model : cobra.Model
        iVS1191 model to be written
    """
    cobra.io.write_sbml_model(model, f'{MODEL_PATH}.xml')
    cobra.io.save_yaml_model(model, f'{MODEL_PATH}.yml')
    save_txt_model(model, f'{MODEL_PATH}.txt')


def save_txt_model(model: cobra.Model, filename: str):
    """
    Writes the model as an .txt file.

    Parameters
    ----------
    model : cobra.Model
        iVS1191 model to be written
    filename : str
        Name of .txt file
    """
    dict_list = [{'Rxn name': rxn.id, 
                  'Formula': rxn.build_reaction_string(),
                  'Gene-reaction association': rxn.gene_reaction_rule,
                  'LB': rxn.upper_bound,
                  'UB': rxn.lower_bound,
                  'Objective': rxn.objective_coefficient} 
                  for rxn in model.reactions]
    model_df = pd.DataFrame(dict_list)
    model_df.to_csv(filename, index=None, sep='\t')
    

if __name__ == '__main__':
    pass