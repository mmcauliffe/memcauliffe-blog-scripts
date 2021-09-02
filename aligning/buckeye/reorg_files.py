
import os
import shutil


orig = r'D:\Data\VIC\prosodylab_format'

fave_dir = r'D:\Data\aligner_comp\buckeye\fave'

pla_dir = r'D:\Data\aligner_comp\buckeye\pla-flat'

for root, dirs, files in os.walk(orig):
    for f in sorted(files):
        if not f.endswith('.TextGrid'):
            continue
        speaker = os.path.basename(root)
        fave_speaker_dir = os.path.join(fave_dir, speaker)
        os.makedirs(fave_speaker_dir, exist_ok=True)

        pla_speaker_dir = os.path.join(pla_dir, speaker)
        os.makedirs(pla_speaker_dir, exist_ok=True)

        if f.endswith('_fave.TextGrid'):
            shutil.move(os.path.join(root, f), os.path.join(fave_speaker_dir, f))
        else:
            shutil.move(os.path.join(root, f), os.path.join(pla_speaker_dir, f))

ref_dir = r'D:\Data\aligner_comp\buckeye\reference'

files = os.listdir(ref_dir)

for f in files:
    if not f.endswith('.TextGrid'):
        continue
    speaker = f[:3]
    speaker_dir = os.path.join(ref_dir, speaker)
    os.makedirs(speaker_dir, exist_ok =True)
    shutil.move(os.path.join(ref_dir, f), os.path.join(speaker_dir, f))
