###################################
## SPADE formant analysis script ##
###################################

## Processes and extracts 'static' (single point) formant values, along with linguistic
## and acoustic information from corpora collected as part of the SPeech Across Dialects
## of English (SPADE) project.

## Input:
## - corpus name (e.g., Buckeye, SOTC)
## - corpus metadata (stored in a YAML file)
##   this file should specify the path to the
##   audio, transcripts, metadata files (e.g.,
##   speaker, lexicon), and the a datafile containing
##   prototype formant values to be used for formant
##   estimation
## Output:
## - CSV of single-point vowel measurements (1 row per token),
##   with columns for the linguistic, acoustic, and speaker information
##   associated with that token

import sys
import os
import time
import argparse

base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

sys.path.insert(0, base_dir)

drop_formant = True

import common

from polyglotdb.utils import ensure_local_database_running
from polyglotdb import CorpusConfig
from polyglotdb import CorpusContext

reset = False

corpus_name = 'mm_mic_test'
directories = [x for x in os.listdir(base_dir) if os.path.isdir(x) and x != 'Common']
if corpus_name not in directories:
    print(
        'The corpus {0} does not have a directory (available: {1}).  Please make it with a {0}.yaml file inside.'.format(
            corpus_name, ', '.join(directories)))
    sys.exit(1)
corpus_conf = common.load_config(corpus_name)

if reset:
    common.reset(corpus_name)
ip = common.server_ip


## Define and process command line arguments

prototype_names = ['spade-Buckeye', 'spade-SantaBarbara', 'spade-SOTC', '']

with ensure_local_database_running(corpus_name, port=common.server_port, ip=ip, token=common.load_token()) as params:
    print(params)
    config = CorpusConfig(corpus_name, **params)
    config.formant_source = 'praat'

    ## Common set up: see commony.py for details of these functions ##
    ## Check if the corpus already has an associated graph object; if not,
    ## perform importing and parsing of the corpus files
    common.loading(config, corpus_conf['corpus_directory'], corpus_conf['input_format'])

    ## Perform linguistic, speaker, and acoustic enrichment
    common.lexicon_enrichment(config, corpus_conf['unisyn_spade_directory'], corpus_conf['dialect_code'])
    common.speaker_enrichment(config, corpus_conf['speaker_enrichment_file'])

    common.basic_enrichment(config, corpus_conf['vowel_inventory'] + corpus_conf['extra_syllabic_segments'],
                            corpus_conf['pauses'])

    ## Check if the YAML specifies the path to the YAML file
    ## if not, load the prototypes file from the default location
    ## (within the SPADE corpus directory)
    ## Determine the class of phone labels to be used for formant analysis
    ## based on lists provided in the YAML file.
    if corpus_conf['stressed_vowels']:
        vowels_to_analyze = corpus_conf['stressed_vowels']
    else:
        vowels_to_analyze = corpus_conf['vowel_inventory']
    for pname in prototype_names:
        if pname:
            vowel_prototypes_path = os.path.join(base_dir, corpus_name, '{}_prototypes.csv'.format(pname))
            if not os.path.exists(vowel_prototypes_path):
                print(vowel_prototypes_path)
                raise Exception
        else:
            vowel_prototypes_path = pname
        track_path = os.path.join(base_dir, corpus_name, '{}_formant_tracks.csv'.format(pname))


        ## Perform formant estimation and analysis
        ## see common.py for the details of this implementation
        common.formant_acoustic_analysis(config, vowels_to_analyze, vowel_prototypes_path, drop_formant=drop_formant, reset_formants=True, output_tracks=True)

        with CorpusContext(config) as c:
            print('Beginning formant export')
            beg = time.time()
            ## Output the query (determined in common.py) as a CSV file
            q = c.query_graph(c.phone)
            # q = q.filter(c.phone.subset == 'unisyn_subset')

            q = q.filter(c.phone.duration >= 0.05)
            q = q.filter(c.phone.label.in_(vowels_to_analyze))
            print('Applied filters')

            ## Define the columns to be included in the query
            ## Include the formant columns with 'relativised' time
            ## (i.e., as % through the vowel, e.g., 5%, 10%, etc).
            formants_prop = c.phone.formants
            formants_prop.relative_time = True
            formants_track = formants_prop.interpolated_track
            formants_track.num_points = 21

            ## Include columns for speaker and file metadata,
            ## phone information (label, duration), surrounding
            ## phonological environment, syllable information
            ## (e.g., stress), word information, and speech rate
            q = q.columns(c.phone.speaker.name.column_name('speaker'),
                          c.phone.discourse.name.column_name('discourse'),
                          c.phone.id.column_name('phone_id'),
                          c.phone.label.column_name('phone_label'),
                          c.phone.begin.column_name('phone_begin'),
                          c.phone.end.column_name('phone_end'),
                          c.phone.duration.column_name('phone_duration'),
                          c.phone.syllable.position_in_word.column_name('syllable_position_in_word'),
                          c.phone.following.label.column_name('following_phone'),
                          c.phone.previous.label.column_name('previous_phone'),
                          c.phone.word.label.column_name('word_label'),
                          c.phone.utterance.speech_rate.column_name('speech_rate'),
                          c.phone.syllable.label.column_name('syllable_label'),
                          c.phone.syllable.duration.column_name('syllable_duration'),
                          formants_track)



            ## Export the query
            ## as a CSV
            print("Writing CSV")
            q.to_csv(track_path)
            end = time.time()
            time_taken = time.time() - beg
            print('Query took: {}'.format(end - beg))
            print("Results for query written to {}".format(track_path))

    print('Finishing up!')

