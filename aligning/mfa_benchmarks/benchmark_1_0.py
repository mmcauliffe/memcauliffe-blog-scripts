import os
import subprocess
import json
import time

root_dir = r'D:\Data\experiments\alignment_benchmarking'
timit_dir = r'D:\Data\speech\benchmark_datasets\timit'
buckeye_dir = r'D:\Data\speech\Buckeye'

mfa10_dir = os.path.join(root_dir, 'montreal-forced-aligner_101')
mfa_path = os.path.join(mfa10_dir, 'bin', 'mfa_align.exe')
dictionary_path = os.path.join(mfa10_dir, 'pretrained_models', 'english.dict')
model_path = os.path.join(mfa10_dir, 'pretrained_models', 'english.zip')
benchmarks = {}
benchmark_path = os.path.join(root_dir, 'benchmarks.json')
if os.path.exists(benchmark_path):
    with open(benchmark_path, 'r', encoding='utf8') as f:
        benchmarks = json.load(f)
# Buckeye
begin = time.time()

output_dir = os.path.join(root_dir, 'alignments', 'mfa_101_alignments', 'buckeye')
if not os.path.exists(output_dir):
    subprocess.check_call([mfa_path, os.path.join(buckeye_dir, 'benchmark'),
                           dictionary_path,model_path, output_dir, '-j', '10', '-q',
                               '--beam', '20',
                           '--clean', '-t', os.path.join(root_dir, 'temp')])
    total_time = time.time() - begin
    benchmarks['mfa_10_buckeye'] = {}
    benchmarks['mfa_10_buckeye']['time'] = total_time

    with open(benchmark_path, 'w', encoding='utf8') as f:
        json.dump(benchmarks, f)

output_dir = os.path.join(root_dir, 'alignments', 'mfa_101_alignments', 'timit')
if not os.path.exists(output_dir):
    subprocess.check_call([mfa_path, os.path.join(timit_dir, 'benchmark'),
                           dictionary_path,model_path, output_dir, '-j', '10', '-q',
                           '--clean', '-t', os.path.join(root_dir, 'temp')])
    total_time = time.time() - begin
    benchmarks['mfa_10_timit'] = {}
    benchmarks['mfa_10_timit']['time'] = total_time

    with open(benchmark_path, 'w', encoding='utf8') as f:
        json.dump(benchmarks, f)