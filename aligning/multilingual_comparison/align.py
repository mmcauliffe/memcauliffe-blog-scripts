import sys
import socket
import shutil, os
import time
import logging
import platform
import csv
import statistics
import re
import multiprocessing as mp
from datetime import datetime

host = socket.gethostname()

DEBUG_MODE = False

csv_columns = ['Name', 'Computer', 'Date', 'Corpus', 'Acoustic model', 'Type of benchmark', 'Final log-likelihood', 'Total time', 'Num_jobs']

if host == 'roquefort':
    MFA_REPO_PATH = '/data/mmcauliffe/dev/Montreal-Forced-Aligner'
    corpus_dir = '/media/share/datasets/aligner_benchmarks/sorted_english'
    output_directory = '/data/mmcauliffe/aligner-output/mfa_librispeech_lsa'
    model_path = r'D:\Data\aligner_comp\english.zip'
    temp_dir = '/data/mmcauliffe/temp/MFA'
    benchmark_path = '/data/mmcauliffe/aligner-output/benchmark.csv'

else:
    MFA_REPO_PATH = r'C:\Users\michael\Documents\Dev\Montreal-Forced-Aligner'
    corpus_dir = r'D:\Data\speech\benchmark_datasets\buckeye\prosodylab_format'
    output_directory = r'D:\Data\speech\benchmark_datasets\buckeye\aligner_comp'
    temp_dir = r'D:\Data\speech\benchmark_datasets\buckeye\temp'

    benchmark_path = r'D:\Data\speech\benchmark_datasets\benchmark.csv'

now = datetime.now()
date = str(now.year) + str(now.month) + str(now.day)

if not os.path.exists(benchmark_path):
    with open(benchmark_path, 'w', newline='', encoding='utf8') as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=csv_columns)
        writer.writeheader()


class AlignDummyArgs(object):
    def __init__(self):
        self.num_jobs = 12
        self.speaker_characters = 0
        self.verbose = False
        self.clean = not DEBUG_MODE
        self.debug = False
        self.corpus_directory = corpus_dir
        self.acoustic_model_path = 'english'
        self.dictionary_path = 'english'
        self.temp_directory = temp_dir
        self.output_directory = None
        self.config_path = None


class AdaptDummyArgs(object):
    def __init__(self):
        self.num_jobs = 12
        self.speaker_characters = 0
        self.verbose = False
        self.clean = not DEBUG_MODE
        self.debug = False
        self.corpus_directory = corpus_dir
        self.output_model_path = None
        self.dictionary_path = 'english'
        self.temp_directory = temp_dir
        self.config_path = None


class TrainDummyArgs(object):
    def __init__(self):
        self.num_jobs = 12
        self.speaker_characters = 0
        self.verbose = False
        self.clean = not DEBUG_MODE
        self.debug = False
        self.corpus_directory = corpus_dir
        self.dictionary_path = 'english'
        self.temp_directory = temp_dir
        self.output_directory = None
        self.output_model_path = None
        self.config_path = None
        self.multilingual_ipa = False



train_setups = [
    {'identifier': 'mfa_ipa_train', 'dictionary_path': r"D:\Data\speech\esports\esports_dict.txt", 'multilingual_ipa': False},
    {'identifier': 'mfa_ipa_train_multilingual', 'dictionary_path': r"D:\Data\speech\esports\esports_dict.txt", 'multilingual_ipa': True},
]

train_args = []
for setup in train_setups:
    a = TrainDummyArgs()
    a.dictionary_path = setup['dictionary_path']
    a.output_directory = os.path.join(output_directory, setup['identifier'])
    a.output_model_path = None
    a.multilingual_ipa = setup['multilingual_ipa']
    train_args.append(a)




sys.path.insert(0, MFA_REPO_PATH)

from montreal_forced_aligner.command_line.mfa import run_align_corpus, run_adapt_model, run_train_corpus, fix_path, unfix_path




def benchmark_train_corpus(arg):
    if not DEBUG_MODE and os.path.exists(arg.output_directory):
        return
    beg = time.time()
    if arg.multilingual_ipa:
        unk = ['--multilingual_ipa', 'true']
    else:
        unk = None
    run_train_corpus(arg, unk)
    train_log_path = os.path.join(arg.temp_directory, 'prosodylab_format', 'train_and_align.log')
    final_log_like = None
    with open(train_log_path, 'r', encoding='utf8') as f:
        for line in f:
            m = re.search(r'\(this might not actually mean anything\): (-[\d.]+)', line)
            if m:
                final_log_like = m.groups()[0]
    end = time.time()
    dict_data = {
        'Name': os.path.basename(arg.output_directory),
        'Computer': platform.node(),
        'Date': date,
        'Corpus': 'Buckeye',
        'Acoustic model': 'N/A',
        'Type of benchmark': 'train',
        'Total time': end - beg,
        'Final log-likelihood': final_log_like,
        'Num_jobs': arg.num_jobs}

    return dict_data


def WriteDictToCSV(csv_file, dict_data):
    with open(csv_file, 'w') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=csv_columns)
        writer.writeheader()
        for data in dict_data:
            writer.writerow(data)


if __name__ == '__main__':
    try:
        mp.freeze_support()
        fix_path()
        print('BEGIN TRAIN')
        for a in train_args:
            dict_data = benchmark_train_corpus(a)
            if not dict_data:
                continue

            with open(benchmark_path, 'a', newline='', encoding='utf8') as csv_file:
                writer = csv.DictWriter(csv_file, fieldnames=csv_columns)
                writer.writerow(dict_data)
    finally:
        unfix_path()
