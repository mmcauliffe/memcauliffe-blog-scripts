import sys
import os
import argparse

import sys
import yaml
base_dir = os.path.dirname(os.path.abspath(__file__))
import polyglotdb.io as pgio
from polyglotdb.utils import ensure_local_database_running
from polyglotdb.config import CorpusConfig
from polyglotdb import CorpusContext

from Common import common



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('corpus_name', help='Name of the corpus')
    parser.add_argument('classifier', help='Path to classifier')
    parser.add_argument('-r', '--reset', help="Reset the corpus", action='store_true')
    parser.add_argument('-e', '--export_file', help='Path of CSV to export')
    parser.add_argument('-v', '--vot', help='Reset and re-encode VOT', action='store_true',default=False)

    args = parser.parse_args()
    corpus_name = args.corpus_name
    classifier = args.classifier
    reset = args.reset
    vot = args.vot
    directories = [x for x in os.listdir(base_dir) if os.path.isdir(x) and x != 'Common']

    if args.corpus_name not in directories:
        print(
            'The corpus {0} does not have a directory (available: {1}).  Please make it with a {0}.yaml file inside.'.format(
                args.corpus_name, ', '.join(directories)))
        sys.exit(1)
    
    corpus_conf = load_config(corpus_name)

    print('Processing...')
    #Connect to local database at 8080
    with ensure_local_database_running(corpus_name, port=8080, token = common.load_token()) as params:
        #Load corpus context and config info
        config = CorpusConfig(corpus_name, **params)
        config.formant_source = 'praat'
        # Common set up
        if reset:
            with CorpusContext(config) as c:
                print("Resetting the corpus.")
                c.reset()
        common.loading(config, corpus_conf['corpus_directory'], corpus_conf['input_format'])
        common.lexicon_enrichment(config, corpus_conf['unisyn_spade_directory'], corpus_conf['dialect_code'])
        common.speaker_enrichment(config, corpus_conf['speaker_enrichment_file'])
        common.basic_enrichment(config, corpus_conf['vowel_inventory'] + corpus_conf['extra_syllabic_segments'], corpus_conf['pauses'])
        with CorpusContext(config) as g:

            #Sets of stops and vowels
            stops = ['p', 't', 'k']
            vowels = corpus_conf['vowel_inventory']

            #If there is already a stop subset in the database, delete it
            if g.hierarchy.has_token_subset('phone', "stops"):
                g.query_graph(g.phone).remove_subset("stops")

            #Encode a subset of word initial stops spoken by a speaker in small_speakers
            q = g.query_graph(g.phone)
            #q = q.filter(g.phone.speaker.name.in_(small_speakers)).filter(g.phone.begin==g.phone.word.begin).filter(g.phone.label.in_(stops))
            q = q.filter(g.phone.begin==g.phone.word.begin).filter(g.phone.label.in_(stops)).filter(g.phone.following.label.in_(vowels))
            q.create_subset('stops')

            #Ensure utterances are encoded and encoded them if not.
            if not 'utterance' in g.annotation_types:
                g.encode_pauses(corpus_conf["pauses"])
                g.encode_utterances(min_pause_length=0.15)

            #Reset and predict VOT values
            if vot:
                g.reset_vot()
                g.analyze_vot(stop_label='stops',
                        classifier=classifier,
                        vot_min=15,
                        vot_max=250,
                        window_min=-30,
                        window_max=30)

            #Get a query of necessary info
            q = g.query_graph(g.phone).filter(g.phone.subset == "stops").columns(g.phone.label, \
                    g.phone.begin, g.phone.end, g.phone.vot.confidence,
                    g.phone.vot.begin, g.phone.vot.end, g.phone.word.label, g.phone.syllable.stress,\
                    g.phone.discourse.name, g.phone.speaker.name).order_by(g.phone.begin)

            if args.export_file:
                q.to_csv(args.export_file)
            else:
                q.to_csv(os.path.join(base_dir, corpus_name, '{}_vot.csv'.format(corpus_name)))
