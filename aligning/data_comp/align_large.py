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

root_dir = '/mnt/d/Data/speech/benchmark_datasets/buckeye/smalls'

MFA_REPO_PATH = r'/mnt/c/Users/michael/Documents/Dev/Montreal-Forced-Aligner'
output_directory = r'/mnt/d/Data/speech/benchmark_datasets/buckeye/smalls/models'
temp_dir = r'/mnt/d/Data/speech/benchmark_datasets/buckeye/smalls/temp'
corpus_directory = r'/mnt/d/Data/speech/benchmark_datasets/buckeye/inverse_smalls'

os.makedirs(output_directory, exist_ok=True)

benchmark_path = r'/mnt/d/Data/speech/benchmark_datasets/buckeye/smalls/benchmark.csv'

sys.path.insert(0, MFA_REPO_PATH)

from montreal_forced_aligner.command_line.mfa import run_align_corpus, fix_path, unfix_path

csv_columns = ['Name', 'Computer', 'Date', 'Corpus', 'Acoustic model', 'Type of benchmark', 'Final log-likelihood', 'Total time', 'Num_jobs']
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
        self.corpus_directory = None
        self.dictionary_path = 'english'
        self.temp_directory = temp_dir
        self.output_directory = None
        self.acoustic_model_path = None
        self.config_path = None
        self.audio_directory = None


def benchmark_align_corpus(arg):
    if not DEBUG_MODE and os.path.exists(arg.output_directory):
        return
    beg = time.time()
    run_align_corpus(arg)
    corpus_name = os.path.basename(arg.corpus_directory)
    acoustic_name = os.path.splitext(os.path.basename(arg.acoustic_model_path))[0]
    train_log_path = os.path.join(arg.temp_directory, corpus_name, 'align.log')
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
        'Corpus': corpus_name,
        'Acoustic model': acoustic_name,
        'Type of benchmark': 'align',
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


train_setups = [f'{x}_{y}' for x in range(1, 40) for y in range(5)]

train_setups.reverse()

train_args = []
for identifier in train_setups:
    a = AlignDummyArgs()
    a.dictionary_path = '/mnt/d/Data/speech/esports/esports_dict.txt'
    a.corpus_directory = os.path.join(corpus_directory, identifier)
    a.output_directory = os.path.join(output_directory, 'full_align_tgs', identifier)
    a.acoustic_model_path = os.path.join(output_directory, identifier +'.zip')
    if os.path.exists(a.output_directory):
        continue
    train_args.append(a)


if __name__ == '__main__':
    try:
        mp.freeze_support()
        fix_path()
        print('BEGIN ALIGN')
        for a in train_args:
            dict_data = benchmark_align_corpus(a)
            if not dict_data:
                continue

            with open(benchmark_path, 'a', newline='', encoding='utf8') as csv_file:
                writer = csv.DictWriter(csv_file, fieldnames=csv_columns)
                writer.writerow(dict_data)
    finally:
        unfix_path()