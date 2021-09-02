

ggplot(aes(x=condition, y=diff), data=d) + stat_summary(fun.data="mean_cl_boot", aes(color=type)) + stat_summary(fun.y=mean, geom="line", aes(color=type, group=type)) + ylab('Annotated time - aligned time (s)') + scale_color_hue(name = 'Timepoint', labels = c('Onset of vowel', 'Vowel-consonant boundary', 'Consonant end')) + xlab('Alignment style')
ggsave('overall.pdf',width = 6, height = 4, units = 'in', dpi =300)

ggplot(aes(x=prec_consonant, y=diff), data=subset(d, type == 'vowel_begin')) + stat_summary(fun.data="mean_cl_boot", aes(color=condition)) + stat_summary(fun.y=mean, geom="line", aes(color=condition, group=condition)) + ylab('Annotated time - aligned time (s)') +ggtitle('Vowel onset data only') + xlab('Previous consonant') + scale_color_hue(name = 'Alignment style')
ggsave('vowelonset.pdf',width = 6, height = 4, units = 'in', dpi =300)

ggplot(aes(x=foll_consonant, y=diff), data=subset(d, type != 'vowel_begin')) + stat_summary(fun.data="mean_cl_boot", aes(color=condition, shape = condition, group = interaction(condition,type))) + stat_summary(fun.y=mean, geom="line", aes(color=condition, group=interaction(condition,type), linetype = type)) + ylab('Annotated time - aligned time (s)') + facet_wrap(~type) +ggtitle('Consonant boundary data only')+ scale_linetype_discrete(name = 'Timepoint', labels = c('Vowel-consonant boundary', 'Consonant end')) + scale_color_discrete(name = 'Alignment style') + scale_shape_discrete(name = 'Alignment style') + xlab('Following consonant')
ggsave('consonantboundary.pdf',width = 6, height = 4, units = 'in', dpi =300)

ggplot(aes(x=vowel, y=diff), data=subset(d, type != 'cons_end')) + stat_summary(fun.data="mean_cl_boot", aes(color=condition, shape = condition, group = interaction(condition,type))) + stat_summary(fun.y=mean, geom="line", aes(color=condition, group=interaction(condition,type), linetype = type)) + ylab('Annotated time - aligned time (s)') + facet_wrap(~type)+ scale_linetype_discrete(name = 'Timepoint', labels = c('Vowel-consonant boundary', 'Consonant end')) + scale_color_discrete(name = 'Alignment style') + scale_shape_discrete(name = 'Alignment style') + xlab('Vowel')

#MAGNITUDE

ggplot(aes(x=condition, y=diff_mag), data=d) + stat_summary(fun.data="mean_cl_boot", aes(color=type)) + stat_summary(fun.y=mean, geom="line", aes(color=type, group=type)) + ylab('Annotated time - aligned time (s)') + scale_color_hue(name = 'Timepoint', labels = c('Onset of vowel', 'Vowel-consonant boundary', 'Consonant end')) + xlab('Alignment style')

ggplot(aes(x=prec_consonant, y=diff_mag), data=subset(d, type == 'vowel_begin')) + stat_summary(fun.data="mean_cl_boot", aes(color=condition)) + stat_summary(fun.y=mean, geom="line", aes(color=condition, group=condition)) + ylab('Annotated time - aligned time (s)') +ggtitle('Vowel onset data only') + xlab('Previous consonant') + scale_color_hue(name = 'Alignment style') + facet_wrap(~condition, scales='free')

ggplot(aes(x=foll_consonant, y=diff_mag), data=subset(d, type != 'vowel_begin')) + stat_summary(fun.data="mean_cl_boot", aes(color=condition, shape = condition, group = interaction(condition,type))) + stat_summary(fun.y=mean, geom="line", aes(color=condition, group=interaction(condition,type), linetype = type)) + ylab('Annotated time - aligned time (s)') + facet_wrap(~type) +ggtitle('Consonant boundary data only')+ scale_linetype_discrete(name = 'Timepoint', labels = c('Vowel-consonant boundary', 'Consonant end')) + scale_color_discrete(name = 'Alignment style') + scale_shape_discrete(name = 'Alignment style') + xlab('Following consonant')

ggplot(aes(x=vowel, y=diff_mag), data=subset(d, type != 'cons_end')) + stat_summary(fun.data="mean_cl_boot", aes(color=condition, shape = condition, group = interaction(condition,type))) + stat_summary(fun.y=mean, geom="line", aes(color=condition, group=interaction(condition,type), linetype = type)) + ylab('Annotated time - aligned time (s)') + facet_wrap(~type) +ggtitle('Consonant boundary data only')+ scale_linetype_discrete(name = 'Timepoint', labels = c('Vowel-consonant boundary', 'Consonant end')) + scale_color_discrete(name = 'Alignment style') + scale_shape_discrete(name = 'Alignment style') + xlab('Vowel')

