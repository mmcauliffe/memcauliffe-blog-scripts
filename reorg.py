import os
import shutil

from textgrid import TextGrid, IntervalTier

# Fixed (removed blank intervals) phon2_105_1_3, say_213_12_2_1, say_231_2_3_1,
# phon2_315_6_1, phon2_330_2_4, phon2_336_2_2, say_216_3_2_1, say_225_13_1_1, say_216_19_1_1,
# say_216_1_1_1

data_dir = r'D:\Data\aligner_comp'

orig_dir = os.path.join(data_dir, 'original')
org_dir = os.path.join(data_dir, 'organized')

def write_lab_file(path, label):
    with open(path, 'w', encoding = 'utf8') as f:
        f.write(label)

for f in os.listdir(orig_dir):
    name, ext = os.path.splitext(f)
    sp = name.split('_')
    speaker_id = '_'.join(sp[:2])
    speaker_dir = os.path.join(org_dir, speaker_id)
    os.makedirs(speaker_dir, exist_ok = True)
    old_path = os.path.join(orig_dir, f)
    print(old_path)
    new_path = os.path.join(speaker_dir, f)
    if ext == '.wav':
        shutil.copyfile(old_path, new_path)
    elif ext == '.TextGrid':
        tg = TextGrid()
        tg.read(old_path)
        annotation_tier = IntervalTier(name = 'annotation', maxTime = tg.maxTime)
        for i, ti in enumerate(tg.tiers):
            if ti.name == 'word':
                label = ' '.join([x.mark for x in ti if x.mark != 'sil'])
            elif ti.name == 'label':
                label = ti[0].mark
            elif ti.name == 'annotation':
                mintime = None
                maxtime = None
                for interval in ti:
                    mark = interval.mark.strip().lower()
                    if mark == 'son':
                        mark = 'con'
                    if mark in ['', 'v', 'con']:
                        if mintime is not None:
                            annotation_tier.add(mintime, maxtime, 'con')
                        annotation_tier.add(interval.minTime, interval.maxTime, mark)
                    elif mark == 'cd':
                        mintime = interval.minTime
                        maxtime = interval.maxTime
                    elif mark in ['vot', 'rel']:
                        if mintime is None:
                            mintime = interval.minTime
                        maxtime = interval.maxTime
                        annotation_tier.add(mintime, maxtime, 'con')
                        mintime = None
                        maxtime = None
        write_lab_file(new_path.replace('.TextGrid','.lab'), label)
        ntg = TextGrid(maxTime = tg.maxTime)
        ntg.append(annotation_tier)
        ntg.write(new_path)
