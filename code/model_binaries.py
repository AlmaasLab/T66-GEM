import cobra
from model_io import read_t66_model
import pandas as pd


MODEL_PATH = 'model/iVS1191'


def build_binaries():
    """
    Reads the model SBML and saves the model as the binary model formats .mat 
    and .xlsx. 
    """
    model = read_t66_model(sanity_check=True)

    # Save as .mat
    cobra.io.save_matlab_model(model, f'{MODEL_PATH}.mat')

    # Save as .xlsx
    save_xlsx_model(model, f'{MODEL_PATH}.xlsx')


def save_xlsx_model(model: cobra.Model, filename: str):
    """
    Writes the model as an .xlsx file.

    Parameters
    ----------
    model : cobra.Model
        iVS1191 model to be written
    filename : str
        Name of .txt file
    """
    # Reactions
    rxn_dict_list = []
    for rxn in model.reactions:
        ec = None if 'ec-code' not in rxn.annotation else rxn.annotation['ec-code']
        obj_coeff = None if rxn.objective_coefficient == 0 else rxn.objective_coefficient
        miriam = ';'.join([f'{key}/{val}' for key, val in rxn.annotation.items()
                           if key != 'ec-code'])
        rxn_dict_list.append({
            '#': None, 'ID': rxn.id, 'NAME': rxn.name,
            'EQUATION': rxn.build_reaction_string(), 'EC-NUMBER': ec, 
            'GENE ASSOCIATION': str(rxn.gpr), 'LOWER BOUND': rxn.lower_bound, 
            'UPPER BOUND': rxn.upper_bound, 'OBJECTIVE': obj_coeff,
            'COMPARTMENT': rxn.compartments, 'MIRIAM': miriam, 
            'SUBSYSTEM': rxn.subsystem, 'REPLACEMENT ID': None, 
            'NOTE': rxn.notes, 'REFERENCE': None, 'CONFIDENCE SCORE': None
            })
    rxn_df = pd.DataFrame(rxn_dict_list)

    # Metabolites
    met_dict_list = []
    for met in model.metabolites:
        miriam = ';'.join([f'{key}/{val}' for key, val in met.annotation.items()
                           if key != 'inchi'])
        inchi = None if 'inchi' not in met.annotation else met.annotation['inchi']
        met_dict_list.append({
            '#': None, 'ID': f'{met.name}[{met.compartment}]',
            'NAME': met.name, 'UNCONSTRAINED': None, 'MIRIAM': miriam,
            'COMPOSITION': met.formula if inchi is None else None, 
            'InChI': inchi, 'COMPARTMENT': met.compartment, 
            'REPLACEMENT ID': met.id, 'CHARGE': met.charge
        })
    met_df = pd.DataFrame(met_dict_list)

    # Compartments
    comp_dict_list = [{'#': None, 'ABBREVIATION': key, 'NAME': val, 
                        'INSIDE': None, 'MIRIAM': None} 
                        for key, val in model.compartments.items()]
    comp_df = pd.DataFrame(comp_dict_list)

    # Genes
    gene_dict_list = [{'#': None, 'NAME': gene, 'MIRIAM': None, 
                       'SHORT NAME': gene, 'COMPARTMENT': None}
                       for gene in model.genes]
    gene_df = pd.DataFrame(gene_dict_list)

    # Model info
    model_dict_list = [{'#': None, 'ID': model.id, 'NAME': model.name, 
                        'TAXONOMY': None, 'DEFAULT LOWER': None,
                        'DEFAULT UPPER': None, 'CONTACT GIVEN NAME': None,
                        'CONTACT FAMILY NAME': None, 'CONTACT EMAIL': None,
                        'ORGANIZATION': None, 'NOTES': None}]
    model_df = pd.DataFrame(model_dict_list)

    # Write to .xlsx file
    with pd.ExcelWriter('model/iVS1191.xlsx') as writer:
        rxn_df.to_excel(writer, sheet_name='RXNS', index=False)
        met_df.to_excel(writer, sheet_name='METS', index=False)
        comp_df.to_excel(writer, sheet_name='COMPS', index=False)
        gene_df.to_excel(writer, sheet_name='GENES', index=False)
        model_df.to_excel(writer, sheet_name='MODEL', index=False)


if __name__ == '__main__':
    build_binaries()

    