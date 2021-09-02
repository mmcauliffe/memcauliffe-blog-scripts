
cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

top_left = c(0.05,0.95)

plotData <- summarySE(data=phonsay, measurevar = 'diff_mag', groupvars=c('condition','type'))

ggplot(aes(x=condition, y=diff_mag * 1000, color = type, shape=type), data=plotData) + geom_point(size = 5) + geom_errorbar(aes(ymin = (diff_mag - ci) * 1000, ymax = (diff_mag + ci)* 1000),size=2, width=0.5) + ylab('Distance to annotated time point (ms)') + scale_color_manual(name = 'Timepoint', values = cbbPalette) + scale_shape_discrete(name = 'Timepoint') + xlab('Alignment condition') +theme_bw() + theme(legend.justification = top_left, legend.position = top_left) + scale_y_continuous(breaks = c(0,25,50,75), limits=c(0,75)) + theme(text = element_text(size=32))
ggsave('timepoint_overall.png',width = 6, height = 9, units = 'in', dpi =300)


plotData <- summarySE(data=subset(phonsay, type == 'Vowel begin point'), measurevar = 'diff_mag', groupvars=c('prec_consonant','data', 'aligner'))

ggplot(aes(x=prec_consonant, y=diff_mag * 1000), data=plotData) + geom_point(size = 5) + geom_errorbar(aes(ymin = (diff_mag - ci) * 1000, ymax = (diff_mag + ci)* 1000),size=2, width=0.5) + ylab('Distance to annotated time point (ms)') +ggtitle('Vowel begin point data only') + xlab('Previous consonant') + scale_color_hue(name = 'Alignment style') + facet_grid(data~aligner) + theme_bw() + theme(text = element_text(size=24))+ylim(c(-5,125))
ggsave('vow_begin.png',width = 9, height = 12, units = 'in', dpi =300)

plotData <- summarySE(data=subset(phonsay, type == 'Vowel end point'), measurevar = 'diff_mag', groupvars=c('foll_consonant','data', 'aligner'))

ggplot(aes(x=foll_consonant, y=diff_mag * 1000), data=plotData) + geom_point(size = 5) + geom_errorbar(aes(ymin = (diff_mag - ci) * 1000, ymax = (diff_mag + ci)* 1000),size=2, width=0.5) + ylab('Distance to annotated time point (ms)') +ggtitle('Vowel end point data only') + xlab('Following obstruent') + facet_grid(data~aligner) + theme_bw() + theme(text = element_text(size=24))+ylim(c(-5,125))
ggsave('vow_end.png',width = 9, height = 12, units = 'in', dpi =300)

plotData <- summarySE(data=subset(phonsay, type == 'Obstruent end point'), measurevar = 'diff_mag', groupvars=c('foll_consonant','data', 'aligner'))

ggplot(aes(x=foll_consonant, y=diff_mag * 1000), data=plotData) + geom_point(size = 5) + geom_errorbar(aes(ymin = (diff_mag - ci) * 1000, ymax = (diff_mag + ci)* 1000),size=2, width=0.5) + ylab('Distance to annotated time point (ms)') +ggtitle('Obstruent end point data only') + xlab('Following obstruent') + scale_color_hue(name = 'Alignment style') + facet_grid(data~aligner) + theme_bw() + theme(text = element_text(size=24))+ylim(c(-5,125))
ggsave('cons_end.png',width = 9, height = 12, units = 'in', dpi =300)

plotData <- summarySE(data=phonsay.duration, measurevar = 'diff_mag', groupvars=c('condition','type'))

ggplot(aes(x=condition, y=diff_mag * 1000, color = type, shape=type), data=plotData) + geom_point(size = 5) + geom_errorbar(aes(ymin = (diff_mag - ci) * 1000, ymax = (diff_mag + ci)* 1000),size=2, width=0.5) + ylab('Difference from annotated duration (ms)') + scale_color_manual(name = 'Segment type', labels = c('Vowel','Obstruent'), values = cbbPalette.2) + scale_shape_discrete(name = 'Segment type', labels = c('Vowel','Obstruent')) + xlab('Alignment condition') +theme_bw() + theme(legend.justification = top_left, legend.position = top_left)  + scale_y_continuous(breaks = c(0,25,50,75), limits = c(0,75)) + theme(text = element_text(size=32))
ggsave('duration_overall.png',width = 6, height = 9, units = 'in', dpi =300)