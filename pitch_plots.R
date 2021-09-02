load_pitch_track <- function(name){
  point_file = paste('C:\\Users\\michael\\Documents\\Dev\\aligner-comparison\\analysis\\mm_mic_test\\', name, '_pitch.csv', sep='')
  tracks = read_csv(point_file)
  #tracks[tracks$phone_label =='iː',]$phone_label = 'i'
  #tracks[tracks$phone_label =='uː',]$phone_label = 'u'
  #tracks[tracks$phone_label =='ɑː',]$phone_label = 'ɑ'
  #tracks[tracks$phone_label =='ɔː',]$phone_label = 'ɔ'
  
  #tracks <- subset(tracks, !phone_label %in% c('aɪ', 'aʊ'))
  tracks$noise <- 'Background noise'
  tracks[str_detect(tracks$discourse,'_no_'),]$noise <- 'No noise'
  tracks$story <- 'North Wind'
  tracks[str_detect(tracks$discourse,'duke'),]$story <- 'Fridland passage'
  tracks$speaker <- factor(tracks$speaker, levels=c('bose', 'hyperx_wired', 'hyperx_wireless', 'hp', 'pred', 'oneplus'), 
                                   labels=c('Bose QC35 II', 'HyperX Cloud 2 wired', 'HyperX Cloud 2 wireless', 'HP laptop', 'Predator laptop', 'OnePlus 6 phone'))
  
  tracks$source <- name
  #tracks$phone_label <- factor(tracks$phone_label)
  return(tracks)
  
}


pitch_color = c( "#FF006E", '#6EC200', '#BA3200')

pitch_tracks <- rbind(load_pitch_track('praat'), load_pitch_track('reaper'))
pitch_tracks[!is.na(pitch_tracks$F0) & pitch_tracks$F0 < 0,]$F0 <- NA

pitch_tracks$actual_time <- (pitch_tracks$time * (pitch_tracks$word_end - pitch_tracks$word_begin)) + pitch_tracks$word_begin


ggplot(aes(x=actual_time, y=F0, color=source, group=source), data=subset(pitch_tracks, story =='North Wind')) + theme_memcauliffe() + geom_line(size=1) + facet_grid(speaker~noise, scales = 'free_y') + 
  scale_color_manual(name = 'Pitch source', values = pitch_color) + ggtitle('Pitch tracks for readings of the North Wind and the Sun') + xlab('Time (s)') + ylab('F0 (Hz)') + theme(panel.grid.minor = element_blank())
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\polyglot_test\\pitch_north_wind.svg',width = blog_width, height = blog_height * 3, units = 'px', dpi =blog_dpi)

ggplot(aes(x=actual_time, y=F0, color=source, group=source), data=subset(pitch_tracks, story =='Fridland passage')) + theme_memcauliffe() + geom_line(size=1) + facet_grid(speaker~noise, scales = 'free_y') + 
  scale_color_manual(name = 'Pitch source', values = pitch_color) + ggtitle('Pitch tracks for readings of the Fridland passage') + xlab('Time (s)') + ylab('F0 (Hz)') + theme(panel.grid.minor = element_blank())
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\polyglot_test\\pitch_fridland.svg',width = blog_width, height = blog_height * 3, units = 'px', dpi =blog_dpi)

load_pitch_single_speaker_track <- function(name){
  point_file = paste('C:\\Users\\michael\\Documents\\Dev\\aligner-comparison\\analysis\\single_speaker\\', name, '_pitch.csv', sep='')
  tracks = read_csv(point_file)
  #tracks[tracks$phone_label =='iː',]$phone_label = 'i'
  #tracks[tracks$phone_label =='uː',]$phone_label = 'u'
  #tracks[tracks$phone_label =='ɑː',]$phone_label = 'ɑ'
  #tracks[tracks$phone_label =='ɔː',]$phone_label = 'ɔ'
  
  #tracks <- subset(tracks, !phone_label %in% c('aɪ', 'aʊ'))
  tracks$noise <- 'Background noise'
  tracks[str_detect(tracks$discourse,'_no_'),]$noise <- 'No noise'
  tracks$story <- 'North Wind'
  tracks[str_detect(tracks$discourse,'duke'),]$story <- 'Fridland passage'
  tracks$speaker <- str_extract(tracks$discourse, '^(bose|hyperx_wired|hyperx_wireless|hp|pred|oneplus)')
  tracks$speaker <- factor(tracks$speaker, levels=c('bose', 'hyperx_wired', 'hyperx_wireless', 'hp', 'pred', 'oneplus'), 
                           labels=c('Bose QC35 II', 'HyperX Cloud 2 wired', 'HyperX Cloud 2 wireless', 'HP laptop', 'Predator laptop', 'OnePlus 6 phone'))
  
  tracks$source <- name
  #tracks$phone_label <- factor(tracks$phone_label)
  return(tracks)
  
}


single_speaker_pitch_tracks <- rbind(load_pitch_single_speaker_track('praat'), load_pitch_single_speaker_track('reaper'))
single_speaker_pitch_tracks[!is.na(single_speaker_pitch_tracks$F0) & single_speaker_pitch_tracks$F0 < 0,]$F0 <- NA

single_speaker_pitch_tracks$actual_time <- (single_speaker_pitch_tracks$time * (single_speaker_pitch_tracks$word_end - single_speaker_pitch_tracks$word_begin)) + single_speaker_pitch_tracks$word_begin
single_speaker_pitch_tracks$time_section <- cut(single_speaker_pitch_tracks$actual_time, c(0,9,18,27,36), labels=c('0-9 seconds', '9-18 seconds', '18-27 seconds', '27-36 seconds'))

summary(subset(single_speaker_pitch_tracks, discourse =='bose_no_noise' & source =='reaper'))

t = subset(single_speaker_pitch_tracks, discourse =='bose_no_noise')

word_data = t %>% group_by(word_label, word_begin, word_end) %>% summarise(word_begin =mean(word_begin), word_end= mean(word_end))

word_data$x = word_data$word_begin + ((word_data$word_end - word_data$word_begin) / 2)
word_data$y = 40
word_data$time_section <- cut(word_data$x, c(0,9,18,27,36), labels=c('0-9 seconds', '9-18 seconds', '18-27 seconds', '27-36 seconds'))
word_data$ymin= 50
word_data$ymax= 250

ggplot() + theme_memcauliffe() + geom_rect(aes(xmin=word_begin, xmax=word_end), ymin=-Inf, ymax=Inf, fill="#003566", alpha=0.75, color="#FFD60A", group=NA, data=word_data) + geom_line(aes(x=actual_time, y=F0, color=source, group=source), data=t,size=1,position = position_dodge(width=0.04)) + #geom_ribbon(aes(x=actual_time, y=F0, fill=source,ymin=F0-3,ymax=F0+3), color=NA,alpha=0.5, data=t) + 
  scale_color_manual(name = 'Pitch source', values = pitch_color) + scale_fill_manual(name = 'Pitch source', values = pitch_color) + ggtitle('Pitch tracks for bose_no_noise reading of the North Wind and the Sun') + 
  xlab('Time (s)') + ylab('F0 (Hz)') + theme(panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(), panel.background = element_rect(fill = "#000814", color = "#000814")) + facet_wrap(time_section~., scales = 'free', ncol=1) + 
  geom_text(aes(label=word_label, x=x, y=y), color='white', group=NA,data=word_data) + geom_vline(aes(xintercept=word_begin), color='#FFD60A', group=NA,data=word_data) + 
  geom_vline(aes(xintercept=word_end), color='#FFD60A', group=NA,data=word_data) + scale_x_continuous(breaks=c(0,5,10,15,20,25,30,35,40))
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\polyglot_test\\pitch_north_wind_single_bose_no_noise.svg',width = blog_width, height = blog_height * 2, units = 'px', dpi =blog_dpi)


t = subset(single_speaker_pitch_tracks, discourse =='hyperx_wired_noise')

word_data = t %>% group_by(word_label, word_begin, word_end) %>% summarise(word_begin =mean(word_begin), word_end= mean(word_end))

word_data$x = word_data$word_begin + ((word_data$word_end - word_data$word_begin) / 2)
word_data$y = 40
word_data$time_section <- cut(word_data$x, c(0,9,18,27,36), labels=c('0-9 seconds', '9-18 seconds', '18-27 seconds', '27-36 seconds'))
word_data$ymin= 50
word_data$ymax= 250

ggplot() + theme_memcauliffe() + geom_rect(aes(xmin=word_begin, xmax=word_end), ymin=-Inf, ymax=Inf, fill="#003566", alpha=0.75, color="#FFD60A", group=NA, data=word_data) + geom_line(aes(x=actual_time, y=F0, color=source, group=source), data=t,size=1,position = position_dodge(width=0.04)) + #geom_ribbon(aes(x=actual_time, y=F0, fill=source,ymin=F0-3,ymax=F0+3), color=NA,alpha=0.5, data=t) + 
  scale_color_manual(name = 'Pitch source', values = pitch_color) + scale_fill_manual(name = 'Pitch source', values = pitch_color) + ggtitle('Pitch tracks for hyperx_wired_noise reading of the North Wind and the Sun') + 
  xlab('Time (s)') + ylab('F0 (Hz)') + theme(panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(), panel.background = element_rect(fill = "#000814", color = "#000814")) + facet_wrap(time_section~., scales = 'free', ncol=1) + 
  geom_text(aes(label=word_label, x=x, y=y), color='white', group=NA,data=word_data) + geom_vline(aes(xintercept=word_begin), color='#FFD60A', group=NA,data=word_data) + 
  geom_vline(aes(xintercept=word_end), color='#FFD60A', group=NA,data=word_data) + scale_x_continuous(breaks=c(0,5,10,15,20,25,30,35,40))
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\polyglot_test\\pitch_north_wind_single_hyperx_wired_noise.svg',width = blog_width, height = blog_height * 2, units = 'px', dpi =blog_dpi)


ggplot(aes(x=actual_time, y=F0, color=source, group=source), data=subset(single_speaker_pitch_tracks, story =='North Wind')) + theme_memcauliffe() + geom_line(size=1,position = position_dodge(width=0.04)) + facet_grid(speaker~noise, scales = 'free_y') + 
  scale_color_manual(name = 'Pitch source', values = pitch_color) + ggtitle('Pitch tracks for readings of the North Wind and the Sun') + xlab('Time (s)') + ylab('F0 (Hz)') + theme(panel.grid.minor = element_blank())
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\polyglot_test\\pitch_north_wind_single.svg',width = blog_width, height = blog_height * 3, units = 'px', dpi =blog_dpi)

ggplot(aes(x=actual_time, y=F0, color=source, group=source), data=subset(single_speaker_pitch_tracks, story =='Fridland passage')) + theme_memcauliffe() + geom_line(size=1,position = position_dodge(width=0.04)) + facet_grid(speaker~noise, scales = 'free_y') + 
  scale_color_manual(name = 'Pitch source', values = pitch_color) + ggtitle('Pitch tracks for readings of the Fridland passage') + xlab('Time (s)') + ylab('F0 (Hz)') + theme(panel.grid.minor = element_blank())
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\polyglot_test\\pitch_fridland_single.svg',width = blog_width, height = blog_height * 3, units = 'px', dpi =blog_dpi)

## BASE PITCH ALGORITHM

load_base_pitch_single_speaker_track <- function(name){
  point_file = paste('C:\\Users\\michael\\Documents\\Dev\\aligner-comparison\\analysis\\single_speaker\\base_', name, '_pitch.csv', sep='')
  tracks = read_csv(point_file)
  #tracks[tracks$phone_label =='iː',]$phone_label = 'i'
  #tracks[tracks$phone_label =='uː',]$phone_label = 'u'
  #tracks[tracks$phone_label =='ɑː',]$phone_label = 'ɑ'
  #tracks[tracks$phone_label =='ɔː',]$phone_label = 'ɔ'
  
  #tracks <- subset(tracks, !phone_label %in% c('aɪ', 'aʊ'))
  tracks$noise <- 'Background noise'
  tracks[str_detect(tracks$discourse,'_no_'),]$noise <- 'No noise'
  tracks$story <- 'North Wind'
  tracks[str_detect(tracks$discourse,'duke'),]$story <- 'Fridland passage'
  tracks$speaker <- str_extract(tracks$discourse, '^(bose|hyperx_wired|hyperx_wireless|hp|pred|oneplus)')
  tracks$speaker <- factor(tracks$speaker, levels=c('bose', 'hyperx_wired', 'hyperx_wireless', 'hp', 'pred', 'oneplus'), 
                           labels=c('Bose QC35 II', 'HyperX Cloud 2 wired', 'HyperX Cloud 2 wireless', 'HP laptop', 'Predator laptop', 'OnePlus 6 phone'))
  
  tracks$source <- name
  #tracks$phone_label <- factor(tracks$phone_label)
  return(tracks)
  
}

base_single_speaker_pitch_tracks <- rbind(load_base_pitch_single_speaker_track('praat'), load_base_pitch_single_speaker_track('reaper'))
base_single_speaker_pitch_tracks[!is.na(base_single_speaker_pitch_tracks$F0) & base_single_speaker_pitch_tracks$F0 < 0,]$F0 <- NA

base_single_speaker_pitch_tracks$actual_time <- (base_single_speaker_pitch_tracks$time * (base_single_speaker_pitch_tracks$word_end - base_single_speaker_pitch_tracks$word_begin)) + base_single_speaker_pitch_tracks$word_begin
base_single_speaker_pitch_tracks$time_section <- cut(base_single_speaker_pitch_tracks$actual_time, c(0,9,18,27,36), labels=c('0-9 seconds', '9-18 seconds', '18-27 seconds', '27-36 seconds'))

summary(subset(base_single_speaker_pitch_tracks, discourse =='bose_no_noise' & source =='reaper'))

t = subset(base_single_speaker_pitch_tracks, discourse =='bose_no_noise')

word_data = t %>% group_by(word_label, word_begin, word_end) %>% summarise(word_begin =mean(word_begin), word_end= mean(word_end))

word_data$x = word_data$word_begin + ((word_data$word_end - word_data$word_begin) / 2)
word_data$y = 40
word_data$time_section <- cut(word_data$x, c(0,9,18,27,36), labels=c('0-9 seconds', '9-18 seconds', '18-27 seconds', '27-36 seconds'))
word_data$ymin= 50
word_data$ymax= 250

ggplot() + theme_memcauliffe() + geom_rect(aes(xmin=word_begin, xmax=word_end), ymin=-Inf, ymax=Inf, fill="#003566", alpha=0.75, color="#FFD60A", group=NA, data=word_data) + geom_line(aes(x=actual_time, y=F0, color=source, group=source), data=t,size=1,position = position_dodge(width=0.04)) + #geom_ribbon(aes(x=actual_time, y=F0, fill=source,ymin=F0-3,ymax=F0+3), color=NA,alpha=0.5, data=t) + 
  scale_color_manual(name = 'Pitch source', values = pitch_color) + scale_fill_manual(name = 'Pitch source', values = pitch_color) + ggtitle('Pitch tracks for bose_no_noise reading of the North Wind and the Sun') + 
  xlab('Time (s)') + ylab('F0 (Hz)') + theme(panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(), panel.background = element_rect(fill = "#000814", color = "#000814")) + facet_wrap(time_section~., scales = 'free', ncol=1) + 
  geom_text(aes(label=word_label, x=x, y=y), color='white', group=NA,data=word_data) + geom_vline(aes(xintercept=word_begin), color='#FFD60A', group=NA,data=word_data) + 
  geom_vline(aes(xintercept=word_end), color='#FFD60A', group=NA,data=word_data) + scale_x_continuous(breaks=c(0,5,10,15,20,25,30,35,40))
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\polyglot_test\\pitch_north_wind_single_bose_no_noise_base.svg',width = blog_width, height = blog_height * 2, units = 'px', dpi =blog_dpi)
