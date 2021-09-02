import os
import wave

corpus_dir = r'D:\Data\aligner_comp\phonsay\organized'

for root, dirs, files in os.walk(corpus_dir):
    for f in files:
        if not f.endswith('.lab'):
            continue
        name, _ = os.path.splitext(f)
        wav_path = os.path.join(root, name + '.wav')
        with wave.open(wav_path, 'rb') as wf:
            duration = wf.getnframes() / wf.getframerate()
        with open(os.path.join(root,f), 'r') as inf:
            transcription = inf.read().strip().replace("'", '').replace('.','')
        speaker = os.path.basename(root)
        trans_path = os.path.join(root, name + '.txt')
        with open(trans_path, 'w') as outf:
            outf.write('{}\t{}\t0\t{}\t{}'.format(speaker, speaker, duration, transcription))
