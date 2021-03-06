import sys
import shutil, os
import socket
import time
import logging
import platform
import csv
import statistics
from datetime import datetime

host = socket.gethostname()

class DummyArgs(object):
    def __init__(self):
        self.num_jobs = 12
        self.fast = False
        self.speaker_characters = 0
        self.verbose = False
        self.clean = True
        self.no_speaker_adaptation = True
        self.debug = False

args = DummyArgs()

if host == 'michael-laptop':
    MFA_REPO_PATH = r'D:\Dev\GitHub\Montreal-Forced-Aligner'
    corpus_dir = r'D:\Data\VIC\prosodylab_format'
    output_directory = r'D:\Data\aligner_comp\buckeye_mfa_librispeech'
    temp_dir = r'D:\Data\aligner_comp\temp\MFA'
    model_path = r'D:\Dev\GitHub\aligner-comparison\aligning\librispeech_models.zip'
    args.num_jobs = 4
elif host == 'roquefort':
    MFA_REPO_PATH = '/data/mmcauliffe/dev/Montreal-Forced-Aligner'
    corpus_dir = '/media/share/corpora/LS21'
    dict_path = '/data/mmcauliffe/data/LibriSpeech/librispeech-lexicon.txt'
    output_directory = '/data/mmcauliffe/aligner-output/LS21'
    model_path = r'/data/mmcauliffe/aligner-models/ls21_models.zip'
    temp_dir = '/data/mmcauliffe/temp/MFA'

sys.path.insert(0, MFA_REPO_PATH)


from aligner.command_line.train_and_align import align_corpus


def benchmark_align_corpus():
    beg = time.time()
    align_corpus(corpus_dir, dict_path, output_directory, temp_dir, model_path, args)
    end = time.time()
    dict_data = {'Computer': platform.node(),
                'Date': str(datetime.now()),
                'Corpus': corpus_dir,
                'Type of benchmark': 'align english',
                'Total time': end - beg,
                'Num_jobs': args.num_jobs}

    return dict_data

def WriteDictToCSV(csv_file,csv_columns,dict_data):
        with open(csv_file, 'w') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=csv_columns)
            writer.writeheader()
            for data in dict_data:
                writer.writerow(data)

if __name__ == '__main__':
    dict_data = benchmark_align_corpus()

    csv_columns = ['Computer','Date','Corpus', 'Type of benchmark', 'Total time', 'Num_jobs']

    now = datetime.now()
    date = str(now.year)+str(now.month)+str(now.day)

    if not os.path.exists('aligner_benchmark'+date+'.csv'):
        with open('aligner_benchmark'+date+'.csv', 'w') as csv_file:
            writer = csv.DictWriter(csv_file, fieldnames=csv_columns)
            writer.writeheader()

    csv_file = 'aligner_benchmark'+date+'.csv'

    with open('aligner_benchmark'+date+'.csv', 'a') as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=csv_columns)
        writer.writerow(dict_data)
