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

pla_dir = r'D:\Dev\GitHub\Prosodylab-Aligner'

dictionary_path = r'D:\Data\aligner_comp\dictionaries\pla.dictionary'

model_path = r'D:\Data\aligner_comp\models\pla\ls-model.zip'

corpus_dir = r'D:\Data\VIC\prosodylab_format'

num_jobs = 5

def align_func(d):
    proc = subprocess.Popen(['python', '-m', 'aligner', '-r', model_path,
                            '-d', dictionary_path,
                            '-a', d], cwd = pla_dir, stderr = subprocess.PIPE, stdout = subprocess.PIPE)
    stdout, stderr = proc.communicate()
    rc = proc.returncode
    if rc != 0 :
        print(stderr.decode('utf8'))
        raise Exception

def benchmark_align_corpus():
    beg = time.time()
    args = []
    ignored = 0
    not_ignored = 0
    for d in os.listdir(corpus_dir):

        args.append((os.path.join(corpus_dir,d), ))
    print(ignored, not_ignored)
    pool = mp.Pool(processes=num_jobs)
    results = [pool.apply_async(align_func, args=i) for i in args]
    output = [p.get() for p in results]
    end = time.time()
    dict_data = {'Computer': platform.node(),
                'Date': str(datetime.now()),
                'Corpus': corpus_dir,
                'Type of benchmark': 'fave buckeye',
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

