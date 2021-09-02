import os
import subprocess
import sys
import shutil
import socket
import time
import logging
import platform
import csv
from datetime import datetime
import multiprocessing as mp

fave_path = r'FAAValign.py'
fave_dir = r'D:\Dev\GitHub\FAVE\FAVE-align'

dictionary_path = r'D:\Data\aligner_comp\dictionaries\fave.dictionary'

corpus_dir = r'D:\Data\aligner_comp\phonsay\organized'

out_dir = r'D:\Data\aligner_comp\phonsay\fave'


num_jobs = 5

def align_func(wav_path, trans_path, tg_path):
    proc = subprocess.Popen(['python',fave_path, '-n',
                            '-d', dictionary_path,
                            wav_path, trans_path, tg_path], cwd = fave_dir, stderr = subprocess.PIPE, stdout = subprocess.PIPE)
    stdout, stderr = proc.communicate()
    rc = proc.returncode
    if rc != 0 :
        if 'Alignment failed' not in stderr:
            print(stderr)
            raise Exception

def benchmark_align_corpus():
    beg = time.time()
    args = []
    ignored = 0
    not_ignored = 0
    tgs = []
    for root, dirs, files in os.walk(corpus_dir):
        for f in sorted(files):
            if not f.endswith('.wav'):
                continue
            #print(f)
            wav_path = os.path.join(root, f)
            trans_path = wav_path.replace('.wav', '.txt')
            tg_path = wav_path.replace('.wav', '_fave.TextGrid')
            tgs.append(tg_path)
            if os.path.exists(tg_path):
                ignored += 1
                continue
            not_ignored += 1
            args.append((wav_path, trans_path, tg_path))
    print(ignored, not_ignored)
    pool = mp.Pool(processes=num_jobs)
    results = [pool.apply_async(align_func, args=i) for i in args]
    output = [p.get() for p in results]
    for p in tgs:
        new_p = p.replace(corpus_dir, out_dir)
        d = os.path.dirname(new_p)
        if not os.path.exists(d):
            os.makedirs(d)
        shutil.move(p, new_p)
    end = time.time()
    dict_data = {'Computer': platform.node(),
                'Date': str(datetime.now()),
                'Corpus': corpus_dir,
                'Type of benchmark': 'fave',
                'Total time': end - beg,
                'Num_jobs': 1}

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

