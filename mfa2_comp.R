

mfa2_utterance_metrics <- subset(utterance_metrics, aligner %in% c(#'FAVE', 'MAUS', 
                                                                   'MFA English','MFA English Adapted', 'MFA English Adapt Mapped', 
                                                                   'MFA default train', 
                                                                   'MFA English IPA','MFA English IPA Adapted', 'MFA English Multilingual IPA Adapt Mapped', 
                                                                   'MFA English IPA train','MFA English Multilingual IPA train',
                                                                   'MFA 2.0 English', 'MFA 2.0 English Adapted', 'MFA 2.0 English Adapt Mapped', 
                                                                   'MFA 2.0 English IPA', 'MFA 2.0 English IPA Adapted', 'MFA 2.0 English IPA Adapt Mapped', 
                                                                   'MFA 2.0 English Multilingual IPA', 'MFA 2.0 English Multilingual IPA Adapted', 'MFA 2.0 English Multilingual IPA Adapt Mapped'))
mfa2_word_distances <- subset(word_distances, aligner %in% c(#'FAVE', 'MAUS', 
                                                             'MFA English','MFA English Adapted', 'MFA English Adapt Mapped', 
                                                             'MFA default train', 
                                                             'MFA English IPA','MFA English IPA Adapted', 'MFA English Multilingual IPA Adapt Mapped', 
                                                             'MFA English IPA train','MFA English Multilingual IPA train',
                                                             'MFA 2.0 English', 'MFA 2.0 English Adapted', 'MFA 2.0 English Adapt Mapped', 
                                                             'MFA 2.0 English IPA', 'MFA 2.0 English IPA Adapted', 'MFA 2.0 English IPA Adapt Mapped', 
                                                             'MFA 2.0 English Multilingual IPA', 'MFA 2.0 English Multilingual IPA Adapted', 'MFA 2.0 English Multilingual IPA Adapt Mapped'))
mfa2_phone_distances <- subset(phone_distances, aligner %in% c(#'FAVE', 'MAUS', 
                                                               'MFA English','MFA English Adapted', 'MFA English Adapt Mapped', 
                                                               'MFA default train', 
                                                               'MFA English IPA','MFA English IPA Adapted', 'MFA English Multilingual IPA Adapt Mapped', 
                                                               'MFA English IPA train','MFA English Multilingual IPA train',
                                                               'MFA 2.0 English', 'MFA 2.0 English Adapted', 'MFA 2.0 English Adapt Mapped', 
                                                               'MFA 2.0 English IPA', 'MFA 2.0 English IPA Adapted', 'MFA 2.0 English IPA Adapt Mapped', 
                                                               'MFA 2.0 English Multilingual IPA', 'MFA 2.0 English Multilingual IPA Adapted', 'MFA 2.0 English Multilingual IPA Adapt Mapped'))
mfa2_utterance_metrics$version = '1.0'
mfa2_utterance_metrics[str_detect(mfa2_utterance_metrics$aligner, '2.0'),]$version = '2.0'
mfa2_utterance_metrics$version <- factor(mfa2_utterance_metrics$version)

mfa2_utterance_metrics$phone_set = 'ARPA'
mfa2_utterance_metrics[str_detect(mfa2_utterance_metrics$aligner, 'IPA'),]$phone_set = 'IPA'
mfa2_utterance_metrics$phone_set <- factor(mfa2_utterance_metrics$phone_set)

mfa2_utterance_metrics$IPA_mode = 'Regular'
mfa2_utterance_metrics[str_detect(mfa2_utterance_metrics$aligner, 'Multilingual'),]$IPA_mode = 'Multilingual'
mfa2_utterance_metrics$IPA_mode <- factor(mfa2_utterance_metrics$IPA_mode)

mfa2_utterance_metrics$method = 'Align'
mfa2_utterance_metrics[str_detect(mfa2_utterance_metrics$aligner, 'train'),]$method = 'Train'
mfa2_utterance_metrics[str_detect(mfa2_utterance_metrics$aligner, 'Adapted'),]$method = 'Adapted'
mfa2_utterance_metrics[str_detect(mfa2_utterance_metrics$aligner, 'Adapt Mapped'),]$method = 'Adapt Mapped'
mfa2_utterance_metrics$method <- factor(mfa2_utterance_metrics$method)

plotData <- summarySE(data=subset(mfa2_utterance_metrics, version=='2.0'), measurevar = 'phone_boundary_error', groupvars=c('phone_set', 'IPA_mode', 'method'))

ggplot(aes(x=method, y=mean * 1000), data=plotData) + geom_point(size = 5, color='#FB5607') + facet_grid(phone_set~IPA_mode) + 
  geom_errorbar(aes(ymin = (mean - ci) * 1000, ymax = (mean + ci)* 1000),size=2, width=0.5, color='#FB5607') + 
  ylab('Phone boundary error (ms)') + xlab('Alignment condition') +ggtitle('Phone boundary errors') +
  theme_memcauliffe() +
  scale_x_discrete(guide = guide_axis(n.dodge = 2))
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\mfa2_average_phone_boundary_error.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)

plotData <- summarySE(data=mfa2_word_distances, measurevar = 'distance', groupvars=c('aligner', 'pause_boundary'))

ggplot(aes(x=aligner, y=mean * 1000, color = pause_boundary, shape = pause_boundary), data=plotData) + 
  geom_point(size = 5) + geom_errorbar(aes(ymin = (mean - ci) * 1000, ymax = (mean + ci)* 1000),size=2, width=0.5) + 
  ylab('Distance to annotated time point (ms)') + scale_color_manual(name = 'Boundary with silence', values = cbbPalette) + 
  scale_x_discrete(guide = guide_axis(n.dodge = 2)) + ggtitle("Word boundary distance between aligner and manual annotations") +
  scale_shape_discrete(name = 'Boundary with silence') + xlab('Alignment condition') +theme_memcauliffe()
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\mfa2_word_boundaries.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)

plotData <- summarySE(data=mfa2_phone_distances, measurevar = 'distance', groupvars=c('aligner','type'))

ggplot(aes(x=aligner, y=mean * 1000, color = type, shape=type), data=plotData) + geom_point(size = 5) + 
  geom_errorbar(aes(ymin = (mean - ci) * 1000, ymax = (mean + ci)* 1000),size=2, width=0.5) + 
  ylab('Distance to annotated time point (ms)') + 
  scale_color_manual(name = 'Timepoint', values = cbbPalette) + 
  scale_shape_manual(name = 'Timepoint', values = c(15, 16, 17, 18)) + xlab('Alignment condition') +
  theme_memcauliffe() +
  scale_x_discrete(guide = guide_axis(n.dodge = 2)) + ggtitle('Phone boundary errors in selected CVC words')
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\mfa2_cvc_phone_boundaries.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)
