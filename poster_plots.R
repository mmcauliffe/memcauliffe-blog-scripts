
word_distances$distance <- word_distances$distance * 1000
phone_distances$distance <- phone_distances$distance * 1000
phonsay$distance <- phonsay$diff_mag * 1000
phonsay$diff.std <- NULL

word_distances$error <- cut(word_distances$distance, breaks=c(-1,10,25,50,100,Inf), labels=c('One frame (<10 ms)', 'Small (<25 ms)', 'Medium (<50 ms)', 'Large (<100 ms)', 'Extreme (>100 ms)'))
colors = c('#009E73', '#F0E442', '#E69F00', '#D55E00', '#000000')

phone_distances$error <- cut(phone_distances$distance, breaks=c(-1,10,25,50,100,Inf), labels=c('One frame (<10 ms)', 'Small (<25 ms)', 'Medium (<50 ms)', 'Large (<100 ms)', 'Extreme (>100 ms)'))

phonsay$error <- cut(phonsay$distance, breaks=c(-1,10,25,50,100,Inf), labels=c('One frame (<10 ms)', 'Small (<25 ms)', 'Medium (<50 ms)', 'Large (<100 ms)', 'Extreme (>100 ms)'))

aligners <- c('mfa_librispeech','mfa_flat', 'pla-ls', 'pla-flat', 'fave')
aligners.labels <- c('MFA-\nLibriSpeech','MFA-\nRetrained', 'PLA-\nLibriSpeech', 'PLA-\nRetrained', 'FAVE')
for.poster.wd <- word_distances %>% filter(aligner %in% aligners)#, type == 'begin')
for.poster.wd$aligner = factor(for.poster.wd$aligner, levels= aligners)
for.poster.wd$aligner = factor(for.poster.wd$aligner, labels= aligners.labels)

ggplot(for.poster.wd, aes(x=aligner, y=distance)) + geom_violin() + scale_y_log10(breaks = c(0, 1, 10, 50, 100, 1000))
ggplot(for.poster.wd, aes(colour=aligner, x=distance)) + geom_histogram() + scale_y_log10(breaks = c(0, 1, 10, 50, 100, 1000))

ggplot(for.poster.wd, aes(x=aligner, fill=error)) + geom_bar(aes(y = (..count..)/428586), position=position_dodge(0.9), color='black') +scale_y_continuous(labels = percent_format(),limits=c(0,0.5)) + geom_text(aes( label = scales::percent((..count..)/428586), y= (..count..)/428586 ), stat= "count", vjust = -.5, position=position_dodge(0.9)) + theme_bw() + scale_fill_manual(name='Error tolerance', values= colors) + ylab('Percent of boundaries') + scale_x_discrete() + theme(text = element_text(size = 20)) +ggtitle('Distribution of word boundary errors (Buckeye)') + xlab('Aligner condition')
ggsave('buckeye_word_dist.png', units='cm', width = 40, height=15, dpi=300)



for.poster.pd <- phone_distances %>% filter(aligner %in% aligners)
for.poster.pd$aligner = factor(for.poster.pd$aligner, levels= aligners)
for.poster.pd$aligner = factor(for.poster.pd$aligner, labels= aligners.labels)
ggplot(for.poster.pd, aes(x=aligner, y=distance)) + geom_violin() + scale_y_log10(breaks = c(0, 1, 10, 50, 100, 1000))

ggplot(for.poster.pd, aes(x=aligner, fill=error)) + geom_bar(aes(y = (..count..)/47032), position=position_dodge(0.9), color='black') +scale_y_continuous(labels = percent_format(),limits=c(0,0.5)) + geom_text(aes( label = scales::percent((..count..)/47032), y= (..count..)/47032 ), stat= "count", vjust = -.5, position=position_dodge(0.9)) + theme_bw() + scale_fill_manual(name='Error tolerance', values= colors) + ylab('Percent of boundaries') + scale_x_discrete() + theme(text = element_text(size = 20)) +ggtitle('Distribution of phone boundary errors (Buckeye)') + xlab('Aligner condition')
ggsave('buckeye_phone_dist.png', units='cm', width = 40, height=15, dpi=300)

ggplot(for.poster.pd, aes(x=aligner, fill=error)) + geom_bar(position=position_dodge(0.9))

for.poster.phonsay <- phonsay %>% filter(condition %in% c('MFA-\nFlat', 'MFA-\nLS','PLA-\nFlat', 'PLA-\nLS-Clean', 'FAVE-\nSCOTUS'))
for.poster.phonsay$aligner = factor(for.poster.phonsay$condition, levels= c('MFA-\nLS','MFA-\nFlat', 'PLA-\nLS-Clean', 'PLA-\nFlat',  'FAVE-\nSCOTUS'))
for.poster.phonsay$aligner = factor(for.poster.phonsay$aligner, labels= c('MFA-\nLibriSpeech','MFA-\nRetrained', 'PLA-\nLibriSpeech', 'PLA-\nRetrained',  'FAVE'))

ggplot(for.poster.phonsay, aes(x=condition, fill=error)) + geom_bar(position=position_dodge(0.9))

ggplot(for.poster.phonsay, aes(x=aligner, fill=error)) + geom_bar(aes(y = (..count..)/4428), position=position_dodge(0.9), color='black') +scale_y_continuous(labels = percent_format(),limits=c(0,0.5)) + geom_text(aes( label = scales::percent((..count..)/4428), y= (..count..)/4428 ), stat= "count", vjust = -.5, position=position_dodge(0.9)) + theme_bw() + scale_fill_manual(name='Error tolerance', values= colors) + ylab('Percent of boundaries') + scale_x_discrete() + theme(text = element_text(size = 20)) +ggtitle('Distribution of phone boundary errors (Phonsay)') + xlab('Aligner condition')
ggsave('phonsay_dist.png', units='cm', width = 40, height=15, dpi=300)

comb.pd <- for.poster.pd[,c('aligner', 'error')]
comb.pd$Type <- 'Distribution of phone boundary errors (Buckeye)'

comb.pd <- comb.pd %>% group_by(aligner, error, Type) %>% summarise(count = n()/47032)

comb.wd <- for.poster.wd[,c('aligner', 'error')]
comb.wd$Type <- 'Distribution of word boundary errors (Buckeye)'

comb.wd <- comb.wd %>% group_by(aligner, error, Type) %>% summarise(count = n()/428586)

comb.phonsay <- for.poster.phonsay[,c('aligner', 'error')]
comb.phonsay$Type <- 'Distribution of phone boundary errors (Phonsay)'

comb.phonsay <- comb.phonsay %>% group_by(aligner, error, Type) %>% summarise(count = n()/4428)

comb <- rbind(comb.pd, comb.wd, comb.phonsay)
comb$Type <- factor(comb$Type, levels = c())

ggplot(comb, aes(x=aligner, fill=error)) + geom_bar(aes(y = count), position=position_dodge(0.9), stat= "identity", color='black') +scale_y_continuous(labels = percent_format(),limits=c(0,0.5)) + geom_text(aes( label = scales::percent(count), y= count ), stat= "identity", vjust = -.5, position=position_dodge(0.9)) + theme_bw() + scale_fill_manual(name='Error tolerance', values= colors) + ylab('Percent of boundaries') + scale_x_discrete() + theme(text = element_text(size = 20)) + xlab('Aligner condition') + facet_wrap(~Type, ncol = 1)

ggsave('all_dist.png', units='cm', width = 40, height=45, dpi=300)
