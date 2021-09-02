

cbbPalette <- c("#FB5607", "#8338EC", "#FF006E", "#FFBE0B",  "#3A86FF")

top_left = c(0.05,0.95)

ggplot(aes(x=distance*1000), data = word_distances) +geom_histogram()+facet_wrap(~aligner)

ggplot(aes(y=distance, x=aligner), data = word_distances) +geom_violin()+facet_wrap(~pause_boundary)

plotData <- summarySE(data=word_distances, measurevar = 'distance', groupvars=c('aligner', 'pause_boundary'))

ggplot(aes(x=aligner, y=mean * 1000, color = pause_boundary, shape = pause_boundary), data=plotData) + 
  geom_point(size = 5) + geom_errorbar(aes(ymin = (mean - ci) * 1000, ymax = (mean + ci)* 1000),size=2, width=0.5) + 
  ylab('Distance to annotated time point (ms)') + scale_color_manual(name = 'Boundary with silence', values = cbbPalette) + 
  scale_x_discrete(guide = guide_axis(n.dodge = 2)) + ggtitle("Word boundary distance between aligner and manual annotations") +
  scale_shape_discrete(name = 'Boundary with silence') + xlab('Alignment condition') +theme_memcauliffe()
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\word_boundaries.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)

plotData <- summarySE(data=phone_distances, measurevar = 'distance', groupvars=c('aligner','type'))

ggplot(aes(x=aligner, y=mean * 1000, color = type, shape=type), data=plotData) + geom_point(size = 5) + 
  geom_errorbar(aes(ymin = (mean - ci) * 1000, ymax = (mean + ci)* 1000),size=2, width=0.5) + 
  ylab('Distance to annotated time point (ms)') + 
  scale_color_manual(name = 'Timepoint', values = cbbPalette) + 
  scale_shape_manual(name = 'Timepoint', values = c(15, 16, 17, 18)) + xlab('Alignment condition') +
  theme_memcauliffe() +
  scale_x_discrete(guide = guide_axis(n.dodge = 2)) + ggtitle('Phone boundary errors in selected CVC words')
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\cvc_phone_boundaries.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)

plotData <- summarySE(data=no_yknows, measurevar = 'phone_boundary_error', groupvars=c('aligner'))

ggplot(aes(x=aligner, y=mean * 1000), data=plotData) + geom_point(size = 5, color='#FB5607') + 
  geom_errorbar(aes(ymin = (mean - ci) * 1000, ymax = (mean + ci)* 1000),size=2, width=0.5, color='#FB5607') + 
  ylab('Phone boundary error (ms)') + xlab('Alignment condition') +ggtitle('Phone boundary errors') +
  theme_memcauliffe() +
  scale_x_discrete(guide = guide_axis(n.dodge = 2))
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\average_phone_boundary_error.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)

plotData <- summarySE(data=no_yknows, measurevar = 'num_insertions', groupvars=c('aligner'))

ggplot(aes(x=aligner, y=mean), data=plotData) + geom_point(size = 5, color='#FB5607') + 
  geom_errorbar(aes(ymin = (mean - ci), ymax = (mean + ci)),size=2, width=0.5, color='#FB5607') + 
  ylab('Number of insertions') + xlab('Alignment condition') + ggtitle('Phone insertion by aligner') +
  theme_memcauliffe() + #theme(legend.justification = top_left, legend.position = top_left) + 
  scale_x_discrete(guide = guide_axis(n.dodge = 2))
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\num_insertions.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)

plotData <- summarySE(data=no_yknows, measurevar = 'num_deletions', groupvars=c('aligner'))

ggplot(aes(x=aligner, y=mean), data=plotData) + geom_point(size = 5, color='#FB5607') + 
  geom_errorbar(aes(ymin = (mean - ci), ymax = (mean + ci)),size=2, width=0.5, color='#FB5607') + 
  ylab('Number of deletions') + xlab('Alignment condition') + ggtitle('Phone deletion by aligner')  + theme_memcauliffe() +
  scale_x_discrete(guide = guide_axis(n.dodge = 2)) + scale_y_continuous(limits=c(0, 0.4))
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\num_deletions.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)



plotData <- summarySE(data=no_yknows, measurevar = 'phone_boundary_error', groupvars=c('aligner', 'speaker'))

ggplot(aes(x=aligner, y=mean * 1000), data=plotData) + geom_point(size = 2, color='#FB5607') + 
  geom_errorbar(aes(ymin = (mean - ci) * 1000, ymax = (mean + ci)* 1000),size=1, width=0.5, color='#FB5607') + 
  ylab('Phone boundary error (ms)') + xlab('Alignment condition') + facet_wrap(~speaker) + ggtitle('Speaker analysis of phone boundary errors') +
  theme_memcauliffe() + #theme(legend.justification = top_left, legend.position = top_left) + 
  scale_x_discrete(guide = guide_axis(n.dodge = 2), labels=c('FAVE', 'MAUS', 'MFA', 'MFA', 'MFA', 'MFA', 'MFA', 'MFA')) + 
  theme(axis.text = element_text(size = rel(0.8), colour = "#FFD60A"), panel.grid.major = element_line(size = 0.1, linetype = 'solid', colour = "#FFC300"), 
                                                                       panel.grid.minor = element_line(size = 0.05, linetype = 'solid', colour = "#FFD60A"),)
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\speaker_analysis.svg',width = blog_width, height = blog_height*2, units = 'px', dpi =blog_dpi)

benchmark %>% group_by(Name) %>% summarise(log_like=mean(`Final log-likelihood`), time= mean(`Total time`)) -> timing_summary

ggplot(aes(x=Name, y=log_like), data=timing_summary) + geom_point(size=5, colour = "#FB5607") + ylab('Align log-likelihood')+ xlab('Alignment condition') + theme_memcauliffe() + 
  ggtitle("Final alignment log-likelihood") + scale_x_discrete(guide = guide_axis(n.dodge = 2))
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\log_like.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)

ggplot(aes(x=Name, y=(time /60)/60), data=timing_summary) + geom_point(size=5, colour = "#FB5607") + ylab('Time (hours)')+ xlab('Alignment condition') + theme_bw() + ggtitle("Time to generate alignment") + 
  scale_y_continuous(limits=c(0, 1.6)) + theme_memcauliffe() +scale_x_discrete(guide = guide_axis(n.dodge = 2))
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\timing.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)
