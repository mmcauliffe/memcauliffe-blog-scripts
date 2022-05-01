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
from argparse import Namespace

host = socket.gethostname()

DEBUG_MODE = False

csv_columns = ['Name', 'Computer', 'Date', 'Corpus', 'Acoustic model', 'Type of benchmark', 'Pre-fmllr log-likelihood', 'Final log-likelihood', 'Total time',
               'Fmllr time', 'Num_jobs', 'Disable MP', 'Blas num threads']

if sys.platform != 'win32':
    MFA_REPO_PATH = '/mnt/c/Users/michael/Documents/Dev/Montreal-Forced-Aligner'
    corpus_dir = '/mnt/d/Data/speech/benchmark_datasets/buckeye/prosodylab_format'
    output_directory = '/mnt/d/Data/speech/benchmark_datasets/buckeye/aligner_comp/blas_num_threads'
    temp_dir = '/mnt/d/Data/speech/benchmark_datasets/buckeye/temp'
    benchmark_path = '/mnt/d/Data/speech/benchmark_datasets/buckeye/aligner_comp/blas_num_threads/benchmark.csv'
    prefix = 'WSL'
    model_path = '/mnt/d/temp/english_ipa_2.0.zip'
    dict_path = '/mnt/d/Data/speech/esports/esports_dict.txt'
else:
    MFA_REPO_PATH = r'C:\Users\michael\Documents\Dev\Montreal-Forced-Aligner'
    corpus_dir = r'D:\Data\speech\benchmark_datasets\buckeye\prosodylab_format'
    output_directory = r'D:\Data\speech\benchmark_datasets\buckeye\aligner_comp\blas_num_threads'
    temp_dir = r'D:\Data\speech\benchmark_datasets\buckeye\temp'
    prefix = 'WIN'
    benchmark_path = r'D:\Data\speech\benchmark_datasets\buckeye\aligner_comp\blas_num_threads\benchmark.csv'
    model_path = r"D:\temp\english_ipa_2.0.zip"
    dict_path = r"D:\Data\speech\esports\esports_dict.txt"

now = datetime.now()
date = str(now.year) + str(now.month) + str(now.day)

os.makedirs(output_directory, exist_ok=True)

if not os.path.exists(benchmark_path):
    with open(benchmark_path, 'w', newline='', encoding='utf8') as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=csv_columns)
        writer.writeheader()


class AlignDummyArgs(Namespace):
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
        self.audio_directory = None
        self.disable_mp = False
        self.overwrite = True
        self.disable_textgrid_cleanup = False

sys.path.insert(0, MFA_REPO_PATH)

from montreal_forced_aligner.command_line.mfa import run_align_corpus, run_adapt_model, run_train_corpus


def benchmark_align_corpus(num_threads, disable_mp):
    arg = AlignDummyArgs()
    if disable_mp:
        identifier = f'{prefix}_no_mp_{num_threads}_threads'
    else:
        identifier = f'{prefix}_use_mp_{num_threads}_threads'
    arg.acoustic_model_path = model_path
    arg.dictionary_path = dict_path
    arg.output_directory = os.path.join(output_directory, identifier)
    arg.disable_mp = disable_mp
    if not DEBUG_MODE and os.path.exists(arg.output_directory):
        return
    beg = time.time()
    os.environ['OPENBLAS_NUM_THREADS'] = f'{num_threads}'
    os.environ['MKL_NUM_THREADS'] = f'{num_threads}'
    run_align_corpus(arg)
    align_log_path = os.path.join(arg.temp_directory, 'prosodylab_format', 'align.log')
    initial_log_like = None
    final_log_like = None
    fmllr_time = None
    with open(align_log_path, 'r', encoding='utf8') as f:
        for line in f:
            m = re.search(r'Prior to SAT, .*\(this might not actually mean anything\): (-[\d.]+)', line)
            if m:
                initial_log_like = m.groups()[0]
            m = re.search(r'Following SAT, .*\(this might not actually mean anything\): (-[\d.]+)', line)
            if m:
                final_log_like = m.groups()[0]
            m = re.search(r'Fmllr calculation took ([\d.]+)', line)
            if m:
                fmllr_time = float(m.groups()[0])
    end = time.time()
    dict_data = {
        'Name': os.path.basename(arg.output_directory),
        'Computer': platform.node(),
        'Date': date,
        'Corpus': 'Buckeye',
        'Acoustic model': arg.acoustic_model_path,
        'Type of benchmark': 'align',
        'Total time': end - beg,
        'Fmllr time': fmllr_time,
        'Disable MP': disable_mp,
        'Blas num threads': num_threads,
        'Pre-fmllr log-likelihood': initial_log_like,
        'Final log-likelihood': final_log_like,
        'Num_jobs': arg.num_jobs}

    return dict_data


if __name__ == '__main__':
    mp.freeze_support()
    print('BEGIN ALIGN')
    for num_threads in range(1, 6):
        for mp_flag in [True, False]:
            dict_data = benchmark_align_corpus(num_threads, mp_flag)
            if not dict_data:
                continue

            with open(benchmark_path, 'a', newline='', encoding='utf8') as csv_file:
                writer = csv.DictWriter(csv_file, fieldnames=csv_columns)
                writer.writerow(dict_data)