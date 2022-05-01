
loading_width_resolution = 720

loading_width_resolution *0.5
loading_width_resolution * 0.75


radians_per_pixel = (4*pi) / 720

arrow_gap = 180-108

anchor_aspect_ratio = 520 / 580

anchor_pixel_width_original = 504

gap = loading_width_resolution-anchor_pixel_width_original

anchor_min_pixel = gap / 2
anchor_max_pixel = loading_width_resolution - (gap/2)

anchor_y_max_pixel = 135

arrow_pixel_gap = arrow_gap * anchor_pixel_width_original / 580


anchor_pixel_width = anchor_pixel_width_original


anchor <- image_read('anchor-yellow.png' )


anchor_height <- image_info(anchor)$height
origin_offset = 99 # Hoop center
#origin_offset = 244 #Cross bar
bottom = 512

origin_ratio = origin_offset / bottom

offset_ratio = ((bottom/2) - origin_offset) / bottom

aspect_ratio = bottom / x_max

main_width = 2*pi
width_ratio = main_width/ anchor_pixel_width_original

arrow_gap_radians = arrow_pixel_gap * width_ratio

xmin= anchor_min_pixel * radians_per_pixel
xmax= anchor_max_pixel * radians_per_pixel


real_x_width = xmax - xmin



real_y_height = real_x_width * anchor_aspect_ratio

plot_height = 12

real_y_offset = anchor_y_max_pixel * (plot_height / 576)

real_y_height = 520* (plot_height / 576)

real_y_origin = 6

y_origin_offset = origin_ratio * real_y_height

wave_baseline = real_y_origin #+ (offset_ratio * real_y_height)

ymax =  plot_height - real_y_offset #+ y_origin_offset
ymin = 0

xs <- seq(-2*pi,2*pi,pi/100)
wave.1 <- sin(3*xs)
wave.2 <- sin(10*xs)

sine_data = data.frame(time= seq(0,4*pi,length.out=400))
sine_data$y0 <- sin(0.5*sine_data$time)
sine_data$y1 <- sin(1*sine_data$time)
sine_data$y2 <- sin((2)*sine_data$time)
sine_data$y3 <- sin((4)*sine_data$time)
sine_data$y4 <- sin((8)*sine_data$time)
sine_data$y5 <- sin((16)*sine_data$time)
sine_data$damping <- ftwindow(length(sine_data$time), wn='blackman')
#sine_data$damping <- tukeywin(length(sine_data$time), r=0.55)

ggplot(aes(x=time, y=y0), data=sine_data) + geom_line() + geom_line(aes(y=y1), color='red') + geom_line(aes(y=y2), color='blue') + geom_line(aes(y=y3), color='green')

sine_data$cool_wave <- (0.5 *sine_data$y1 + 0.25*sine_data$y2 + 0.125*sine_data$y3 + 0.0625*sine_data$y4 + 0.0625*sine_data$y5) #* sine_data$damping

#sine_data[sine_data$time > pi,]$cool_wave = sine_data[sine_data$time > pi,]$cool_wave * -1

ggplot(aes(x=time, y=cool_wave), data=sine_data) + geom_line() + geom_line(aes(y=damping), color='red')

num_frames = 480


time_rate = 8

time_damping <- c(-1*ftwindow(num_frames/2, wn='bartlett'), ftwindow(num_frames/2, wn='bartlett')) /2

time_damping <- sin(((1:num_frames) - 1) * pi/(2*num_frames/time_rate) + pi) /2


time_damping <- c(-1*welchwin(num_frames/2), welchwin(num_frames/2))


df = data.frame(step=1:num_frames, time_damping = time_damping)


ggplot(aes(x=step, y=time_damping), data=df) + geom_line()
anidata <- sine_data %>% expand_grid(step=1:num_frames) %>% left_join(df)

rate = 8

anidata$time_step <- (anidata$step - 1) * pi/(2*num_frames/rate)

#anidata$time_damping <- sin((anidata$step - 1) * pi/(2*num_frames/time_rate) + pi) /2

ggplot(aes(x=step, y=time_damping), data=anidata) + geom_line()

anidata$moving_time = anidata$time - anidata$time_step
anidata$y1 <- sin(1*(anidata$moving_time))
anidata$y2 <- sin((2)*(anidata$moving_time))
anidata$y3 <- sin((4)*(anidata$moving_time))
anidata$y4 <- sin((8)*(anidata$moving_time))
anidata$y5 <- sin((16)*(anidata$moving_time))

anidata$pi_remainder = anidata$moving_time /(4*pi)


anidata$cool_wave2 <- (0.5 *anidata$y1 + 0.25*anidata$y2 + 0.125*anidata$y3  + 0.0625*anidata$y4 + 0.0625*anidata$y5)
#anidata$cool_wave2 = anidata$cool_wave2 * anidata$phase

anidata$modded <- ((anidata$cool_wave2 *anidata$time_damping) *5) + wave_baseline+ 2

ggplot(aes(x=pi_remainder, y=cool_wave2, group=time_step), data=subset(anidata, step %in% c(10, 60))) + geom_line() + facet_wrap(~step)
ggplot(aes(x=pi_remainder, y=modded, group=time_step), data=subset(anidata, step %in% c(10, 60))) + geom_line() + facet_wrap(~step)
#ggplot(aes(x=time, y=modded, group=time_step), data=subset(anidata, step <200)) + geom_line() + facet_wrap(~step)


anidata$cool_wave_plot <- (anidata$cool_wave2 * 5) + wave_baseline + 2


ggplot(aes(x=time /pi, y=cool_wave_plot), data=subset(anidata, step == 340/2)) + geom_line()

ggplot(aes(x=time, y=cool_wave2), data=subset(anidata, step == 70)) + geom_line()


## DEBUG PLOT
ggplot(aes(x=time, y=cool_wave_plot), data=subset(anidata, step == 172)) + 
  scale_y_continuous(limits=c(0,plot_height), expand=c(0,0)) + scale_x_continuous(limits=c(0,4*pi),expand = c(0,0)) + 
  geom_ribbon(aes(ymin=0, ymax=cool_wave_plot), fill=base_blue) + geom_ribbon(aes(ymin=cool_wave_plot, ymax=plot_height), fill=sky_blue)+ 
  theme_memcauliffe() + geom_vline(xintercept=2*pi, color='red') + geom_vline(xintercept=pi, color='yellow') + geom_vline(xintercept=3*pi, color='yellow') + geom_hline(yintercept=wave_baseline, color='red')+
  annotation_raster(anchor, ymin = ymin, ymax = ymax, xmin = xmin, xmax = 
                      xmax) +
  labs(x=NULL, y=NULL) + 
  theme(panel.grid.minor = element_blank(), panel.grid.major = element_blank(), panel.grid = element_blank(), 
        axis.title.x = element_blank(), axis.title.y = element_blank(), 
        axis.text.x = element_blank(), axis.text.y = element_blank(), 
        axis.line.x = element_blank(), axis.line.y = element_blank(),
        axis.ticks.x = element_blank(), axis.ticks.y = element_blank(),
        panel.border = element_blank(), panel.spacing = unit(0, "cm"),
        plot.margin=grid::unit(c(0,0,0,0), "mm"),
        panel.background = element_rect(fill = "transparent"),
        axis.ticks.length = unit(0, "pt"),
        
        plot.background = element_rect(fill = "transparent"))


ggplot(aes(x=time, y=cool_wave_plot), data=subset(anidata, step == 172)) + 
  scale_y_continuous(limits=c(0,plot_height), expand=c(0,0)) + scale_x_continuous(limits=c(0,4*pi),expand = c(0,0)) + 
  geom_ribbon(aes(ymin=0, ymax=cool_wave_plot), fill=base_blue) + geom_ribbon(aes(ymin=cool_wave_plot, ymax=plot_height), fill=sky_blue)+ 
  theme_memcauliffe() + 
  labs(x=NULL, y=NULL) + 
  theme(panel.grid.minor = element_blank(), panel.grid.major = element_blank(), panel.grid = element_blank(), 
        axis.title.x = element_blank(), axis.title.y = element_blank(), 
        axis.text.x = element_blank(), axis.text.y = element_blank(), 
        axis.line.x = element_blank(), axis.line.y = element_blank(),
        axis.ticks.x = element_blank(), axis.ticks.y = element_blank(),
        panel.border = element_blank(), panel.spacing = unit(0, "cm"),
        plot.margin=grid::unit(c(0,0,0,0), "mm"),
        panel.background = element_rect(fill = "transparent"),
        axis.ticks.length = unit(0, "pt"),
        
        plot.background = element_rect(fill = "transparent"))
ggsave('splash_screen_background.svg', width=loading_width_resolution, height=576, units='px')
#ggsave('C:\\Users\\michael\\Documents\\Dev\\Montreal-Forced-Aligner\\montreal_forced_aligner\\anchor\\resources\\splash_screen_background.svg', width=loading_width_resolution, height=576, units='px')

p <- ggplot(aes(x=time, y=modded, group=time_step), data=anidata) + 
  scale_y_continuous(limits=c(0,plot_height), expand=c(0,0)) + scale_x_continuous(limits=c(0,4*pi),expand = c(0,0)) + 
  geom_ribbon(aes(ymin=0, ymax=modded), fill=base_blue) + geom_ribbon(aes(ymin=modded, ymax=plot_height), fill=sky_blue)+ 
  theme_memcauliffe() +
  annotation_raster(anchor, ymin = ymin, ymax = ymax, xmin = xmin, xmax = 
                      xmax)  + labs(x=NULL, y=NULL) + 
  theme(panel.grid.minor = element_blank(), panel.grid.major = element_blank(), panel.grid = element_blank(), 
        axis.title.x = element_blank(), axis.title.y = element_blank(), 
        axis.text.x = element_blank(), axis.text.y = element_blank(), 
        axis.line.x = element_blank(), axis.line.y = element_blank(),
        axis.ticks.x = element_blank(), axis.ticks.y = element_blank(),
        panel.border = element_blank(), panel.spacing = unit(0, "cm"),
        plot.margin=grid::unit(c(0,0,0,0), "mm"),
        panel.background = element_rect(fill = "transparent"),
        axis.ticks.length = unit(0, "pt"),
      
        plot.background = element_rect(fill = "transparent")) +transition_time(step) # + shadow_wake(wake_length = 0.1, alpha = FALSE)
a <- animate(p, width=loading_width_resolution + 1, height=576, fps=30, nframes=num_frames / 3)
anim_save('loading_screen.gif', animation = a)
anim_save('C:\\Users\\michael\\Documents\\Dev\\Montreal-Forced-Aligner\\montreal_forced_aligner\\anchor\\resources\\loading_screen.gif')


sine_data_for_logo = data.frame(time= seq(0,2*pi,length.out=400))
sine_data_for_logo$y <- sin(1*sine_data_for_logo$time)

ggplot(aes(x=time, y=y), data=sine_data_for_logo) + geom_line()

