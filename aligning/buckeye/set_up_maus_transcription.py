import os
import shutil
corpus_dir = r'D:\Data\speech\benchmark_datasets\buckeye\prosodylab_format'
maus_directory = r'D:\Data\speech\benchmark_datasets\buckeye\maus_format'


for root, dirs, files in os.walk(corpus_dir):
    for f in sorted(files):
        if not f.endswith('.lab'):
            continue
        lab_path = os.path.join(root, f)
        out_path = lab_path.replace('.lab', '.txt').replace(corpus_dir, maus_directory)
        os.makedirs(os.path.dirname(out_path), exist_ok=True)
        shutil.copyfile(lab_path, out_path)