import os
import subprocess

root_dir = r'D:\Data\experiments\alignment_benchmarking'
mfa10_dir = os.path.join(root_dir, 'montreal-forced-aligner_101')
timit_dir = r'D:\Data\speech\benchmark_datasets\timit'
buckeye_dir = r'D:\Data\speech\Buckeye'

corpus_directories = {'buckeye': buckeye_dir, 'timit': timit_dir}

arpa1_dictionary_path = os.path.join(mfa10_dir, 'pretrained_models', 'english.dict')
arpa1_model_path = os.path.join(mfa10_dir, 'pretrained_models', 'english.zip')
conditions = {
    'MFA2_arpa1': (arpa1_dictionary_path, arpa1_model_path),
    'MFA2_arpa2': ("english_us_arpa", "english_us_arpa"),
    'MFA2_ipa2': ("english_us_mfa", "english_mfa"),
}
mapping_files = {}
for k in conditions.keys():
    for corpus in corpus_directories:
        if 'arpa' in k:
            phone_set = 'arpa'
        else:
            phone_set = 'ipa'
        mapping_files[k] = os.path.join(root_dir, f"{phone_set}_{corpus}_mapping.yaml")

for condition, (dictionary_path, model_path) in conditions.items():
    for corpus, root in corpus_directories.items():
        output_directory = os.path.join(root_dir, 'alignments', condition, corpus)
        if os.path.exists(output_directory):
            continue
        subprocess.check_call(['mfa', 'align',
                               os.path.join(root, 'benchmark'),
                               dictionary_path,
                               model_path,
                               output_directory,
                               '-j', '10',
                               '-t',
                               os.path.join(root_dir, f'temp_{condition}_{corpus}'),
                               '--reference_directory',
                               os.path.join(root, 'reference'),
                               '--custom_mapping_path',
                                mapping_files[condition],
                               '--beam', '20', '--retry_beam', '80'
                               ], env=os.environ)