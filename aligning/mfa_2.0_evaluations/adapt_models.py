import os

from montreal_forced_aligner.command_line.adapt import run_adapt_model

model_dir = r'D:\Data\models'
evaluation_dir = os.path.join(model_dir, 'evaluations')

models = [x for x in os.listdir(model_dir) if x.endswith('.zip')] + ['english']

buckeye_benchmark_dir = r'D:\Data\speech\Buckeye\benchmark'
buckeye_reference_dir = r'D:\Data\speech\Buckeye\reference'
temp_dir = r'D:\temp\align_evaluation_temp'

ipa_dict_path = r"C:\Users\michael\Documents\Dev\mfa-models\dictionary\english_us_ipa.dict"
arpa_dict_path = r"C:\Users\michael\Documents\Dev\mfa-models\dictionary\english.dict"

ipa_mapping_path = r"D:\Data\speech\benchmark_datasets\buckeye\ipa_buckeye_mapping.yaml"
arpa_mapping_path = r"D:\Data\speech\benchmark_datasets\buckeye\arpa_buckeye_mapping.yaml"

class AdaptDummyArgs(object):
    def __init__(self):
        self.num_jobs = 15
        self.speaker_characters = 0
        self.verbose = False
        self.clean = True
        self.debug = False
        self.corpus_directory = buckeye_benchmark_dir
        self.acoustic_model_path = 'english'
        self.dictionary_path = 'english'
        self.temporary_directory = temp_dir
        self.output_paths = []
        self.output_model_path = None
        self.config_path = None

if __name__ == '__main__':
    for m in models:
        m_name = os.path.splitext(m)[0]
        if 'adapted' in m_name:
            continue
        print(m_name)
        if m == 'english':
            output_path = os.path.join(model_dir, 'english_1.0_adapted.zip')
            model_path = m
        else:
            output_path = os.path.join(model_dir, m.replace('.zip', '_adapted.zip'))
            model_path = os.path.join(model_dir, m)
        if os.path.exists(output_path):
            continue
        args = AdaptDummyArgs()
        args.acoustic_model_path = model_path
        args.output_model_path = output_path
        if 'ipa' in m:
            args.dictionary_path = ipa_dict_path
        else:
            args.dictionary_path = arpa_dict_path
        run_adapt_model(args)