

multilingual_utterance_metrics <- subset(utterance_metrics, aligner %in% c('MFA English','MFA default train', 
                                                                           'MFA English IPA','MFA English IPA train',
                                                                           'MFA English Multilingual IPA train'))
multilingual_word_distances <- subset(word_distances, aligner %in% c('MFA English','MFA default train', 
                                                                           'MFA English IPA','MFA English IPA train',
                                                                           'MFA English Multilingual IPA train'))
multilingual_phone_distances <- subset(phone_distances, aligner %in% c('MFA English','MFA default train', 
                                                                           'MFA English IPA','MFA English IPA train',
                                                                           'MFA English Multilingual IPA train'))

plotData <- summarySE(data=multilingual_utterance_metrics, measurevar = 'phone_boundary_error', groupvars=c('aligner'))

ggplot(aes(x=aligner, y=mean * 1000), data=plotData) + geom_point(size = 5, color='#FB5607') + 
  geom_errorbar(aes(ymin = (mean - ci) * 1000, ymax = (mean + ci)* 1000),size=2, width=0.5, color='#FB5607') + 
  ylab('Phone boundary error (ms)') + xlab('Alignment condition') +ggtitle('Phone boundary errors') +
  theme_memcauliffe() +
  scale_x_discrete(guide = guide_axis(n.dodge = 2))
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\multilingual_average_phone_boundary_error.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)

plotData <- summarySE(data=multilingual_word_distances, measurevar = 'distance', groupvars=c('aligner', 'pause_boundary'))

ggplot(aes(x=aligner, y=mean * 1000, color = pause_boundary, shape = pause_boundary), data=plotData) + 
  geom_point(size = 5) + geom_errorbar(aes(ymin = (mean - ci) * 1000, ymax = (mean + ci)* 1000),size=2, width=0.5) + 
  ylab('Distance to annotated time point (ms)') + scale_color_manual(name = 'Boundary with silence', values = cbbPalette) + 
  scale_x_discrete(guide = guide_axis(n.dodge = 2)) + ggtitle("Word boundary distance between aligner and manual annotations") +
  scale_shape_discrete(name = 'Boundary with silence') + xlab('Alignment condition') +theme_memcauliffe()
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\multilingual_word_boundaries.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)

plotData <- summarySE(data=multilingual_phone_distances, measurevar = 'distance', groupvars=c('aligner','type'))

ggplot(aes(x=aligner, y=mean * 1000, color = type, shape=type), data=plotData) + geom_point(size = 5) + 
  geom_errorbar(aes(ymin = (mean - ci) * 1000, ymax = (mean + ci)* 1000),size=2, width=0.5) + 
  ylab('Distance to annotated time point (ms)') + 
  scale_color_manual(name = 'Timepoint', values = cbbPalette) + 
  scale_shape_manual(name = 'Timepoint', values = c(15, 16, 17, 18)) + xlab('Alignment condition') +
  theme_memcauliffe() +
  scale_x_discrete(guide = guide_axis(n.dodge = 2)) + ggtitle('Phone boundary errors in selected CVC words')
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\multilingual_cvc_phone_boundaries.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)
