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


class AdaptDummyArgs(Namespace):
    def __init__(self):
        self.num_jobs = 12
        self.speaker_characters = 0
        self.verbose = False
        self.clean = not DEBUG_MODE
        self.debug = False
        self.full_train = False
        self.corpus_directory = corpus_dir
        self.output_model_path = None
        self.output_directory = None
        self.dictionary_path = 'english'
        self.temp_directory = temp_dir
        self.config_path = None
        self.audio_directory = None
        self.disable_mp = False
        self.overwrite = True
        self.disable_textgrid_cleanup = False


class TrainDummyArgs(Namespace):
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
        self.audio_directory = None
        self.disable_mp = False
        self.overwrite = True
        self.disable_textgrid_cleanup = False


align_setups = [
    {'identifier': 'mfa_english_ipa', 'acoustic_model_path': r"D:\Data\speech\english_ipa.zip", 'dictionary_path': r"D:\Data\speech\esports\esports_dict.txt"},
    {'identifier': 'mfa_english', 'acoustic_model_path': 'english', 'dictionary_path': 'english'},
{'identifier': 'mfa_english_2', 'acoustic_model_path': r'D:\Data\speech\english_2.zip', 'dictionary_path': 'english'},
{'identifier': 'mfa_english_ipa_2', 'acoustic_model_path': r'D:\Data\speech\english_ipa_2.zip', 'dictionary_path': r"D:\Data\speech\esports\esports_dict.txt"},
{'identifier': 'mfa_english_ml_ipa_2', 'acoustic_model_path': r'D:\Data\speech\english_ml_ipa_2.zip', 'dictionary_path': r"D:\Data\speech\esports\esports_dict.txt"},
]

align_args = []
for setup in align_setups:
    a = AlignDummyArgs()
    a.acoustic_model_path = setup['acoustic_model_path']
    a.dictionary_path = setup['dictionary_path']
    a.output_directory = os.path.join(output_directory, setup['identifier'])
    align_args.append(a)


train_setups = [
    {'identifier': 'mfa_default_train', 'dictionary_path': 'english'},
    {'identifier': 'mfa_ipa_train', 'dictionary_path': r"D:\Data\speech\esports\esports_dict.txt"},
]

train_args = []
for setup in train_setups:
    a = TrainDummyArgs()
    a.dictionary_path = setup['dictionary_path']
    a.output_directory = os.path.join(output_directory, setup['identifier'])
    a.output_model_path = None
    train_args.append(a)


adapt_setups = [
    {
        'identifier': 'mfa_english_adapt',
        'acoustic_model_path': 'english',
        'full_train': True,
        'dictionary_path': 'english'},
    {
        'identifier': 'mfa_english_2_adapt',
        'acoustic_model_path': r'D:\Data\speech\english_2.zip',
        'full_train': True,
        'dictionary_path': 'english'},
    {
        'identifier': 'mfa_english_ipa_2_adapt',
        'acoustic_model_path': r'D:\Data\speech\english_ipa_2.zip',
        'full_train': True,
        'dictionary_path': r"D:\Data\speech\esports\esports_dict.txt"},
    {
        'identifier': 'mfa_english_ipa_adapt',
        'acoustic_model_path': r'D:\Data\speech\english_ipa.zip',
        'full_train': True,
        'dictionary_path': r'D:\Data\speech\esports\esports_dict.txt'},
    {
        'identifier': 'mfa_english_ml_ipa_2_adapt',
        'acoustic_model_path': r'D:\Data\speech\english_ml_ipa_2.zip',
        'full_train': True,
        'dictionary_path': r'D:\Data\speech\esports\esports_dict.txt'
    },
    {
        'identifier': 'mfa_english_adapt_mapped',
        'acoustic_model_path': 'english',
        'full_train': False,
        'dictionary_path': 'english'},
    {
        'identifier': 'mfa_english_2_adapt_mapped',
        'acoustic_model_path': r'D:\Data\speech\english_2.zip',
        'full_train': False,
        'dictionary_path': 'english'},
    {
        'identifier': 'mfa_english_ipa_2_adapt_mapped',
        'acoustic_model_path': r'D:\Data\speech\english_ipa_2.zip',
        'full_train': False,
        'dictionary_path': r"D:\Data\speech\esports\esports_dict.txt"},
    {
        'identifier': 'mfa_english_ipa_adapt_mapped',
        'acoustic_model_path': r'D:\Data\speech\english_ipa.zip',
        'full_train': False,
        'dictionary_path': r'D:\Data\speech\esports\esports_dict.txt'},
    {
        'identifier': 'mfa_english_ml_ipa_2_adapt_mapped',
        'acoustic_model_path': r'D:\Data\speech\english_ml_ipa_2.zip',
        'full_train': False,
        'dictionary_path': r'D:\Data\speech\esports\esports_dict.txt'
    },
]

adapt_args = []
for setup in adapt_setups:
    adapt_a = AdaptDummyArgs()
    adapt_a.acoustic_model_path = setup['acoustic_model_path']
    adapt_a.dictionary_path = setup['dictionary_path']
    adapt_a.full_train = setup['full_train']
    adapt_a.output_model_path = os.path.join(output_directory, setup['identifier'] + '_adapted.zip')
    a = AlignDummyArgs()
    a.acoustic_model_path = adapt_a.output_model_path
    a.dictionary_path = setup['dictionary_path']
    a.output_directory = os.path.join(output_directory, setup['identifier'])
    adapt_args.append((adapt_a, a))

sys.path.insert(0, MFA_REPO_PATH)

from montreal_forced_aligner.command_line.mfa import run_align_corpus, run_adapt_model, run_train_corpus, fix_path, unfix_path


def benchmark_align_corpus(arg):
    if not DEBUG_MODE and os.path.exists(arg.output_directory):
        return
    beg = time.time()
    run_align_corpus(arg)
    align_log_path = os.path.join(arg.temp_directory, 'prosodylab_format', 'align.log')
    final_log_like = None
    with open(align_log_path, 'r', encoding='utf8') as f:
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
        'Acoustic model': arg.acoustic_model_path,
        'Type of benchmark': 'align',
        'Total time': end - beg,
        'Final log-likelihood': final_log_like,
        'Num_jobs': arg.num_jobs}

    return dict_data


def benchmark_adapt_corpus(adapt_arg, align_arg):
    if not DEBUG_MODE and os.path.exists(align_arg.output_directory):
        return
    beg = time.time()
    run_adapt_model(adapt_arg)
    run_align_corpus(align_arg)
    align_log_path = os.path.join(align_arg.temp_directory, 'prosodylab_format', 'align.log')
    final_log_like = None
    with open(align_log_path, 'r', encoding='utf8') as f:
        for line in f:
            m = re.search(r'\(this might not actually mean anything\): (-[\d.]+)', line)
            if m:
                final_log_like = m.groups()[0]
    end = time.time()
    dict_data = {
        'Name': os.path.basename(align_arg.output_directory),
        'Computer': platform.node(),
        'Date': date,
        'Corpus': 'Buckeye',
        'Acoustic model': align_arg.acoustic_model_path,
        'Type of benchmark': 'adapt',
        'Total time': end - beg,
        'Final log-likelihood': final_log_like,
        'Num_jobs': align_arg.num_jobs}

    return dict_data


def benchmark_train_corpus(arg):
    if not DEBUG_MODE and os.path.exists(arg.output_directory):
        return
    beg = time.time()
    run_train_corpus(arg)
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
        print('BEGIN ALIGN')
        for a in align_args:
            dict_data = benchmark_align_corpus(a)
            if not dict_data:
                continue

            with open(benchmark_path, 'a', newline='', encoding='utf8') as csv_file:
                writer = csv.DictWriter(csv_file, fieldnames=csv_columns)
                writer.writerow(dict_data)
            #error
        print('BEGIN ADAPT')
        for a in adapt_args:
            dict_data = benchmark_adapt_corpus(*a)
            if not dict_data:
                continue

            with open(benchmark_path, 'a', newline='', encoding='utf8') as csv_file:
                writer = csv.DictWriter(csv_file, fieldnames=csv_columns)
                writer.writerow(dict_data)
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
