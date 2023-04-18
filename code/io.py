"""
Functions for reading and writing iVS1191.
"""


from cobra.io import read_sbml_model, write_sbml_model


MODEL_PATH = f'model/iVS1191.xml'
MIN_GLC_MEDIUM = {'EX_dglc_e': 1.44, 'EX_h2o_e': 1000.0, 'EX_o2_e': 1000.0, 
                  'EX_nh3_e': 10.0, 'EX_pi_e': 1000.0, 'EX_slf_e': 1000.0, 
                  'EX_h_e': 1000.0}


def read_t66_model(sanity_check=False):
    """
    Imports the T66 GEM by reading the SBML file using cobrapy. Optionally
    performs some sanity checks to ensure that the model has been imported 
    correctly.

    Returns
    ------- 
    model : cobra.core.Model
        iVS1191 model object
    """
    # Load model
    model = read_sbml_model(MODEL_PATH)

    if sanity_check:
        # Check for necessary attributes
        req_attrs = ['reactions', 'metabolites', 'genes']
        for attr in req_attrs:
            if not hasattr(model, attr):
                raise Warning(f'Model does not have the required attribute {attr}')
        
        # Optimize growth on minimal glucose media
        model.medium = MIN_GLC_MEDIUM
        model.objective = 'biomass'
        solution = model.optimize()
        if solution.status != 'optimal':
            raise Warning('Model unable to grow on minimal glucose media')
    return model


def write_t66_model(model):
    """
    Writes the model to an SBML file.

    Parameters
    ----------
    model : cobra.core.Model
        iVS1191 model to be written
    """
    write_sbml_model(model, MODEL_PATH)
    #TODO: add option to write model as .yml, .txt, .xlsx, .mat


if __name__ == '__main__':
    print(__file__)
    model = read_t66_model(sanity_check=True)