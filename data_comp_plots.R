
directory = 'D:\\Data\\speech\\benchmark_datasets\\buckeye\\data_comp_accuracy_data'

benchmark_file = 'D:\\Data\\speech\\benchmark_datasets\\buckeye\\smalls\\benchmark.csv'

data_comp_benchmark = read_csv(benchmark_file)


data_comp_benchmark$num_speakers <- as.numeric(str_extract(data_comp_benchmark$Name, '^(\\d+)'))
data_comp_benchmark$index <- as.numeric(str_extract(data_comp_benchmark$Name, '(\\d+)$'))

data_comp_benchmark$num_speakers <- as.numeric(data_comp_benchmark$num_speakers)

data_comp_benchmark$`Final log-likelihood` <- as.numeric(data_comp_benchmark$`Final log-likelihood`)

data_comp_benchmark$`Type of benchmark` <- factor(data_comp_benchmark$`Type of benchmark`)
data_comp_benchmark$Name <- factor(data_comp_benchmark$Name)

summary(data_comp_benchmark)

train_benchmark <- subset(data_comp_benchmark, `Type of benchmark` == 'train')
align_benchmark <- subset(data_comp_benchmark, `Type of benchmark` == 'align')

subset_data_file = 'D:\\Data\\speech\\benchmark_datasets\\buckeye\\smalls\\subset_info.csv'
data_comp_subset_data <- read_csv(subset_data_file)

data_comp_subset_data$num_speakers <- as.numeric(str_extract(data_comp_subset_data$name, '^(\\d+)'))
data_comp_subset_data$index <- as.numeric(str_extract(data_comp_subset_data$name, '(\\d+)$'))

data_comp_subset_data$name <- factor(data_comp_subset_data$name)
data_comp_subset_data$index <- factor(data_comp_subset_data$index)
summary(data_comp_subset_data)
data_comp_subset_data$type <- 'subset'

inverse_subset_data_file = 'D:\\Data\\speech\\benchmark_datasets\\buckeye\\smalls\\inverse_subset_info.csv'
inverse_subset_data <- read_csv(inverse_subset_data_file)


inverse_subset_data$num_speakers <- as.numeric(str_extract(inverse_subset_data$name, '^(\\d+)'))
inverse_subset_data$index <- as.numeric(str_extract(inverse_subset_data$name, '(\\d+)$'))

inverse_subset_data$name <- factor(inverse_subset_data$name)
summary(inverse_subset_data)
inverse_subset_data$type <- 'inverse'

data_comp_subset_data <- rbind(data_comp_subset_data, inverse_subset_data)
data_comp_subset_data$type <- factor(data_comp_subset_data$type)

csv_files = list.files(path=directory, pattern="*utterance_metrics.txt", full.names=TRUE)

data_comp_utterance_metrics = csv_files %>% map_dfr(read_csv)

data_comp_utterance_metrics$num_speakers <- as.numeric(str_extract(data_comp_utterance_metrics$aligner, '^(\\d+)'))
data_comp_utterance_metrics$index <- as.numeric(str_extract(data_comp_utterance_metrics$aligner, '(\\d+)$'))

data_comp_utterance_metrics$phone_boundary_error <- data_comp_utterance_metrics$overlap_error /2

data_comp_utterance_metrics$corrected_num_insertions <- data_comp_utterance_metrics$num_insertions

remove_utterances = c('s4003b_205.2415_223.195437')

data_comp_utterance_metrics <- subset(data_comp_utterance_metrics, !utterance %in% remove_utterances)


csv_files = list.files(path=directory, pattern="*word_distance.txt", full.names=TRUE)

data_comp_word_distances = csv_files %>% map_dfr(read_csv)


data_comp_word_distances$num_speakers <- as.numeric(str_extract(data_comp_word_distances$aligner, '^(\\d+)'))
data_comp_word_distances$index <- as.numeric(str_extract(data_comp_word_distances$aligner, '(\\d+)$'))


data_comp_word_distances <- subset(data_comp_word_distances, !(discourse == 's4003b' & reference_time > 205 & reference_time < 223.2))
data_comp_word_distances <- subset(data_comp_word_distances, !(discourse == 's2401a' & reference_time > 36.49 & reference_time < 51.2))
data_comp_word_distances <- subset(data_comp_word_distances, !(discourse == 's3301a' & reference_time > 28.2 & reference_time < 44.1))
data_comp_word_distances <- subset(data_comp_word_distances, !(discourse == 's2903b' & reference_time > 518))

data_comp_word_distances$distance <- abs(data_comp_word_distances$distance)


csv_files = list.files(path=directory, pattern="*phone_distance.txt", full.names=TRUE)

data_comp_phone_distances = csv_files %>% map_dfr(read_csv)

data_comp_phone_distances$distance <- abs(data_comp_phone_distances$distance)


data_comp_phone_distances$num_speakers <- as.numeric(str_extract(data_comp_phone_distances$aligner, '^(\\d+)'))
data_comp_phone_distances$index <- as.numeric(str_extract(data_comp_phone_distances$aligner, '(\\d+)$'))

data_comp_phone_distances$type <- factor(data_comp_phone_distances$type, levels=c('initialc', 'cv', 'vc', 'finalc'), labels=c('Initial C', 'CV transition', 'VC transition', 'Final C'))


## LOAD BASELINE DATA


baseline_directory = 'D:\\Data\\speech\\benchmark_datasets\\buckeye\\accuracy_data'

csv_files = list.files(path=baseline_directory, pattern="mfa_ipa_train_utterance_metrics.txt", full.names=TRUE)

utterance_metrics = csv_files %>% map_dfr(read_csv)

utterance_metrics$phone_boundary_error <- utterance_metrics$overlap_error /2

remove_utterances = c('s4003b_205.2415_223.195437')

utterance_metrics <- subset(utterance_metrics, !utterance %in% remove_utterances)

csv_files = list.files(path=baseline_directory, pattern="mfa_ipa_train_word_distance.txt", full.names=TRUE)

word_distances = csv_files %>% map_dfr(read_csv)

word_distances <- subset(word_distances, !(discourse == 's4003b' & reference_time > 205 & reference_time < 223.2))
word_distances <- subset(word_distances, !(discourse == 's2401a' & reference_time > 36.49 & reference_time < 51.2))
word_distances <- subset(word_distances, !(discourse == 's3301a' & reference_time > 28.2 & reference_time < 44.1))
word_distances <- subset(word_distances, !(discourse == 's2903b' & reference_time > 518))



word_distances$distance <- abs(word_distances$distance)


csv_files = list.files(path=baseline_directory, pattern="mfa_ipa_train_phone_distance.txt", full.names=TRUE)

phone_distances = csv_files %>% map_dfr(read_csv)

phone_distances$distance <- abs(phone_distances$distance)


phone_distances$type <- factor(phone_distances$type, levels=c('initialc', 'cv', 'vc', 'finalc'), labels=c('Initial C', 'CV transition', 'VC transition', 'Final C'))




# PLOTS

plotData <- summarySE(data=data_comp_utterance_metrics, measurevar = 'phone_boundary_error', groupvars=c('num_speakers'))
baselinePlotData <- summarySE(data=utterance_metrics, measurevar = 'phone_boundary_error', groupvars=c('aligner'))

ggplot(aes(x=num_speakers, y=mean * 1000), data=plotData) +
  geom_rect(ymin=(baselinePlotData$mean - baselinePlotData$ci) * 1000, ymax = (baselinePlotData$mean + baselinePlotData$ci)* 1000, xmin=-Inf, xmax=Inf,  alpha =0.01, fill="#FB5607", size=1.5) + 
  geom_point(size = 5, colour = "#FB5607") + 
  geom_errorbar(aes(ymin = (mean - ci) * 1000, ymax = (mean + ci)* 1000),size=2, width=0.5, colour = "#FB5607") + 
  ylab('Phone boundary error (ms)') + xlab('Number of training speakers') +ggtitle('Phone boundary errors on training data') +
  theme_memcauliffe() + scale_color_manual(name = 'Run index', values = cbbPalette) + scale_y_continuous(limits = c(18.75, 21.5)) + scale_x_continuous(limits = c(1, 39))
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\data_comp_average_phone_boundary_error.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)


plotData <- summarySE(data=data_comp_word_distances, measurevar = 'distance', groupvars=c('num_speakers', 'pause_boundary'))
baselinePlotData <- summarySE(data=word_distances, measurevar = 'distance', groupvars=c('aligner', 'pause_boundary'))
baselinePlotData$num_speakers <- 1

ggplot(aes(x=num_speakers, y=mean * 1000, color = pause_boundary, shape = pause_boundary, group=pause_boundary), data=plotData)+
  geom_rect(aes(ymin=(mean - ci) * 1000, ymax = (mean + ci)* 1000, fill=pause_boundary), xmin=-Inf, xmax=Inf,  alpha =0.5, size=1,data=baselinePlotData, color=NA, show.legend = F) + 
  geom_point(size = 5) + geom_errorbar(aes(ymin = (mean - ci) * 1000, ymax = (mean + ci)* 1000),size=1.5, width=0.5) + 
  ylab('Distance to annotated time point (ms)') + scale_color_manual(name = 'Boundary with silence', values = cbbPalette) + scale_fill_manual(name = 'Boundary with silence', values = cbbPalette) + ggtitle("Word boundary errors on training data") +
  scale_shape_discrete(name = 'Boundary with silence') + xlab('Number of training speakers') +theme_memcauliffe()
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\data_comp_word_boundaries.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)

plotData <- summarySE(data=data_comp_phone_distances, measurevar = 'distance', groupvars=c('num_speakers','type'))
baselinePlotData <- summarySE(data=phone_distances, measurevar = 'distance', groupvars=c('aligner', 'type'))
baselinePlotData$num_speakers <- 1

ggplot(aes(x=num_speakers, y=mean * 1000, color = type, shape=type), data=plotData)+
  geom_rect(aes(ymin=(mean - ci) * 1000, ymax = (mean + ci)* 1000, fill=type), xmin=-Inf, xmax=Inf,  alpha =0.5, size=1,data=baselinePlotData, color=NA, show.legend = F) + 
  geom_point(size = 5) + 
  geom_errorbar(aes(ymin = (mean - ci) * 1000, ymax = (mean + ci)* 1000),size=2, width=0.5) + 
  ylab('Distance to annotated time point (ms)') + 
  scale_color_manual(name = 'Timepoint', values = cbbPalette) + 
  scale_fill_manual(name = 'Timepoint', values = cbbPalette) + 
  scale_shape_manual(name = 'Timepoint', values = c(15, 16, 17, 18)) + xlab('Number of training speakers') +
  theme_memcauliffe() + ggtitle('Phone boundary errors in selected CVC words in training data')
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\data_comp_cvc_phone_boundaries.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)


plotData <- summarySE(data=train_benchmark, measurevar = '`Final log-likelihood`', groupvars=c('num_speakers'))

ggplot(aes(x=num_speakers, y=mean), data=plotData) +geom_point(size = 5, colour = "#FB5607") + 
  geom_errorbar(aes(ymin = (mean - ci), ymax = (mean + ci)),size=2, width=0.5, colour = "#FB5607") + 
  ylab('Align log-likelihood')+ xlab('Number of training speakers') + theme_memcauliffe() + 
  ggtitle("Final alignment log-likelihood")
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\data_comp_log_like.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)


plotData <- summarySE(data=subset(train_benchmark, `Total time` < 4000), measurevar = '`Total time`', groupvars=c('num_speakers'))
ggplot(aes(x=num_speakers, y=(mean /60)/60), data=plotData) + geom_point(size = 5, colour = "#FB5607") + 
  geom_errorbar(aes(ymin = (((mean - ci) /60)/60), ymax = (((mean + ci) /60)/60)),size=2, width=0.5, colour = "#FB5607") + 
  ylab('Time (hours)')+ xlab('Number of training speakers') + theme_bw() + ggtitle("Time to generate alignment") + 
  scale_y_continuous(limits=c(0, 1.6)) + theme_memcauliffe()
ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\data_comp_timing.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)



ggplot(aes(x=num_speakers, y=(duration /60)/60, color=type), data=subset_data) +geom_point(size = 3) + 
  ylab('Duration (hours)')+ xlab('Number of training speakers') + theme_memcauliffe() + 
  scale_color_manual(name = 'Subset', values = cbbPalette, labels =c('Held out data', 'Training data')) + 
  ggtitle("Duration of subsets")

ggsave('C:\\Users\\michael\\Documents\\Dev\\Web\\memcauliffe.com\\memcauliffe-pelican\\content\\images\\data_comp_duration.svg',width = blog_width, height = blog_height, units = 'px', dpi =blog_dpi)
