import os

from montreal_forced_aligner.command_line.align import run_align_corpus

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

class AlignDummyArgs(object):
    def __init__(self):
        self.num_jobs = 15
        self.speaker_characters = 0
        self.verbose = False
        self.clean = True
        self.debug = False
        self.corpus_directory = buckeye_benchmark_dir
        self.reference_directory = buckeye_reference_dir
        self.acoustic_model_path = 'english'
        self.dictionary_path = 'english'
        self.temporary_directory = temp_dir
        self.output_directory = None
        self.custom_mapping_path = None
        self.config_path = None

if __name__ == '__main__':
    for m in models:
        m_name = os.path.splitext(m)[0]
        if m == 'english':
            model_path = m
            m_name = 'english_1.0'
        else:
            model_path = os.path.join(model_dir, m)
        print(m_name)
        output = os.path.join(evaluation_dir, m_name)
        if os.path.exists(output):
            continue
        args = AlignDummyArgs()
        args.acoustic_model_path = model_path
        args.output_directory = output
        if 'ipa' in m:
            args.dictionary_path = ipa_dict_path
            args.custom_mapping_path = ipa_mapping_path
        else:
            args.dictionary_path = arpa_dict_path
            args.custom_mapping_path = arpa_mapping_path
        run_align_corpus(args)