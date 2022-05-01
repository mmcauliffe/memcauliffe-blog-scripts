import os

from montreal_forced_aligner.command_line.align import run_align_corpus

model_dir = r'D:\Data\experiments\korean'
evaluation_dir = os.path.join(model_dir, 'evaluations')

models = [x for x in os.listdir(model_dir) if x.endswith('.zip')]

buckeye_benchmark_dir = r'D:\Data\speech\korean_corpora\seoul_corpus\seoul_corpus_benchmark'
buckeye_reference_dir = r'D:\Data\speech\korean_corpora\seoul_corpus\seoul_reference_alignments'
temp_dir = r'D:\temp\align_evaluation_temp'

ipa_mapping_path = r"D:\Data\experiments\korean\korean_mfa_mapping.yaml"

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
        args.custom_mapping_path = ipa_mapping_path
        args.dictionary_path = os.path.join(model_dir, m_name + '.dict')
        args.acoustic_model_path = model_path
        args.output_directory = output
        run_align_corpus(args)