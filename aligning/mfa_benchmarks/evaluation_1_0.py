import os
import subprocess
import json
import yaml
import time
from montreal_forced_aligner.alignment.pretrained import PretrainedAligner
from montreal_forced_aligner.db import ReferencePhoneInterval, PhoneInterval, Utterance, Speaker, File

root_dir = r'D:\Data\experiments\alignment_benchmarking'
timit_dir = r'D:\Data\speech\benchmark_datasets\timit'
buckeye_dir = r'D:\Data\speech\Buckeye'

mfa10_dir = os.path.join(root_dir, 'montreal-forced-aligner_101')
mfa_path = os.path.join(mfa10_dir, 'bin', 'mfa_align.exe')
dictionary_path = os.path.join(mfa10_dir, 'pretrained_models', 'english.dict')
model_path = os.path.join(mfa10_dir, 'pretrained_models', 'english.zip')
benchmarks = {}
benchmark_path = os.path.join(root_dir, 'benchmarks.json')


begin = time.time()

if __name__ == '__main__':
    aligned_dir = os.path.join(root_dir, 'alignments', 'mfa_101_alignments', 'buckeye')
    mapping_path = os.path.join(root_dir, 'arpa_buckeye_mapping.yaml')
    if not os.path.exists(os.path.join(aligned_dir, "alignment_evaluation.csv")):
        aligner = PretrainedAligner(corpus_directory=os.path.join(buckeye_dir, 'benchmark'),
                                    acoustic_model_path=model_path,
                dictionary_path=dictionary_path,
                                    num_jobs=10, clean=True,
                                    temporary_directory=os.path.join(root_dir, 'temp_eval'))

        aligner.setup()
        aligner.load_reference_alignments(aligned_dir)
        mapping = []
        with aligner.session() as session:
            reference_phones = session.query(ReferencePhoneInterval)
            utterances = set()
            for rp in reference_phones:
                mapping.append({
                    'begin': rp.begin,
                    'end': rp.end,
                    'label': rp.label,
                    'utterance_id': rp.utterance_id,
                })
                utterances.add(rp.utterance_id)
            session.bulk_insert_mappings(PhoneInterval, mapping)
            reference_phones.delete()
            session.bulk_update_mappings(Utterance, [{'id': x,
                                                      'alignment_log_likelihood': 50} for x in utterances])
            session.commit()

        with open(mapping_path, "r", encoding="utf8") as f:
            mapping = yaml.safe_load(f)
        aligner.load_reference_alignments(os.path.join(buckeye_dir, 'reference'))
        aligner.evaluate(mapping, output_directory=aligned_dir)

    aligned_dir = os.path.join(root_dir, 'alignments', 'mfa_101_alignments', 'timit')
    mapping_path = os.path.join(root_dir, 'arpa_timit_mapping.yaml')
    if not os.path.exists(os.path.join(aligned_dir, "alignment_evaluation.csv")):
        aligner = PretrainedAligner(corpus_directory=os.path.join(timit_dir, 'benchmark'),
                                    acoustic_model_path=model_path,
                dictionary_path=dictionary_path,
                                    num_jobs=10, clean=True,
                                    temporary_directory=os.path.join(root_dir, 'temp_eval'))

        aligner.setup()
        aligner.load_reference_alignments(aligned_dir)
        mapping = []
        with aligner.session() as session:
            reference_phones = session.query(ReferencePhoneInterval)
            utterances = set()
            for rp in reference_phones:
                mapping.append({
                    'begin': rp.begin,
                    'end': rp.end,
                    'label': rp.label,
                    'utterance_id': rp.utterance_id,
                })
                utterances.add(rp.utterance_id)
            session.bulk_insert_mappings(PhoneInterval, mapping)
            reference_phones.delete()
            session.bulk_update_mappings(Utterance, [{'id': x,
                                                      'alignment_log_likelihood': 50} for x in utterances])
            session.commit()

        with open(mapping_path, "r", encoding="utf8") as f:
            mapping = yaml.safe_load(f)
        aligner.load_reference_alignments(os.path.join(timit_dir, 'reference'))
        aligner.evaluate(mapping, output_directory=aligned_dir)
