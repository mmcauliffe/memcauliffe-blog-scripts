import os
import csv
from textgrid import TextGrid, IntervalTier

base_dir = r'D:\Data\aligner_comp\phonsay'
to_compare = ['mfa_flat', 'mfa_librispeech', 'mfa_librispeech_clean',
                'prosodylab_librispeech_clean', 'prosodylab_flat', 'prosodylab_lab_models', 'lab_models','fave']

annotated = os.path.join(base_dir, 'organized')
ignored = ['please','say','again', '', '<unk>', 'l', 'sp','sil']
header = ['word', 'speaker', 'file', 'aligner', 'data', 'type', 'vowel', 'prec_consonant', 'foll_consonant', 'diff', 'norm_dur', 'reference_time']
with open('results.txt', 'w', newline = '') as outf:
    writer = csv.writer(outf)
    writer.writerow(header)
    for root, dirs, files in os.walk(annotated):
        for f in sorted(files):
            name, ext = os.path.splitext(f)
            if ext != '.TextGrid':
                continue
            print(name)
            speaker = os.path.basename(root)
            tg = TextGrid()
            tg.read(os.path.join(root, f))
            v_beg = None
            v_end = None
            c_end = None
            for x in tg.tiers[0]:
                if x.mark == 'v':
                    v_beg = x.minTime
                    v_end = x.maxTime
                elif x.mark == 'con':
                    c_end = x.maxTime
            if any (x is None for x in [v_beg, v_end, c_end]):
                continue
            anno_vow_dur = v_end - v_beg
            anno_cons_dur = c_end - v_end
            for c in to_compare:
                c_dir = os.path.join(base_dir, c)
                ntg = TextGrid()
                if 'prosodylab' in c:
                    ntg.read(os.path.join(c_dir, f))

                    i = [x for x in ntg.tiers[1] if x.mark.lower() not in ignored][-1]
                    norm_dur = sum([x.maxTime - x.minTime for x in ntg.tiers[1] if x.mark.lower() in ['please', 'say']])
                    intervals = [x for x in ntg.tiers[0] if x.minTime < i.maxTime and x.maxTime > i.minTime]

                else:
                    if c == 'fave':
                        f = f.replace('.TextGrid','_fave.TextGrid')
                        word_tier = 1
                        phone_tier = 0
                    else:
                        word_tier = 0
                        phone_tier = 1
                    ntg.read(os.path.join(c_dir, speaker, f))
                    #print([x for x in ntg.tiers[word_tier]])
                    #print([x for x in ntg.tiers[word_tier] if x.mark.lower() not in ignored])
                    i = [x for x in ntg.tiers[word_tier] if x.mark.lower() not in ignored][-1]
                    norm_dur = sum([x.maxTime - x.minTime for x in ntg.tiers[word_tier] if x.mark.lower() in ['please', 'say']])
                    intervals = [x for x in ntg.tiers[phone_tier] if x.minTime < i.maxTime and x.maxTime > i.minTime]
                #print(f, i)
                word = i.mark.lower()
                if 'phon2' in speaker:
                    vow_ind = -4
                    cons_ind = -3
                    prev_ind = -5
                    if 'prosodylab' in c and word == 'dapple':
                        vow_ind += 1
                        cons_ind += 1
                        prev_ind += 1
                else:
                    vow_ind = -2
                    cons_ind = -1
                    prev_ind = -3
                if 'prosodylab' in c:
                    aligner = 'prosodylab'
                else:
                    aligner = 'mfa'
                if 'flat' in c:
                    data = 'flat'
                elif 'clean' in c:
                    data = 'librispeech-clean'
                elif 'librispeech' in c:
                    data = 'librispeech'
                elif c == 'fave':
                    data = 'SCOTUS'
                    aligner = 'fave'
                else:
                    data = 'lab'
                nv_beg = intervals[vow_ind].minTime
                nv_end = intervals[vow_ind].maxTime
                #print(c, nv_end, v_end - nv_end)
                nc_end = intervals[cons_ind].maxTime
                cons = intervals[cons_ind].mark
                vowel = intervals[vow_ind].mark
                prec_cons = intervals[prev_ind].mark
                vowel_duration = nv_end - nv_beg
                cons_duration = nc_end - nv_end
                #writer.writerow([word, speaker, name, aligner, data, 'vowel_duration', vowel, prec_cons, cons, anno_vow_dur - vowel_duration, norm_dur])
                #writer.writerow([word, speaker, name, aligner, data, 'consonant_duration', vowel, prec_cons, cons, anno_cons_dur - cons_duration, norm_dur])
                writer.writerow([word, speaker, name, aligner, data, 'vowel_begin', vowel, prec_cons, cons, nv_beg - v_beg, norm_dur, v_beg])
                writer.writerow([word, speaker, name, aligner, data, 'vowel_end', vowel, prec_cons, cons, nv_end - v_end, norm_dur, v_end])
                writer.writerow([word, speaker, name, aligner, data, 'cons_end', vowel, prec_cons, cons, nc_end - c_end, norm_dur, c_end])

            #if speaker == 'phon1_60':
            #    error
