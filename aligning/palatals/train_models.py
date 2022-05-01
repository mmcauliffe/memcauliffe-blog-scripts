import os.path
import re
import subprocess

#from montreal_forced_aligner.command_line.train_acoustic_model import run_train_acoustic_model

dictionaries = ['palatals_no_unreleased',
                'palatals_unreleased',

'no_palatals_no_unreleased', 'no_palatals_unreleased',]

experiment_root = '/mnt/d/Data/experiments/palatals'
librispeech_dir = '/mnt/d/Data/speech/librispeech_mfa'

temp_dir = r'/mnt/d/temp/palatals_temp2/'

for dict_name in dictionaries:
    print(dict_name)
    dictionary_path = os.path.join(experiment_root, 'input_dictionaries', dict_name+'.dict')
    model_path = os.path.join(experiment_root, f'{dict_name}.zip')
    subprocess.check_call(['mfa', 'model', 'inspect', 'dictionary', dictionary_path])
    #continue
    if os.path.exists(model_path):
        continue
    command = ['mfa', 'train', librispeech_dir, dictionary_path,
                     model_path, '-t', os.path.join(temp_dir, dict_name), '-j',
               '20', '--phone_set', 'IPA']
    #args = DefaultArgs(root_corpus_dir.format(lang),
    #                   root_dictionary.format(full_names[lang]), os.path.join(temp_dir, lang), model_path, tg_path)
    subprocess.check_call(command)
    #run_train_acoustic_model(args)