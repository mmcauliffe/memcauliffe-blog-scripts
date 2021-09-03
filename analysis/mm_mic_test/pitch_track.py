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

sys.path.insert(0, '/mnt/c/Users/michael/Documents/Dev/PolyglotDB')

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

algorithm_names = ['base', 'speaker_adjusted']

source_names = ['praat', 'reaper']

with ensure_local_database_running(corpus_name, port=common.server_port, ip=ip, token=common.load_token()) as params:
    print(params)
    config = CorpusConfig(corpus_name, **params)

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
    for pname in source_names:
        for aname in algorithm_names:
            csv_path = os.path.join(base_dir, corpus_name, '{}_{}_pitch.csv'.format(aname, pname))


            ## Perform formant estimation and analysis
            ## see common.py for the details of this implementation
            common.pitch_acoustic_analysis(config, source=pname, algorithm=aname, reset_pitch=True)

            with CorpusContext(config) as c:
                print('Beginning pitch export')
                beg = time.time()
                ## Output the query (determined in common.py) as a CSV file
                q = c.query_graph(c.word)
                # q = q.filter(c.phone.subset == 'unisyn_subset')

                #q = q.filter(c.phone.duration >= 0.05)
                #q = q.filter(c.phone.label.in_(vowels_to_analyze))
                print('Applied filters')

                ## Define the columns to be included in the query
                ## Include the formant columns with 'relativised' time
                ## (i.e., as % through the vowel, e.g., 5%, 10%, etc).
                pitch_prop = c.word.pitch
                pitch_prop.relative_time = True
                pitch_track = pitch_prop.track

                ## Include columns for speaker and file metadata,
                ## phone information (label, duration), surrounding
                ## phonological environment, syllable information
                ## (e.g., stress), word information, and speech rate
                q = q.columns(c.word.speaker.name.column_name('speaker'),
                              c.word.discourse.name.column_name('discourse'),
                              c.word.label.column_name('word_label'),
                              c.word.begin.column_name('word_begin'),
                              c.word.end.column_name('word_end'),
                              c.word.duration.column_name('word_duration'),
                              c.word.utterance.speech_rate.column_name('speech_rate'),
                              pitch_track)



                ## Export the query
                ## as a CSV
                print("Writing CSV")
                q.to_csv(csv_path)
                end = time.time()
                time_taken = time.time() - beg
                print('Query took: {}'.format(end - beg))
                print("Results for query written to {}".format(csv_path))

    print('Finishing up!')

