import os
import sys
import shutil

orig_dir = r'/data/mmcauliffe/data/LibriSpeech'

output_dir = r'/data/mmcauliffe/data/LibriSpeech_for_pla'

os.makedirs(output_dir, exist_ok = True)

dict_path = r'/data/mmcauliffe/data/LibriSpeech/pla.dictionary'

words = set()

with open(dict_path, 'r', encoding = 'utf8') as f:
    for line in f:
        words.add(line.split()[0])

print(len(words))

for root, dirs, files in os.walk(orig_dir):
    for f in files:
        if not f.endswith('.wav'):
            continue
        wav_path = os.path.join(root, f)
        lab_path = wav_path.replace('.wav', '.lab')
        lab_words = set()
        with open(lab_path, 'r') as labf:
            for line in labf:
                line = line.strip()
                lab_words.update(x for x in line.split() if x)
        diff = lab_words - words
        if diff:
            print(lab_path, diff)
            continue
        new_wav_path = os.path.join(output_dir, f)
        shutil.copyfile(wav_path, new_wav_path)
        shutil.copyfile(lab_path, new_wav_path.replace('.wav', '.lab'))
