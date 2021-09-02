import os
import sys
import csv
import re
from textgrid import TextGrid
from Bio import pairwise2



ipa_mapping = {
    'ʔ': 'tq',
    'i': 'iy',
    'h': 'hh',
    'iː': 'iy',
    'ɡ': 'g',
    'ɚ': 'er',
    'ɝ': 'er',
    'ɝː': 'er',
    '3`': 'er',
    'dʒ': 'jh',
    'tʃ': 'ch',
    'ʒ': 'zh',
    'ɑ': 'aa',
    'ɑː': 'aa',
    'ʊ': 'uh',
    'ɛ': 'eh',
    'oʊ': 'ow',
    'aʊ': 'aw',
    'aɪ': 'ay',
    'ɔ': 'ao',
    'ɔː': 'ao',
    'ɔɪ': 'oy',
    'u': 'uw',
    'uː': 'uw',
    'æ': 'ae',
    'eɪ': 'ey',
    'ð': 'dh',
    'ʃ': 'sh',
    'ɹ': 'r',
    'j': 'y',
    'θ': 'th',
    'ə': 'ah',
    'ŋ': 'ng',
    'ʌ': 'ah',
    'n̩': 'en',
    'm̩': 'em',
    'l̩': 'el',
}

def compare_labels(ref, test, d):
    mapping = ipa_mapping
    if ref == test:
        return 0
    if test in mapping and mapping[test] == ref:
        return 0
    ref = ref.lower()
    test = test.lower()
    if ref == test:
        return 0
    return 2

def overlap_scoring(firstElement, secondElement, d):
    begin_diff = abs(firstElement.minTime - secondElement.minTime)
    end_diff = abs(firstElement.maxTime - secondElement.maxTime)
    label_diff = compare_labels(firstElement.mark, secondElement.mark, d)
    return -1 * (begin_diff + end_diff + label_diff)



def align_phones(ref, test, d):
    ref = [x for x in ref]
    test = [x for x in test]
    import functools
    score_func = functools.partial(overlap_scoring, d=d)
    alignments = pairwise2.align.globalcs(ref, test, score_func, -5, -5, gap_char=['-'], one_alignment_only=True)
    overlap_count = 0
    overlap_sum = 0
    num_insertions = 0
    num_deletions = 0
    for a in alignments:
        for i, sa in enumerate(a.seqA):
            sb = a.seqB[i]
            #print(sa, '->', sb)
            if sa == '-':
                if not silence_check(sb.mark):
                    num_insertions += 1
                else:
                    continue
            elif sb == '-':
                if not silence_check(sa.mark):
                    num_deletions += 1
                else:
                    continue
            else:
                overlap_sum += abs(sa.minTime - sb.minTime) + abs(sa.maxTime - sb.maxTime)
                overlap_count += 1
    return overlap_sum / overlap_count, num_insertions, num_deletions

base_dir = r'D:\Data\speech\benchmark_datasets\buckeye\smalls\models\full_align_tgs'

reference_dir = r'D:\Data\speech\benchmark_datasets\buckeye\reference'

all_dirs = [f'{x}_{y}' for x in range(1, 40) for y in range(5)]

to_extract = [x for x in all_dirs if x not in ['reference', 'prosodylab_format']
              and os.path.exists(os.path.join(base_dir, x)) and os.path.isdir(os.path.join(base_dir, x))]

ignored_words = {'', 'sp', 'sil'}

skip_utterances = {'s0702a_357.505619_361.640812.TextGrid',
                   's1604a_292.375082_293.243178.TextGrid',
                   's1604a_415.781_418.27277399999997.TextGrid',
                   's1604a_634.977504_637.642113.TextGrid',
                   's1902b_445.35931700000003_447.020116.TextGrid',
                   's2202b_208.48235100000002_215.56812399999998.TextGrid',
                   's2301a_60.34254_62.645804000000005.TextGrid',
                   's2903b_177.181667_180.622425.TextGrid'}

speakers = os.listdir(reference_dir)
print(speakers)

GOOD_WORDS = {'back', 'bad', 'badge', 'bag', 'ball', 'bar', 'bare', 'base', 'bash', 'bass', 'bat', 'bath', 'beach',
              'bean', 'bear', 'beat', 'bed', 'beer', 'bell', 'berth', 'big', 'bike', 'bill', 'birth', 'bitch', 'bite',
              'boat', 'bob', 'boil', 'bomb', 'book', 'boom', 'boon', 'boss', 'bought', 'bout', 'bowl', 'buck', 'bum',
              'burn', 'bus', 'bush', 'cab', 'cad', 'cake', 'calf',
              'call', 'came', 'cap',
              'car', 'care', 'case', 'cash', 'cat', 'catch', 'caught', 'cave', 'cell', 'chain', 'chair', 'chat',
              'cheap', 'cheat', 'check',
              'cheer', 'cheese', 'chess', 'chick', 'chief', 'chill', 'choice', 'choose', 'chose', 'church', 'coach',
              'code', 'coke',
              'comb', 'come', 'cone', 'cook', 'cool', 'cop', 'cope', 'corps', 'couch', 'cough', 'cub', 'cuff', 'cup',
              'curl', 'curve', 'cut',
              'dab', 'dad', 'dare', 'date', 'dawn', 'dead', 'deal', 'dear', 'death', 'debt', 'deck', 'deed', 'deep',
              'deer', 'dime', 'dirt',
              'doc', 'dodge', 'dog', 'dole', 'doll', 'doom', 'door', 'dot', 'doubt', 'duck', 'dug', 'dumb', 'face',
              'fad', 'fade', 'fail',
              'fair', 'faith', 'fake', 'fall', 'fame', 'fan', 'far', 'fat', 'faze', 'fear', 'fed', 'feed', 'feet',
              'fell', 'fight', 'file', 'fill', 'fine',
              'firm', 'fish', 'fit', 'fog', 'folk', 'food', 'fool', 'foot', 'fore', 'fought', 'fun', 'fuss', 'gain',
              'game', 'gap', 'gas',
              'gate', 'gave', 'gear', 'geese', 'gig', 'girl', 'give', 'goal', 'gone', 'good', 'goose', 'gum', 'gun',
              'gut', 'gym', 'hail', 'hair',
              'hall', 'ham', 'hang', 'hash', 'hat', 'hate', 'head', 'hear', 'heard', 'heat', 'height', 'hick', 'hid',
              'hide', 'hill', 'hip', 'hit',
              'hole', 'home', 'hood', 'hook', 'hop', 'hope', 'hot', 'house', 'hug', 'hum', 'hung', 'hurt', 'jab',
              'jail', 'jam', 'jazz', 'jerk',
              'jet', 'job', 'jog', 'join', 'joke', 'judge', 'june', 'keep', 'kick', 'kid', 'kill', 'king', 'kiss',
              'knife', 'knit', 'knob', 'knock',
              'known', 'lack', 'lag', 'laid', 'lake', 'lame', 'lane', 'lash', 'latch', 'late', 'laugh', 'lawn',
              'league', 'leak', 'lean', 'learn',
              'lease', 'leash', 'leave', 'led', 'leg', 'let', 'lid', 'life', 'light', 'line', 'load', 'loan', 'lock',
              'lodge', 'lone', 'long', 'look',
              'loose', 'lose', 'loss', 'loud', 'love', 'luck', 'mad', 'made', 'maid', 'mail', 'main', 'make', 'male',
              'mall',
              'map', 'mass', 'mat', 'match', 'math', 'meal', 'meat', 'meet', 'men', 'mess', 'met', 'mid', 'mike',
              'mile', 'mill',
              'miss', 'mock', 'moon', 'mouth', 'move', 'mud', 'nail', 'name', 'nap', 'neat', 'neck', 'need', 'nerve',
              'net', 'news',
              'nice', 'niche', 'niece', 'night', 'noise', 'noon', 'nose', 'notch', 'note', 'noun', 'nurse', 'nut',
              'pace', 'pack', 'page',
              'paid', 'pain', 'pair', 'pal', 'pass', 'pat', 'path', 'pawn', 'peace', 'peak', 'pearl', 'peek', 'peer',
              'pen', 'pet', 'phase',
              'phone', 'pick', 'piece', 'pile', 'pill', 'pine', 'pipe', 'pit', 'pool', 'poor', 'pop', 'pope', 'pot',
              'pour', 'puck', 'push',
              'put', 'race', 'rage', 'rail', 'rain', 'raise', 'ran', 'rash', 'rat', 'rate', 'rave', 'reach', 'rear',
              'red', 'reef', 'reel',
              'rice', 'rich', 'ride', 'ring', 'rise', 'road', 'roam', 'rob', 'rock', 'rode', 'role', 'roll', 'roof',
              'room', 'rose', 'rough',
              'rub', 'rude', 'rule', 'run', 'rush', 'sack', 'sad', 'safe', 'said', 'sake', 'sale', 'sang', 'sat',
              'save', 'scene', 'search',
              'seat', 'seen', 'sell', 'serve', 'set', 'sewn', 'shake', 'shame', 'shape', 'share', 'shave', 'shed',
              'sheep', 'sheer', 'sheet',
              'shell', 'ship', 'shirt', 'shock', 'shoot', 'shop', 'shot', 'shown', 'shun', 'shut', 'sick', 'side',
              'sight', 'sign', 'sin', 'sing',
              'sit', 'site', 'size', 'soap', 'son', 'song', 'soon', 'soul', 'soup', 'south', 'suit', 'sung', 'tab',
              'tag', 'tail', 'take', 'talk',
              'tap', 'tape', 'taught', 'teach', 'team', 'tease', 'teeth', 'tell', 'term', 'theme', 'thick', 'thief',
              'thing', 'thought', 'tiff',
              'tight', 'time', 'tip', 'tongue', 'took', 'tool', 'top', 'tore', 'toss', 'touch', 'tough', 'tour', 'town',
              'tub', 'tube',
              'tune', 'turn', 'type', 'use', 'van', 'vet', 'vice', 'voice', 'vote', 'wade', 'wage', 'wait', 'wake',
              'walk', 'wall', 'war',
              'wash', 'watch', 'wear', 'web', 'week', 'weight', 'wet', 'whack', 'wheat', 'wheel', 'whim', 'whine',
              'whip', 'white',
              'whole', 'wick', 'wide', 'wife', 'win', 'wine', 'wing', 'wise', 'wish', 'woke', 'womb', 'wood', 'word',
              'wore', 'work',
              'worse', 'wreck', 'wright', 'write', 'wrong', 'wrote', 'wrought', 'year', 'yell', 'young', 'youth', 'zip'}


root_dir = r'D:\Data\speech\benchmark_datasets\buckeye\data_comp_accuracy_data_align'
os.makedirs(root_dir, exist_ok=True)

def get_paths(identifier):
    words_distance_path = os.path.join(root_dir, f'{identifier}_word_distance.txt')
    phone_distance_path = os.path.join(root_dir, f'{identifier}_phone_distance.txt')
    utterance_metrics_path = os.path.join(root_dir, f'{identifier}_utterance_metrics.txt')
    return {'words_distance': words_distance_path,
            'utterance_metrics': utterance_metrics_path,
            'phone_distance': phone_distance_path, }


def is_completed(identifier):
    paths = get_paths(identifier)
    if os.path.exists(paths['words_distance']):
        return True
    return False

headers = {
    'words_distance': ['speaker', 'discourse', 'aligner', 'pause_boundary', 'distance', 'reference_time'],
    'utterance_metrics': ['speaker', 'discourse', 'utterance', 'aligner', 'label', 'duration',
                          'overlap_error', 'num_insertions', 'num_deletions'],
    #'phone_recall': ['speaker', 'discourse', 'aligner', 'label', 'pos', 'distance', 'reference_time'],
    #'phone_precision': ['speaker', 'discourse', 'aligner', 'label', 'pos', 'distance', 'reference_time'],
    'phone_distance': ['speaker', 'discourse', 'aligner', 'word', 'first_consonant', 'vowel', 'second_consonant',
                           'buckeye_first_consonant', 'buckeye_vowel', 'buckeye_second_consonant', 'type', 'distance',
                           'reference_time'],
}

to_extract = [x for x in to_extract if not is_completed(x)]

other_dirs = [x for x in os.listdir(base_dir) if x in to_extract]

handles = {x: {} for x in to_extract}
writers = {x: {} for x in to_extract}

for ident in to_extract:
    paths = get_paths(ident)
    for k, v in paths.items():
        handles[ident][k] = open(v, 'w', newline='', encoding='utf8')
        writers[ident][k] = csv.writer(handles[ident][k])
        writers[ident][k].writerow(headers[k])

missing = {x: 0 for x in other_dirs}

def silence_check(phone):
    return phone in {'sp', '<p:>', '', None}

def shop_words(ref, test):
    new_test = []
    offset = 0
    for i, rw in enumerate(ref):
        actual_ind = i+offset
        tw = test[actual_ind]
        if rw.mark != tw.mark.lower():
            if rw.mark.startswith(tw.mark.lower() + '-'):
                tw.mark = tw.mark + '-' + test[actual_ind+1].mark
                tw.maxTime = test[actual_ind+1].maxTime
                offset += 1
        new_test.append(tw)
    return new_test


for speaker in sorted(speakers):
    if len(speaker) != 3:
        continue
    speaker_dir = os.path.join(reference_dir, speaker)
    files = os.listdir(speaker_dir)
    print(speaker)
    for f in files:
        print(f)
        if not f.endswith('.TextGrid'):
            continue
        if f in skip_utterances:
            continue
        # print(f)
        discourse, real_begin, real_end = f.replace('.TextGrid', '').split('_')
        real_begin = float(real_begin)
        real_end = float(real_end)
        duration = real_end - real_begin
        ref_tg_path = os.path.join(speaker_dir, f)
        ref_tg = TextGrid()
        ref_tg.read(ref_tg_path)
        ref_words = ref_tg.getFirst('words')
        ref_words = [x for x in ref_words if x.mark not in ignored_words]
        ref_phones = ref_tg.getFirst('phones')
        skip = False
        for d in other_dirs:
            test_f = f
            test_tg_path = os.path.join(base_dir, d, speaker, test_f)
            if not os.path.exists(test_tg_path):
                skip = True
        #if skip:
        #    continue
        for d in other_dirs:
            print(d)
            test_f = f
            test_tg_path = os.path.join(base_dir, d, speaker, test_f)
            if not os.path.exists(test_tg_path):
                missing[d] += 1
                continue
            test_tg = TextGrid()
            test_tg.read(test_tg_path)
            if d == 'fave':
                test_words = test_tg.getFirst('{} - word'.format(speaker))
                test_phones = test_tg.getFirst('{} - phone'.format(speaker))
            elif d == 'maus':
                test_words = test_tg.getFirst('ORT-MAU')
                test_phones = test_tg.getFirst('MAU')
            else:
                test_words = test_tg.getFirst('words')
                test_phones = test_tg.getFirst('phones')
            test_words = [x for x in test_words if x.mark.lower() not in ignored_words]
            if len(ref_words) != len(test_words):
                test_words = shop_words(ref_words, test_words)
            if len(ref_words) != len(test_words):
                print(f, d)
                print(ref_words)
                print(test_words)
                raise (Exception)
            prev_time = None
            for i, rw in enumerate(ref_words):
                tw = test_words[i]
                if tw.mark.lower() != rw.mark.lower() and tw.mark != '<unk>' and d !='maus':
                    print(f, d)
                    print(ref_words)
                    print(test_words)
                    raise (Exception)
                if real_begin + rw.minTime == real_begin + rw.maxTime:
                    print(f, d)
                    print(ref_words)
                    print(test_words)
                    print(real_begin + rw.minTime, real_begin + rw.maxTime, rw)
                    raise (Exception)
                time_point = real_begin + rw.minTime
                if prev_time != time_point:

                    writers[d]['words_distance'].writerow([speaker, discourse, d, True, tw.minTime - rw.minTime, time_point])
                prev_time = real_begin + rw.maxTime
                check = False
                if i == len(ref_words) - 1:
                    check = True
                elif rw.maxTime != ref_words[i + 1].minTime:
                    check = True

                writers[d]['words_distance'].writerow([speaker, discourse, d, check, tw.maxTime - rw.maxTime, prev_time])
                if rw.mark.lower() in GOOD_WORDS:
                    rps = [x for x in ref_phones if x.minTime >= rw.minTime and x.maxTime <= rw.maxTime]
                    if len(rps) != 3:
                        continue
                    tps = [x for x in test_phones if x.minTime >= tw.minTime and x.maxTime <= tw.maxTime]
                    if len(tps) != 3:
                        continue
                    try:
                        writers[d]['phone_distance'].writerow([speaker, discourse, d, rw.mark, tps[0].mark, tps[1].mark, tps[2].mark,
                                               rps[0].mark, rps[1].mark, rps[2].mark, 'initialc',
                                               tps[0].minTime - rps[0].minTime, real_begin + rps[0].minTime])
                        writers[d]['phone_distance'].writerow([speaker, discourse, d, rw.mark, tps[0].mark, tps[1].mark, tps[2].mark,
                                               rps[0].mark, rps[1].mark, rps[2].mark, 'cv',
                                               tps[0].maxTime - rps[0].maxTime, real_begin + rps[0].maxTime])
                        writers[d]['phone_distance'].writerow([speaker, discourse, d, rw.mark, tps[0].mark, tps[1].mark, tps[2].mark,
                                               rps[0].mark, rps[1].mark, rps[2].mark, 'vc',
                                               tps[1].maxTime - rps[1].maxTime, real_begin + rps[1].maxTime])
                        writers[d]['phone_distance'].writerow([speaker, discourse, d, rw.mark, tps[0].mark, tps[1].mark, tps[2].mark,
                                               rps[0].mark, rps[1].mark, rps[2].mark, 'finalc',
                                               tps[2].maxTime - rps[2].maxTime, real_begin + rps[2].maxTime])
                    except:
                        print('REF', rps)
                        print('TEST', tps)
                        raise
            overlap_diff, num_insertions, num_deletions = align_phones(ref_phones, test_phones, d)
            writers[d]['utterance_metrics'].writerow([speaker, discourse, f.replace('.TextGrid', ''), d,
                                                      ' '.join(x.mark for x in ref_words), duration, overlap_diff, num_insertions, num_deletions])




print(missing)


def calculate_precision_recall():
    for i, rp in enumerate(ref_phones):
        if not rp.mark:
            continue
        if silence_check(rp.mark):
            continue
        begin_min_distance = 100000
        end_min_distance = None
        if i == len(ref_phones) - 1 or silence_check(ref_phones[i + 1].mark):
            end_min_distance = 100000
        for j, tp in enumerate(test_phones):
            if silence_check(tp.mark):
                continue
            begin_dist = abs(tp.minTime - rp.minTime)
            if begin_dist < begin_min_distance:
                begin_min_distance = begin_dist
            if end_min_distance:
                end_dist = abs(tp.maxTime - rp.maxTime)
                begin_dist = abs(tp.minTime - rp.maxTime)
                if begin_dist < end_min_distance:
                    end_min_distance = begin_dist
                if end_dist < end_min_distance:
                    end_min_distance = end_dist
        writers[d]['phone_recall'].writerow([speaker, discourse, d, rp.mark, 'begin', begin_min_distance, rp.minTime])
        if end_min_distance is not None:
            writers[d]['phone_recall'].writerow([speaker, discourse, d, rp.mark, 'end', end_min_distance, rp.maxTime])
    for i, tp in enumerate(test_phones):
        if not tp.mark:
            continue
        if silence_check(tp.mark):
            continue
        begin_min_distance = 100000
        end_min_distance = None
        if i == len(test_phones) - 1 or silence_check(test_phones[i + 1].mark):
            end_min_distance = 100000
        for j, rp in enumerate(ref_phones):
            if silence_check(rp.mark):
                continue
            begin_dist = abs(rp.minTime - tp.minTime)
            if begin_dist < begin_min_distance:
                begin_min_distance = begin_dist
            if end_min_distance:
                end_dist = abs(rp.maxTime - tp.minTime)
                if end_dist < begin_min_distance:
                    begin_min_distance = end_dist
                end_dist = abs(rp.maxTime - tp.maxTime)
                begin_dist = abs(rp.minTime - tp.maxTime)
                if begin_dist < end_min_distance:
                    end_min_distance = begin_dist
                if end_dist < end_min_distance:
                    end_min_distance = end_dist
        writers[d]['phone_precision'].writerow(
            [speaker, discourse, d, tp.mark, 'begin', begin_min_distance, tp.minTime])
        if end_min_distance is not None:
            writers[d]['phone_precision'].writerow(
                [speaker, discourse, d, tp.mark, 'end', end_min_distance, tp.maxTime])
