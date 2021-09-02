#BUCKEYE

word_distances <- read.csv('D:\\Data\\speech\\benchmark_datasets\\buckeye\\word_distance.txt')
nrow(subset(word_distances, discourse == 's4003b' & reference_time > 205 & reference_time < 223.2))
nrow(subset(word_distances, discourse == 's2401a' & reference_time > 36.49 & reference_time < 51.2))
nrow(subset(word_distances, discourse == 's3301a' & reference_time > 28.2 & reference_time < 44.1))
nrow(subset(word_distances, discourse == 's2903b' & reference_time > 518))

word_distances <- subset(word_distances, !(discourse == 's4003b' & reference_time > 205 & reference_time < 223.2))
word_distances <- subset(word_distances, !(discourse == 's2401a' & reference_time > 36.49 & reference_time < 51.2))
word_distances <- subset(word_distances, !(discourse == 's3301a' & reference_time > 28.2 & reference_time < 44.1))
word_distances <- subset(word_distances, !(discourse == 's2903b' & reference_time > 518))

word_distances$distance <- abs(word_distances$distance)

phone_distances <- read.csv('D:\\Data\\speech\\benchmark_datasets\\buckeye\\phone_distance.txt')

phone_distances$distance <- abs(phone_distances$distance)
