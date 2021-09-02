import os
import random

root_dir = '/mnt/d/Data/speech/benchmark_datasets/buckeye'

corpus_dir = os.path.join(root_dir, 'prosodylab_format')
output_dir = os.path.join(root_dir, 'smalls')
inverse_output_dir = os.path.join(root_dir, 'inverse_smalls')

num_variants = 5

speakers = os.listdir(corpus_dir)

subsets = {x: set() for x in range(1,len(speakers))}

for speaker_count in range(1,len(speakers)):
    print(speaker_count)
    while len(subsets[speaker_count]) < num_variants:
        random_set = random.sample(speakers, speaker_count)
        random_set = tuple(sorted(random_set))
        if random_set in subsets[speaker_count]:
            continue
        subsets[speaker_count].add(random_set)
    print(len(subsets[speaker_count]))

for k, v in subsets.items():
    print(k)
    for j, v2 in enumerate(v):
        ident = f'{k}_{j}'
        out_dir = os.path.join(output_dir, ident)
        inverse_out_dir = os.path.join(inverse_output_dir, ident)
        if os.path.exists(out_dir):
            if os.path.exists(inverse_out_dir):
                continue
            os.makedirs(inverse_out_dir, exist_ok=True)
            included = os.listdir(out_dir)
            inverse = [x for x in speakers if x not in included]
            for s in inverse:
                os.symlink(os.path.join(corpus_dir, s), os.path.join(inverse_out_dir, s))

            continue
        os.makedirs(out_dir, exist_ok=True)
        print(v2)
        for s in v2:
            os.symlink(os.path.join(corpus_dir, s), os.path.join(out_dir, s))