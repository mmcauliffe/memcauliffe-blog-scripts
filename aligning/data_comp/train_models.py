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

os.makedirs(output_directory, exist_ok=True)

benchmark_path = r'/mnt/d/Data/speech/benchmark_datasets/buckeye/smalls/benchmark.csv'

sys.path.insert(0, MFA_REPO_PATH)

from montreal_forced_aligner.command_line.mfa import run_train_corpus, fix_path, unfix_path

csv_columns = ['Name', 'Computer', 'Date', 'Corpus', 'Acoustic model', 'Type of benchmark', 'Final log-likelihood', 'Total time', 'Num_jobs']
now = datetime.now()
date = str(now.year) + str(now.month) + str(now.day)

if not os.path.exists(benchmark_path):
    with open(benchmark_path, 'w', newline='', encoding='utf8') as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=csv_columns)
        writer.writeheader()


class TrainDummyArgs(object):
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
        self.output_model_path = None
        self.config_path = None
        self.audio_directory = None


def benchmark_train_corpus(arg):
    if not DEBUG_MODE and os.path.exists(arg.output_model_path):
        return
    beg = time.time()
    run_train_corpus(arg)
    corpus_name = os.path.basename(arg.corpus_directory)
    train_log_path = os.path.join(arg.temp_directory, corpus_name, 'train_and_align.log')
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


train_setups = os.listdir(root_dir)

train_args = []
for identifier in train_setups:
    a = TrainDummyArgs()
    a.dictionary_path = '/mnt/d/Data/speech/esports/esports_dict.txt'
    a.corpus_directory = os.path.join(root_dir, identifier)
    a.output_directory = os.path.join(output_directory, 'tgs', identifier)
    a.output_model_path = os.path.join(output_directory, identifier +'.zip')
    if os.path.exists(a.output_model_path):
        continue
    train_args.append(a)


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