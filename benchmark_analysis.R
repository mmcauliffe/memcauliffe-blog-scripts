library(tidyr)
library(dplyr)
library(stringr)
root_dir = "D:/Data/experiments/alignment_benchmarking/alignments"

evals = list.dirs(root_dir, recursive = F, full.names = F)

data = data.frame()

for (e in evals){
  print(e)
  
  corpora = list.dirs(file.path(root_dir, e), recursive = F, full.names = F)
  for (c in corpora){
    print(c)
    path = file.path(root_dir, e, c,  "alignment_evaluation.csv")
    print(path)
    d = read.csv(path)
    d$alignment_score <- as.numeric(d$alignment_score)
    d$utterance <- paste(d$file, str_replace_all(as.character(d$begin), '\\.', '-'), str_replace_all(as.character(d$end), '\\.', '-'), sep="-")
    #d$begin = NULL
    #d$end = NULL
    d$evaluation = e
    d$corpus = c
    data = bind_rows(data,d)
    
  }
} 

data$evaluation = factor(data$evaluation)
data$corpus = factor(data$corpus)
data$alignment_score <- as.numeric(data$alignment_score)

#data %>% group_by(utterance) %>% summarise(count=n()) %>% arrange(desc(count)) %>% subset(count < 10) -> misalignments
#bad_utts = misalignments$utterance
#data = subset(data, !utterance %in% bad_utts)
data <- subset(data,!is.na(alignment_score))
data = subset(data, word_count > 1)
data = subset(data, !(word_count == 2 & reference_phone_count == 2))

plotData <- summarySE(data=data, measurevar = 'alignment_score', groupvars=c('evaluation', 'corpus'))

ggplot(aes(x=evaluation, y=mean * 1000), data=plotData) + geom_point(size = 5, color='#FB5607') + 
  geom_errorbar(aes(ymin = (mean - ci) * 1000, ymax = (mean + ci)* 1000),size=2, width=0.5, color='#FB5607') + 
  ylab('Phone boundary error (ms)') + xlab('Alignment condition') +ggtitle('Phone boundary errors') +
  theme_memcauliffe() + facet_wrap(~corpus) +
  scale_x_discrete(guide = guide_axis(n.dodge = 2)) #+ facet_wrap(~utterance_length, ncol = 2)

plotData <- summarySE(data=data, measurevar = 'phone_error_rate', groupvars=c('evaluation', 'corpus'))

ggplot(aes(x=evaluation, y=mean * 100), data=plotData) + geom_point(size = 5, color='#FB5607') + 
  geom_errorbar(aes(ymin = (mean - ci) * 100, ymax = (mean + ci)* 100),size=2, width=0.5, color='#FB5607') + 
  ylab('Phone error rate %') + xlab('Alignment condition') +ggtitle('Phone error rate') +
  theme_memcauliffe() + facet_wrap(~corpus) +
  scale_x_discrete(guide = guide_axis(n.dodge = 2))

#data %>% group_by(utterance) %>% summarise(count=n()) %>% arrange(desc(count)) %>% subset(count < 10) -> misalignments
#bad_utts = misalignments$utterance
#data = subset(data, !utterance %in% bad_utts)
nrow(data)
nrow(data[data$word_count == 1,])
nrow(subset(data, (word_count == 2 & reference_phone_count == 2)))
#data[data$phone_error_rate > 1,] %>% group_by(utterance) %>% summarise(count=n()) %>% arrange(desc(count)) %>% subset(count <= 2) -> misalignments
#data[data$phone_error_rate > 1,] %>% group_by(utterance) %>% summarise(count=n()) %>% arrange(desc(count)) %>% subset(count >= 8) -> misalignments

#bad_utts = misalignments$utterance
#data = subset(data, !utterance %in% bad_utts)

test <- na.omit(data)
test <- subset(test, duration > 2)

data$utterance_length <- '>11'
data[data$word_count<=11,]$utterance_length  <- '<=11'
data[data$word_count<=6,]$utterance_length <- '<=6'
data[data$word_count<=3,]$utterance_length  <- '<=3'

data$utterance_length <- factor(data$utterance_length, levels =c('<=3', '<=6', '<=11','>11'))

arpa <- subset(data, evaluation=='english_us_arpa')
mfa <- subset(data, evaluation=='english_pitch_mfa')

missing_utts <- arpa[!arpa$utterance %in% mfa$utterance,]

summary(data)

ggplot(data, aes(x=word_count)) + geom_histogram()


timit <- subset(data, corpus=='timit')
timit[timit$alignment_score > 0.5 & timit$evaluation=='MFA2_ipa2',]
timit[timit$phone_error_rate > 2 & timit$evaluation=='mfa_101_alignments',]
