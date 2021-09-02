
### Buckeye


benchmark_file = 'D:\\Data\\speech\\benchmark_datasets\\benchmark.csv'
benchmark = read_csv(benchmark_file)
benchmark <- subset(benchmark, Name != 'fave')

benchmark$Name <- factor(benchmark$Name, levels = c('mfa_english', 'mfa_english_adapt', 'mfa_default_train', 
                                                    'mfa_english_ipa', 'mfa_english_ipa_adapt', 'mfa_ipa_train', 'mfa_ipa_train_multilingual'),
                         labels=c('MFA English',
                                  'MFA English adapted','MFA default train', 'MFA English IPA','MFA English IPA adapted','MFA English IPA train','MFA English Multilingual IPA train'))
benchmark$`Final log-likelihood` <- as.numeric(benchmark$`Final log-likelihood`)

summary(benchmark)

csv_files = list.files(path=directory, pattern="*utterance_metrics.txt", full.names=TRUE)

utterance_metrics = csv_files %>% map_dfr(read_csv)

utterance_metrics$aligner <- factor(utterance_metrics$aligner, levels = c('fave', 'maus', 'mfa_english', 'mfa_english_adapt', 'mfa_default_train', 
                                                                    'mfa_english_ipa', 'mfa_english_ipa_adapt', 'mfa_ipa_train', 'mfa_ipa_train_multilingual'),
                                 labels=c('FAVE', 'MAUS', 'MFA English',
                                          'MFA English adapted','MFA default train', 'MFA English IPA','MFA English IPA adapted','MFA English IPA train','MFA English Multilingual IPA train'))

utterance_metrics$phone_boundary_error <- utterance_metrics$overlap_error /2

utterance_metrics$corrected_num_insertions <- utterance_metrics$num_insertions
utterance_metrics[utterance_metrics$aligner=='MAUS',]$corrected_num_insertions <- utterance_metrics[utterance_metrics$aligner=='MAUS',]$corrected_num_insertions - (5 * str_count(utterance_metrics[utterance_metrics$aligner=='MAUS',]$label, 'yknow'))

remove_utterances = c('s4003b_205.2415_223.195437')

utterance_metrics <- subset(utterance_metrics, !utterance %in% remove_utterances)

nrow(subset(utterance_metrics, aligner == 'MAUS'))
nrow(subset(utterance_metrics, aligner == 'MAUS' & str_count(label, 'yknow') > 0))

nrow(subset(utterance_metrics, str_count(label, 'yknow') > 0))

no_yknows <- subset(utterance_metrics, str_count(label, 'yknow') == 0)

csv_files = list.files(path=directory, pattern="*word_distance.txt", full.names=TRUE)

word_distances = csv_files %>% map_dfr(read_csv)

nrow(subset(word_distances, discourse == 's4003b' & reference_time > 205 & reference_time < 223.2))
nrow(subset(word_distances, discourse == 's2401a' & reference_time > 36.49 & reference_time < 51.2))
nrow(subset(word_distances, discourse == 's3301a' & reference_time > 28.2 & reference_time < 44.1))
nrow(subset(word_distances, discourse == 's2903b' & reference_time > 518))

word_distances <- subset(word_distances, !(discourse == 's4003b' & reference_time > 205 & reference_time < 223.2))
word_distances <- subset(word_distances, !(discourse == 's2401a' & reference_time > 36.49 & reference_time < 51.2))
word_distances <- subset(word_distances, !(discourse == 's3301a' & reference_time > 28.2 & reference_time < 44.1))
word_distances <- subset(word_distances, !(discourse == 's2903b' & reference_time > 518))

word_distances$aligner <- factor(word_distances$aligner, levels = c('fave', 'maus', 'mfa_english', 'mfa_english_adapt', 'mfa_default_train', 
                                                                    'mfa_english_ipa', 'mfa_english_ipa_adapt', 'mfa_ipa_train', 'mfa_ipa_train_multilingual'),
                                 labels=c('FAVE', 'MAUS', 'MFA English',
                                          'MFA English adapted','MFA default train', 'MFA English IPA','MFA English IPA adapted','MFA English IPA train','MFA English Multilingual IPA train'))


word_distances$distance <- abs(word_distances$distance)


csv_files = list.files(path=directory, pattern="*phone_distance.txt", full.names=TRUE)

phone_distances = csv_files %>% map_dfr(read_csv)

phone_distances$distance <- abs(phone_distances$distance)

phone_distances$aligner <- factor(phone_distances$aligner, levels = c('fave', 'maus', 'mfa_english', 'mfa_english_adapt', 'mfa_default_train', 
                                                                    'mfa_english_ipa', 'mfa_english_ipa_adapt', 'mfa_ipa_train', 'mfa_ipa_train_multilingual'),
                                  labels=c('FAVE', 'MAUS', 'MFA English',
                                           'MFA English adapted','MFA default train', 'MFA English IPA','MFA English IPA adapted','MFA English IPA train','MFA English Multilingual IPA train'))

phone_distances$type <- factor(phone_distances$type, levels=c('initialc', 'cv', 'vc', 'finalc'), labels=c('Initial C', 'CV transition', 'VC transition', 'Final C'))


