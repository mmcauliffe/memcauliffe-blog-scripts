library(tidyr)
library(dplyr)
root_dir = "D:/Data/models/globalphone"

evals = list.dirs(root_dir, recursive = F, full.names = F)

data = data.frame()

for (e in evals){
  print(e)
  path = file.path(root_dir, e, "transcription_evaluation.csv")
  print(path)
  d = read.csv(path)
  d$language = e
  d$speaker <- as.character(d$speaker)
  data = bind_rows(data,d)
} 

summary(data)


data %>% group_by(language,speaker) %>% summarise(num_utterances=n()) %>% group_by(language) %>% summarise(mean_utterances=mean(num_utterances))

data %>% group_by(language,speaker) %>% summarise(mean_wer=mean(WER)) %>% arrange(desc(mean_wer)) %>% group_by(language) %>% summarise(mean_wer=mean(mean_wer), num_speakers=n())

data %>% mutate(word_errors=WER*word_count) %>% group_by(language) %>% summarise(WER= sum(word_errors)/ sum(word_count), average_cer=mean(CER))

data %>% group_by(language) %>% summarise(oov_count= sum(oov_count), mean(duration))


plotData <- summarySE(data=data, measurevar = 'WER', groupvars=c('language'))

ggplot(aes(x=language, y=mean * 100), data=plotData) + geom_point(size = 5, color='#FB5607') + 
  geom_errorbar(aes(ymin = (mean - ci) * 100, ymax = (mean + ci)* 100),size=2, width=0.5, color='#FB5607') + 
  ylab('Word error rate (%)') + xlab('language') +ggtitle('Word error rates across languages') +
  theme_memcauliffe() + scale_y_continuous(limits=c(0,120))+
  scale_x_discrete(guide = guide_axis(n.dodge = 2))


plotData <- summarySE(data=na.exclude(data), measurevar = 'CER', groupvars=c('language'))

ggplot(aes(x=language, y=mean * 100), data=plotData) + geom_point(size = 5, color='#FB5607') + 
  geom_errorbar(aes(ymin = (mean - ci) * 100, ymax = (mean + ci)* 100),size=2, width=0.5, color='#FB5607') + 
  ylab('Character error rate (%)') + xlab('language') +ggtitle('Character error rates across languages') +
  theme_memcauliffe() + scale_y_continuous(limits=c(0,120))+
  scale_x_discrete(guide = guide_axis(n.dodge = 2))

vietnamese <- subset(data, language=='vietnamese')
head(vietnamese)

data %>% subset(language=='ukrainian') %>% group_by(speaker) %>% summarise(mean_wer=mean(WER)) %>% arrange(desc(mean_wer))


korean <- subset(data, language=='korean')
head(korean)
