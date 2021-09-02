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
fave_dir = r'C:\Users\michael\Documents\Dev\Tools\FAVE\FAVE-align'

dictionary_path = r'D:\Data\speech\benchmark_datasets\buckeye\fave.dictionary'
oov_path = r'D:\Data\speech\benchmark_datasets\buckeye\fave_oov.txt'

corpus_dir = r'D:\Data\speech\benchmark_datasets\buckeye\prosodylab_format'
output_dir = r'D:\Data\speech\benchmark_datasets\buckeye\aligner_comp\fave'
benchmark_path = r'D:\Data\speech\benchmark_datasets\benchmark.csv'

num_jobs = 12

now = datetime.now()
date = str(now.year) + str(now.month) + str(now.day)

look_for_oovs = False
oovs = set()

def align_func(wav_path, trans_path, tg_path):
    output_path = wav_path.replace('.wav', '.dict')
    proc = subprocess.Popen(['python',fave_path, '-n',
                            #'-d', dictionary_path,
                            wav_path, trans_path, tg_path], cwd = fave_dir, stderr = subprocess.PIPE, stdout = subprocess.PIPE, text=True)
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
    for root, dirs, files in os.walk(corpus_dir):
        for f in sorted(files):
            if not f.endswith('.wav'):
                continue
            wav_path = os.path.join(root, f)
            if look_for_oovs:
                dict_path = wav_path.replace('.wav', '.dict')
                with open(dict_path, 'r', encoding='utf8') as inf:
                    for line in inf:
                        line = line.strip()
                        line = line.split()[0]
                        oovs.add(line)
                continue
            #print(f)
            trans_path = wav_path.replace('.wav', '.txt')
            old_tg_path = wav_path.replace('.wav', '_fave.TextGrid')
            tg_path = wav_path.replace(corpus_dir, output_dir).replace('.wav', '.TextGrid')
            dir_name = os.path.dirname(tg_path)
            os.makedirs(dir_name, exist_ok=True)
            if os.path.exists(old_tg_path):
                shutil.move(old_tg_path, tg_path)
            if os.path.exists(tg_path):
                ignored += 1
                continue
            not_ignored += 1
            args.append((wav_path, trans_path, tg_path))
    if oovs:
        with open(oov_path, 'w', encoding='utf8') as f:
            for word in sorted(oovs):
                f.write(f'{word}\n')
            error
    print(ignored, not_ignored)
    pool = mp.Pool(processes=num_jobs)
    results = [pool.apply_async(align_func, args=i) for i in args]
    output = [p.get() for p in results]
    end = time.time()
    dict_data = {'Name':'fave',
        'Computer': platform.node(),
                'Date': date,
                'Corpus': corpus_dir,
                'Acoustic model': 'fave',
                'Type of benchmark': 'fave buckeye',
                'Final log-likelihood': 'N/A',
                'Total time': end - beg,
                'Num_jobs': num_jobs}

    return dict_data

def WriteDictToCSV(csv_file,csv_columns,dict_data):
        with open(csv_file, 'w') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=csv_columns)
            writer.writeheader()
            for data in dict_data:
                writer.writerow(data)

csv_columns = ['Name', 'Computer', 'Date', 'Corpus', 'Acoustic model', 'Type of benchmark', 'Final log-likelihood', 'Total time', 'Num_jobs']

if __name__ == '__main__':
    mp.freeze_support()
    dict_data = benchmark_align_corpus()

    with open(benchmark_path, 'a', newline='', encoding='utf8') as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=csv_columns)
        writer.writerow(dict_data)


