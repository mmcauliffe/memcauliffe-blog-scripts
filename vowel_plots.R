
load_formant_point <- function(name){
  point_file = paste('C:\\Users\\michael\\Documents\\Dev\\aligner-comparison\\analysis\\mm_mic_test\\', name, '_formants.csv', sep='')
  formant_points = read_csv(point_file)
  formant_points[formant_points$phone_label =='iː',]$phone_label = 'i'
  formant_points[formant_points$phone_label =='uː',]$phone_label = 'u'
  formant_points[formant_points$phone_label =='ɑː',]$phone_label = 'ɑ'
  formant_points[formant_points$phone_label =='ɔː',]$phone_label = 'ɔ'
  
  formant_points <- subset(formant_points, !phone_label %in% c('aɪ', 'aʊ'))
  formant_points$noise <- 'Background noise'
  formant_points[str_detect(formant_points$discourse,'_no_'),]$noise <- 'No noise'
  
  formant_points$prototypes <- name
  formant_points$phone_label <- factor(formant_points$phone_label)
  formant_points$speaker <- factor(formant_points$speaker, levels=c('bose', 'hyperx_wired', 'hyperx_wireless', 'hp', 'pred', 'oneplus'), 
                                   labels=c('Bose QC35 II', 'HyperX Cloud 2 wired', 'HyperX Cloud 2 wireless', 'HP laptop', 'Predator laptop', 'OnePlus 6 phone'))
  return(formant_points)
  
}

load_formant_point_single_speaker <- function(name){
  point_file = paste('C:\\Users\\michael\\Documents\\Dev\\aligner-comparison\\analysis\\single_speaker\\', name, '_formants.csv', sep='')
  formant_points = read_csv(point_file)
  formant_points <- subset(formant_points, !phone_label %in% c('i', 'u'))
  formant_points[formant_points$phone_label =='iː',]$phone_label = 'i'
  formant_points[formant_points$phone_label =='uː',]$phone_label = 'u'
  formant_points[formant_points$phone_label =='ɑː',]$phone_label = 'ɑ'
  formant_points[formant_points$phone_label =='ɔː',]$phone_label = 'ɔ'
  
  
  formant_points <- subset(formant_points, !phone_label %in% c('aɪ', 'aʊ'))
  formant_points$noise <- 'Background noise'
  formant_points[str_detect(formant_points$discourse,'_no_'),]$noise <- 'No noise'
  
  formant_points$prototypes <- name
  formant_points$phone_label <- factor(formant_points$phone_label, levels = c('i', 'eɪ', 'ɑ', 'oʊ', 'u', 'ɪ', 'ɛ', 'æ', 'ɔ', 'ʊ'))
  formant_points$speaker <- str_extract(formant_points$discourse, '^(bose|hyperx_wired|hyperx_wireless|hp|pred|oneplus)')
  formant_points$speaker <- factor(formant_points$speaker, levels=c('bose', 'hyperx_wired', 'hyperx_wireless', 'hp', 'pred', 'oneplus'), 
                           labels=c('Bose QC35 II', 'HyperX Cloud 2 wired', 'HyperX Cloud 2 wireless', 'HP laptop', 'Predator laptop', 'OnePlus 6 phone'))
  return(formant_points)
  
}

formant_summary <- function(data){
  plotData = data %>% group_by(speaker, noise, phone_label, prototypes) %>% summarise(mean_F1=mean(F1), mean_F2=mean(F2), N=n(), sd_F1=sd(F1), sd_F2=sd(F2))
  plotData = subset(plotData, N > 3)
  conf.interval=.95
  
  plotData$se_F1 <- plotData$sd_F1 / sqrt(plotData$N)  # Calculate standard error of the mean
  plotData$se_F2 <- plotData$sd_F2 / sqrt(plotData$N)  # Calculate standard error of the mean
  
  # Confidence interval multiplier for standard error
  # Calculate t-statistic for confidence interval:
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- qt(conf.interval/2 + .5, plotData$N-1)
  plotData$ci_F1 <- plotData$se_F1 * ciMult
  plotData$ci_F2 <- plotData$se_F2 * ciMult
  return(plotData)
}


points <- rbind(load_formant_point('base'), load_formant_point('spade-Buckeye'), load_formant_point('spade-SantaBarbara'), load_formant_point('spade-SOTC'))

points <- subset(points, phone_label != 'ɝ')

plotData = formant_summary(points)

ggplot(aes(x=mean_F2, y=mean_F1, color=speaker),data=plotData) + geom_text(aes(label=phone_label), size=10) +theme_memcauliffe() + theme(panel.grid.minor = element_blank()) +
  scale_x_reverse()+scale_y_reverse() +facet_grid(prototypes~noise, scales='free_y') + scale_color_manual(name = 'Microphone setup', values = cbbPalette) +xlab('F2') + ylab('F1') + ggtitle('Vowel spaces across setups (multiple speakers)')
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\polyglot_test\\vowel_spaces.svg',width = blog_width, height = blog_height * 2, units = 'px', dpi =blog_dpi)


single_speaker_points <- rbind(load_formant_point_single_speaker('base'), load_formant_point_single_speaker('spade-Buckeye'), load_formant_point_single_speaker('spade-SantaBarbara'), load_formant_point_single_speaker('spade-SOTC'))

single_speaker_points <- subset(single_speaker_points, phone_label != 'ɝ')

plotData = formant_summary(single_speaker_points)

ggplot(aes(x=mean_F2, y=mean_F1, color=speaker),data=plotData) + geom_text(aes(label=phone_label), size=10) +theme_memcauliffe() + theme(panel.grid.minor = element_blank()) +
  scale_x_reverse()+scale_y_reverse() +facet_grid(prototypes~noise, scales='free_y') + scale_color_manual(name = 'Microphone setup', values = cbbPalette) +xlab('F2') + ylab('F1') + ggtitle('Vowel spaces across setups (single speaker)')
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\polyglot_test\\vowel_spaces_single_speaker.svg',width = blog_width, height = blog_height * 2, units = 'px', dpi =blog_dpi)

test_data <- subset(single_speaker_points, prototypes == 'base' & noise=='No noise' & speaker == 'HyperX Cloud 2 wired')

vowel_palette = c('#277DA1', '#90BE6D', '#F3722C', '#43AA8B', '#F8961E', '#577590', '#F9844A', '#F9C74F', '#4D908E', '#F94144', "#FB5607", "#8338EC", "#FF006E", "#FFBE0B",  "#3A86FF", '#6EC200', '#BA3200')

ggplot(aes(x=F2, y=F1, color=phone_label),data=test_data) + geom_text(aes(label=word), size=7) +theme_memcauliffe() + theme(panel.grid.minor = element_blank()) +
  scale_x_reverse()+scale_y_reverse()   +xlab('F2') + ylab('F1') + ggtitle('Vowel space from base algorithm over no noise with HyperX Cloud 2 wired headset') + scale_color_manual(name='Vowel', values=vowel_palette)
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\polyglot_test\\vowel_spaces_single_speaker_example_words.svg',width = blog_width, height = blog_height * 2, units = 'px', dpi =blog_dpi)

subset(formant_points, phone_label == 'ɝ' & speaker == 'pred')



load_formant_tracks_single_speaker <- function(name){
  point_file = paste('C:\\Users\\michael\\Documents\\Dev\\aligner-comparison\\analysis\\single_speaker\\', name, '_formant_tracks.csv', sep='')
  formant_points = read_csv(point_file)
  formant_points <- subset(formant_points, !phone_label %in% c('i', 'u'))
  formant_points[formant_points$phone_label =='iː',]$phone_label = 'i'
  formant_points[formant_points$phone_label =='uː',]$phone_label = 'u'
  formant_points[formant_points$phone_label =='ɑː',]$phone_label = 'ɑ'
  formant_points[formant_points$phone_label =='ɔː',]$phone_label = 'ɔ'
  
  formant_points$noise <- 'Background noise'
  formant_points[str_detect(formant_points$discourse,'_no_'),]$noise <- 'No noise'
  
  formant_points$prototypes <- name
  #formant_points$phone_label <- factor(formant_points$phone_label, levels = c('aɪ', 'aʊ', 'i', 'eɪ', 'ɑ', 'oʊ', 'u', 'ɪ', 'ɛ', 'æ', 'ɔ', 'ʊ'))
  formant_points$speaker <- str_extract(formant_points$discourse, '^(bose|hyperx_wired|hyperx_wireless|hp|pred|oneplus)')
  formant_points$speaker <- factor(formant_points$speaker, levels=c('bose', 'hyperx_wired', 'hyperx_wireless', 'hp', 'pred', 'oneplus'), 
                                   labels=c('Bose QC35 II', 'HyperX Cloud 2 wired', 'HyperX Cloud 2 wireless', 'HP laptop', 'Predator laptop', 'OnePlus 6 phone'))
  return(formant_points)
  
}
single_speaker_tracks <- rbind(load_formant_tracks_single_speaker('base'), load_formant_tracks_single_speaker('spade-Buckeye'), load_formant_tracks_single_speaker('spade-SantaBarbara'), load_formant_tracks_single_speaker('spade-SOTC'))

test_data <- subset(single_speaker_tracks, prototypes == 'base' & noise=='No noise' & speaker == 'HyperX Cloud 2 wired' & phone_label %in% c('aɪ', 'aʊ', 'eɪ', 'oʊ'))


ggplot(aes(x=time, color=phone_label, fill=phone_label), data=test_data) + theme_memcauliffe() + geom_smooth(aes(y=F1)) + geom_smooth(aes(y=F2)) + ylab('Frequency (Hz)') + xlab('Relative time')+ 
  scale_color_manual(name='Diphthong', values=cbbPalette) +scale_fill_manual(name='Diphthong', values=cbbPalette) + ggtitle('Diphthong trajectories from base algorithm over no noise with HyperX Cloud 2 wired headset')
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\polyglot_test\\diphthong_single_speaker.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)

test_data <- subset(single_speaker_tracks, prototypes == 'base' & noise=='No noise' & speaker == 'HyperX Cloud 2 wired')

plotData = test_data %>% group_by(time, phone_label) %>% summarise(mean_F1=mean(F1), mean_F2=mean(F2), N=n(), sd_F1=sd(F1), sd_F2=sd(F2))
plotData = subset(plotData, N > 2)
conf.interval=.95

plotData$se_F1 <- plotData$sd_F1 / sqrt(plotData$N)  # Calculate standard error of the mean
plotData$se_F2 <- plotData$sd_F2 / sqrt(plotData$N)  # Calculate standard error of the mean

# Confidence interval multiplier for standard error
# Calculate t-statistic for confidence interval:
# e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
ciMult <- qt(conf.interval/2 + .5, plotData$N-1)
plotData$ci_F1 <- plotData$se_F1 * ciMult
plotData$ci_F2 <- plotData$se_F2 * ciMult

ggplot(aes(x=mean_F2, y=mean_F1, color=phone_label),data=plotData) +geom_path(aes(group= phone_label), arrow = arrow()) +theme_memcauliffe()  +scale_x_reverse()+scale_y_reverse() + scale_color_manual(name='Vowel', values=vowel_palette)


sib_file = 'C:\\Users\\michael\\Documents\\Dev\\SPADE\\mm_mictest\\mm_mictest_sibilants.csv'
sibilants = read_csv(sib_file)
sibilants$noise <- 'Background noise'
sibilants[str_detect(sibilants$discourse,'_no_'),]$noise <- 'No noise'
sibilants$speaker <- factor(sibilants$speaker, levels=c('bose', 'hyperx_wired', 'hyperx_wireless', 'hp', 'pred', 'oneplus'), 
                                 labels=c('Bose QC35 II', 'HyperX Cloud 2 wired', 'HyperX Cloud 2 wireless', 'HP laptop', 'Predator laptop', 'OnePlus 6 phone'))

plotData = sibilants %>% group_by(speaker, noise, phone_label) %>% summarise(mean_cog=mean(cog), N=n(), sd_cog=sd(cog))
plotData = subset(plotData, N > 3)
conf.interval=.95

plotData$se_cog <- plotData$sd_cog / sqrt(plotData$N)  # Calculate standard error of the mean

# Confidence interval multiplier for standard error
# Calculate t-statistic for confidence interval:
# e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
ciMult <- qt(conf.interval/2 + .5, plotData$N-1)
plotData$ci_cog <- plotData$se_cog * ciMult

ggplot(aes(x=speaker, y=mean_cog, color=phone_label),data=plotData) + geom_point(size=5) +
  geom_errorbar(aes(ymin=mean_cog-ci_cog, ymax=mean_cog+ci_cog),size=1.5, width=0.5) +theme_memcauliffe()  + ylab('Center of Gravity (Hz)') +
  facet_grid(~noise) + scale_color_manual(name = 'Sibilant', values = cbbPalette) + scale_x_discrete(name='Microphone setup', guide = guide_axis(n.dodge = 2))
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\polyglot_test\\sibilants.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)
