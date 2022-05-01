library(tidyr)
library(dplyr)
root_dir = "D:/Data/models/evaluations"

evals = list.dirs(root_dir, recursive = F, full.names = F)

data = data.frame()

for (e in evals){
  print(e)
  path = file.path(root_dir, e, "alignment_evaluation.csv")
  print(path)
  d = read.csv(path)
  d$evaluation = e
  data = bind_rows(data,d)
} 

data$evaluation = factor(data$evaluation)
data$score <- as.numeric(data$score)

#data %>% group_by(utterance) %>% summarise(count=n()) %>% arrange(desc(count)) %>% subset(count < 10) -> misalignments
#bad_utts = misalignments$utterance
#data = subset(data, !utterance %in% bad_utts)
data = subset(data, word_count > 1)
data = subset(data, !(word_count == 2 & reference_phone_count == 2))

plotData <- summarySE(data=na.exclude(data), measurevar = 'score', groupvars=c('evaluation'))

ggplot(aes(x=evaluation, y=mean * 1000), data=plotData) + geom_point(size = 5, color='#FB5607') + 
  geom_errorbar(aes(ymin = (mean - ci) * 1000, ymax = (mean + ci)* 1000),size=2, width=0.5, color='#FB5607') + 
  ylab('Phone boundary error (ms)') + xlab('Alignment condition') +ggtitle('Phone boundary errors') +
  theme_memcauliffe() +
  scale_x_discrete(guide = guide_axis(n.dodge = 2))

plotData <- summarySE(data=data, measurevar = 'phone_error_rate', groupvars=c('evaluation'))

ggplot(aes(x=evaluation, y=mean * 100), data=plotData) + geom_point(size = 5, color='#FB5607') + 
  geom_errorbar(aes(ymin = (mean - ci) * 100, ymax = (mean + ci)* 100),size=2, width=0.5, color='#FB5607') + 
  ylab('Phone error rate %') + xlab('Alignment condition') +ggtitle('Phone error rate') +
  theme_memcauliffe() +
  scale_x_discrete(guide = guide_axis(n.dodge = 2))

#data %>% group_by(utterance) %>% summarise(count=n()) %>% arrange(desc(count)) %>% subset(count < 10) -> misalignments
#bad_utts = misalignments$utterance
#data = subset(data, !utterance %in% bad_utts)
nrow(data)
nrow(data[data$word_count == 1,])
nrow(subset(data, (word_count == 2 & reference_phone_count == 2)))
#data[data$phone_error_rate > 1,] %>% group_by(utterance) %>% summarise(count=n()) %>% arrange(desc(count)) %>% subset(count >= 8) -> misalignments
#data[data$phone_error_rate > 1,] %>% group_by(utterance) %>% summarise(count=n()) %>% arrange(desc(count)) %>% subset(count >= 8) -> misalignments

#bad_utts = misalignments$utterance
#data = subset(data, !utterance %in% bad_utts)

summary(data)
