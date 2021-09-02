import sys
import socket
import shutil, os
import time
import logging
import platform
import csv
import statistics
import re
from decimal import Decimal
import multiprocessing as mp
from datetime import datetime

host = socket.gethostname()

DEBUG_MODE = False

csv_columns = ['name', 'num_speakers', 'num_utterances', 'num_words', 'duration']


MFA_REPO_PATH = r'/mnt/c/Users/michael/Documents/Dev/Montreal-Forced-Aligner'
temp_dir = r'/mnt/d/Data/speech/benchmark_datasets/buckeye/smalls/validate_temp'

root_dir = '/mnt/d/Data/speech/benchmark_datasets/buckeye/inverse_smalls'
output_path = r'/mnt/d/Data/speech/benchmark_datasets/buckeye/smalls/inverse_subset_info.csv'
sys.path.insert(0, MFA_REPO_PATH)

from montreal_forced_aligner.command_line.mfa import fix_path, unfix_path
from montreal_forced_aligner.validator import CorpusValidator
from montreal_forced_aligner.corpus.align_corpus import AlignableCorpus
from montreal_forced_aligner.dictionary import Dictionary

train_setups = [f'{x}_{y}' for x in range(1, 40) for y in range(5)]
dictionary_path = '/mnt/d/Data/speech/esports/esports_dict.txt'


if __name__ == '__main__':
    stats = []
    try:
        mp.freeze_support()
        fix_path()
        data_directory = os.path.join(temp_dir, 'dictionary')
        dictionary = Dictionary(dictionary_path, data_directory)
        print('BEGIN VALIDATE')
        for a in train_setups:
            print(a)
            data_directory = os.path.join(temp_dir, a)
            corpus_directory = os.path.join(root_dir, a)
            if not os.path.isdir(corpus_directory):
                continue
            corpus = AlignableCorpus(corpus_directory, data_directory,
                            num_jobs=12)
            validator = CorpusValidator(corpus, dictionary, temp_directory=data_directory,
                        ignore_acoustics=True, test_transcriptions= False)
            total_duration = sum(x[2] for x in validator.corpus.wav_info.values())
            total_duration = Decimal(str(total_duration)).quantize(Decimal('0.001'))
            num_utterances = validator.corpus.num_utterances
            num_speakers = len(validator.corpus.speak_utt_mapping)
            num_words = 0
            for t in validator.corpus.text_mapping.values():
                num_words += len(t.split())
            stats.append({'name': a, 'num_speakers': num_speakers, 'num_utterances': num_utterances,
                          'num_words': num_words, 'duration': total_duration})
    finally:
        unfix_path()
    with open(output_path, 'w', newline='', encoding='utf8') as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=csv_columns)
        writer.writeheader()
        for dict_data in stats:
            writer.writerow(dict_data)