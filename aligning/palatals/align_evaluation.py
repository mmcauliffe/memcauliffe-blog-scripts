import os

from montreal_forced_aligner.command_line.align import run_align_corpus

model_dir = r'D:\Data\experiments\palatals'
evaluation_dir = os.path.join(model_dir, 'evaluations')

models = [x for x in os.listdir(model_dir) if x.endswith('.zip')]

buckeye_benchmark_dir = r'D:\Data\speech\Buckeye\benchmark'
buckeye_reference_dir = r'D:\Data\speech\Buckeye\reference'
temp_dir = r'D:\temp\align_evaluation_temp'

ipa_dict_path = r"C:\Users\michael\Documents\Dev\mfa-models\dictionary\english_us_ipa.dict"
arpa_dict_path = r"C:\Users\michael\Documents\Dev\mfa-models\dictionary\english.dict"

ipa_mapping_path = r"D:\Data\speech\benchmark_datasets\buckeye\ipa_buckeye_mapping.yaml"
arpa_mapping_path = r"D:\Data\speech\benchmark_datasets\buckeye\arpa_buckeye_mapping.yaml"

class AlignDummyArgs(object):
    def __init__(self):
        self.num_jobs = 5
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
        if m_name.endswith('lm'):
            continue
        model_path = os.path.join(model_dir, m)
        if not os.path.exists(model_path):
            continue
        output = os.path.join(evaluation_dir, m_name)
        if os.path.exists(output):
            continue
        print(m_name)
        args = AlignDummyArgs()
        if m_name == 'english_us_arpa':
            args.custom_mapping_path = arpa_mapping_path
        else:
            args.custom_mapping_path = ipa_mapping_path
        args.dictionary_path = os.path.join(model_dir, m_name + '.dict')
        args.acoustic_model_path = model_path
        args.output_directory = output
        run_align_corpus(args, ['--beam', '20', '--retry_beam', '80'])