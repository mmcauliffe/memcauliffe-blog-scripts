import os
import shutil
import wave
from collections import defaultdict
from statistics import mean

#directories = [r'D:\Data\aligner_comp\organized']
directories = ['/media/share/datasets/aligner_benchmarks/AlignerTestData/1_English_13000files',
                '/data/mmcauliffe/data/LibriSpeech/clean']

for d in directories:
    print(d)
    total_duration = 0
    speaker_durations = defaultdict(float)

    for root, dirs, files in os.walk(d):
        for f in files:
            if not f.lower().endswith('.wav'):
                continue
            speaker = os.path.basename(root)
            with wave.open(os.path.join(root, f), 'rb') as wavef:
                sr = wavef.getframerate()
                nframe = wavef.getnframes()
                duration = nframe / sr
                total_duration += duration
                speaker_durations[speaker] += duration

    print('Total:', total_duration / 60)
    print('Mean per speaker:', mean(speaker_durations.values())/60)
