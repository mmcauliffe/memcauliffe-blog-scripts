library(ggplot2)
library(lme4)
library(stringr)
library(dplyr)
library(tidyr)
library(xtable)

loadData <- TRUE

if(loadData){
  rm(list=ls())
  source("dataprep.r")
  save.image("interspeechData.RData")
}

wdSumm <- summarySE(data=word_distances, measurevar = 'distance', groupvars=c('aligner'))
pdSumm <- summarySE(data=phone_distances, measurevar = 'distance', groupvars=c('aligner'))
pdPhonsaySumm <- summarySE(data=phonsay, measurevar = 'diff_mag', groupvars=c('condition'))

distHist1 <- ggplot(aes(x=distance), data=filter(word_distances, aligner=='mfa_librispeech')) + geom_histogram() + geom_vline(aes(xintercept=0.005),lty=2) + scale_x_log10(breaks=c(0.001,0.01,0.1,1)) + xlab("Absolute manual/aligned distance (sec)") + ggtitle("Word boundaries (Buckeye)") + annotation_logticks(sides = 'b')

distHist2 <- ggplot(aes(x=distance), data=filter(phone_distances, aligner=='mfa_librispeech')) + geom_histogram() + geom_vline(aes(xintercept=0.005),lty=2) + scale_x_log10(breaks=c(0.001,0.01,0.1,1)) + xlab("Absolute manual/aligned distance (sec)") + ggtitle("Phone boundaries (Buckeye)") + annotation_logticks(sides = 'b')

phonsayMfaLs <- phonsay[phonsay$condition=='MFA-\nLS',]
distHist3 <- ggplot(aes(x=diff_mag), data=phonsayMfaLs) + geom_histogram() + geom_vline(aes(xintercept=0.005),lty=2) + scale_x_log10(breaks=c(0.001,0.01,0.1,1)) + xlab("Absolute manual/aligned distance (sec)") + ggtitle("Phone boundaries (Phonsay)") + annotation_logticks(sides = 'b')


ggsave(distHist1, file="wordBoundaryHist.pdf", width=3.5,height=3.5)
ggsave(distHist2, file="phoneBoundaryBuckHist.pdf", width=3.5,height=3.5)
ggsave(distHist3, file="phoneBoundaryPhonsayHist.pdf", width=3.5,height=3.5)



## Table 1 rows
cdfWordDist <- ecdf(word_distances$distance)
cdfPhoneDist <- ecdf(phone_distances$distance)
cdfPhoneDistPhonsay <- ecdf(phonsay$diff_mag)

round(as.numeric(lapply(c(0.01, 0.025, 0.05, 0.1), cdfWordDist)),2)
round(as.numeric(lapply(c(0.01, 0.025, 0.05, 0.1), cdfPhoneDist)),2)
round(as.numeric(lapply(c(0.01, 0.025, 0.05, 0.1), cdfPhoneDistPhonsay)),2)

###
### numbers for Tab 2
### 

tempDf1 <- filter(wdSumm, !aligner=='mfa_librispeech_nsa') %>% select(one_of('aligner','median','mean'))
tempDf1 <- gather(tempDf1, "measure", "val", 2:3)
tempDf1$boundary <- 'word'

tempDf2 <- filter(pdSumm, !aligner=='mfa_librispeech_nsa') %>% select(one_of('aligner','median', 'mean'))
tempDf2 <- gather(tempDf2, "measure", "val", 2:3)
tempDf2$boundary <- 'phone_buck'

tempDf3 <- filter(pdPhonsaySumm,  condition%in%c('MFA-\nLS','MFA-\nFlat','PLA-\nLS-Clean','PLA-\nFlat','FAVE-\nSCOTUS'))  %>% select(one_of('condition','median','mean'))
tempDf3 <- tempDf3 %>% mutate(aligner=factor(condition, labels = c('fave','mfa_librispeech','mfa_flat','pla-ls','pla-flat')), condition=NULL)
tempDf3 <- gather(tempDf3, "measure", "val", 1:2)
tempDf3$boundary <- 'phone_phonsay'

tempDf4 <- rbind(tempDf1, tempDf2) %>% mutate(val=round(1000*val,1))
tempDf4$type <- with(tempDf4, paste0(boundary, '_',measure))
tempDf4 <- droplevels(tempDf4)
tempDf4 <- tempDf4 %>% select(one_of('aligner','val','type')) %>% spread(type,val)
tempDf4 <- tempDf4[c(3,2,5,4,1),c(1,6,7,2,3,4,5)]
tempDf4.tab <- xtable(tempDf4, digits=1)
print(tempDf4.tab, include.rownames=FALSE, include.colnames=FALSE, only.contents=TRUE)




## significance testing

word_distances$id <- factor(paste0(word_distances$discourse, word_distances$word, word_distances$reference_time))

k <- word_distances %>% select(one_of('aligner','id','distance'))
#k <- select(word_distances, one_of('aligner','id','distance'))

t <- spread(k, aligner, distance)

wilcox.test(t$mfa_flat,t$mfa_librispeech_nsa, alternative='less', paired=T)
wilcox.test(t$mfa_flat,t$mfa_librispeech, alternative='less', paired=T)
wilcox.test(t$mfa_flat,t$fave,alternative='less',  paired=T)
wilcox.test(t$mfa_flat,t[['pla-flat']], alternative='less', paired=T)
wilcox.test(t$mfa_flat,t[['pla-ls']], alternative='less', paired=T)



phone_distances$id <- factor(paste0(phone_distances$discourse, phone_distances$word, word_distances$type, phone_distances$reference_time))
k <- phone_distances %>% select(one_of('aligner','id','distance'))
#k <- select(word_distances, one_of('aligner','id','distance'))

## get rid of duplicate ids, like when end of one word is start of next
k1 <- k %>% group_by(aligner) %>% filter(!duplicated(id)) %>% ungroup()


t <- spread(k1, aligner, distance)


wilcox.test(t$mfa_librispeech,t$mfa_librispeech_nsa, alternative='less', paired=T)
wilcox.test(t$mfa_librispeech,t$mfa_flat, alternative='less', paired=T)
wilcox.test(t$mfa_librispeech,t$fave, alternative='less', paired=T)
wilcox.test(t$mfa_librispeech,t[['pla-flat']],alternative='less',  paired=T)
wilcox.test(t$mfa_librispeech,t[['pla-ls']],alternative='less',  paired=T)

## TODO: wilcox tests for phonsay phone boundaries






## check what difference SA makes:

tempDf2 <- filter(pdSumm, aligner%in%c('fave','mfa_librispeech','mfa_librispeech_nsa','pla-ls')) %>% select(one_of('aligner','mean'))
spread(tempDf2, aligner, mean)
# what improvement from monophone->triphone?
temp2 <- spread(tempDf2, aligner, mean)
(temp2[['pla-ls']] - temp2$mfa_librispeech_nsa)/(temp2[['pla-ls']] - temp2$mfa_librispeech)

tempDf2 <- filter(pdSumm, aligner%in%c('fave','mfa_flat', 'mfa_librispeech','mfa_librispeech_nsa','pla-ls')) %>% select(one_of('aligner','median'))
# what improvement from monophone->triphone?
temp2 <- spread(tempDf2, aligner, median)
(temp2[['pla-ls']] - temp2$mfa_librispeech_nsa)/(temp2[['pla-ls']] - temp2$mfa_librispeech)


tempDf1 <- filter(wdSumm, aligner%in%c('fave','mfa_librispeech','mfa_librispeech_nsa','pla-ls')) %>% select(one_of('aligner','mean'))
#spread(tempDf1, aligner, distance)
# what improvement from monophone->triphone?
temp1 <- spread(tempDf1, aligner, mean)
(temp1[['pla-ls']] - temp1$mfa_librispeech_nsa)/(temp1[['pla-ls']] - temp1$mfa_librispeech)

tempDf1 <- filter(wdSumm, aligner%in%c('fave','mfa_librispeech','mfa_librispeech_nsa','pla-ls')) %>% select(one_of('aligner','median'))
#spread(tempDf1, aligner, distance)
# what improvement from monophone->triphone?
temp1 <- spread(tempDf1, aligner, median)
(temp1[['pla-ls']] - temp1$mfa_librispeech_nsa)/(temp1[['pla-ls']] - temp1$mfa_librispeech)





####
#### OLD STUFF
####


# 
# ## first part
# tempDf1 <- filter(wdSumm, aligner%in%c('fave','mfa_librispeech','pla-ls')) %>% select(one_of('aligner','type','distance'))
# tempDf1$aligner <- factor(tempDf1$aligner, levels=c('mfa_librispeech','pla-ls', 'fave'))
# tempDf1$distance <- round(1000*tempDf1$distance,1)
# 
# spread(tempDf1, aligner, distance)
# 
# 
# ## second part
# tempDf2 <- filter(pdSumm, aligner%in%c('fave','mfa_librispeech','pla-ls')) %>% select(one_of('aligner','type','distance'))
# tempDf2$aligner <- factor(tempDf2$aligner, levels=c('mfa_librispeech','pla-ls', 'fave'))
# tempDf2$distance <- round(1000*tempDf2$distance,1)
# 
# spread(tempDf2, aligner,distance)
# 
# ## third part
# tempDf3 <- filter(pdPhonsaySumm,  condition%in%c('MFA-\nLS','PLA-\nLS-Clean','FAVE-\nSCOTUS'))  %>% select(one_of('condition','type','diff_mag'))
# tempDf3$condition <- factor(tempDf3$condition, levels=c('MFA-\nLS','PLA-\nLS-Clean','FAVE-\nSCOTUS'))
# tempDf3$diff_mag <- round(1000*tempDf3$diff_mag,1)
# spread(tempDf3, condition,diff_mag)
# 


# 
# ###
# ### numbers for Tab 3
# 
# ### first part
# aligners <- c('mfa_flat', 'mfa_librispeech','pla-flat', 'pla-ls')
# tempDf1 <- filter(wdSumm, aligner%in%aligners) %>% select(one_of('aligner','type','distance'))
# tempDf1$aligner <- factor(tempDf1$aligner, levels=aligners)
# tempDf1$distance <- round(1000*tempDf1$distance,1)
# 
# spread(tempDf1, aligner, distance)
# 
# ## second part
# aligners <- c('mfa_flat', 'mfa_librispeech','pla-flat', 'pla-ls')
# tempDf2 <- filter(pdSumm, aligner%in%aligners) %>% select(one_of('aligner','type','distance'))
# tempDf2$aligner <- factor(tempDf2$aligner, levels=aligners)
# tempDf2$distance <- round(1000*tempDf2$distance,1)
# 
# spread(tempDf2, aligner, distance)
# 

# 
# 
# ##
# ## checking on results for mean->median, for each part above:
# ##
# 
# ## tab 1:
# # > spread(tempDf1, aligner, median)
# # # A tibble: 2 × 4
# # type mfa_librispeech `pla-ls`    fave
# # * <fctr>           <dbl>    <dbl>   <dbl>
# #   1  begin         0.01489    0.015 0.01492
# # 2    end         0.01375    0.015 0.01486
# 
# #> spread(tempDf2, aligner,median)
# # # A tibble: 4 × 4
# # type mfa_librispeech `pla-ls`    fave
# # *   <fctr>           <dbl>    <dbl>   <dbl>
# #   1 initialc        0.012375  0.01500 0.01300
# # 2       cv        0.011320  0.01141 0.01110
# # 3       vc        0.008570  0.01500 0.01049
# # 4   finalc        0.013760  0.01487 0.01386
# ## (so yes a difference, but barely)
# 
# 
# # > spread(tempDf3, condition,median)
# # # A tibble: 3 × 4
# # type `FAVE-\nSCOTUS` `MFA-\nLS` `PLA-\nLS-Clean`
# # *              <fctr>           <dbl>      <dbl>            <dbl>
# #   1   Vowel begin point        0.011165   0.010770         0.015245
# # 2     Vowel end point        0.011120   0.007765         0.014435
# # 3 Obstruent end point        0.019445   0.014775         0.020860
# 
# 
# 
# 
# 
# ## tab 3:
# aligners <- c('mfa_flat', 'mfa_librispeech','pla-flat', 'pla-ls')
# tempDf1 <- filter(wdSumm, aligner%in%aligners) %>% select(one_of('aligner','type','median'))
# tempDf1$aligner <- factor(tempDf1$aligner, levels=aligners)
# spread(tempDf1, aligner, median)
# # # A tibble: 2 × 5
# # type mfa_flat mfa_librispeech `pla-flat` `pla-ls`
# # * <fctr>    <dbl>           <dbl>      <dbl>    <dbl>
# #   1  begin  0.01500         0.01489    0.01500    0.015
# # 2    end  0.01368         0.01375    0.01601    0.015
# 
# ## second part
# aligners <- c('mfa_flat', 'mfa_librispeech','pla-flat', 'pla-ls')
# tempDf2 <- filter(pdSumm, aligner%in%aligners) %>% select(one_of('aligner','type','median'))
# spread(tempDf2, aligner, median)
# 

