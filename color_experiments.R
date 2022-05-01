library(shiny)
library(shinyjs)

theme_color<- function () { 
  base_size = 12
  half_line <- base_size/2
  theme_bw(base_size=base_size, base_family="OpenSans") %+replace% 
    theme(
      plot.background = element_rect(fill = "#000000"),
      panel.background = element_rect(fill = "#000000", color = '#000000'),
      panel.border = element_rect(color='#000000', fill='NA'),
      axis.title = element_blank(),
      axis.text = element_blank(),
      axis.line = element_blank(),
      axis.ticks = element_blank(),
      axis.ticks.length = unit(0, "pt"),
      panel.grid.major = element_blank(), 
      panel.grid.minor = element_blank(),
      #axis.text = element_text(size = rel(1.2), colour = "#FFD60A"),
      #axis.text.y = element_text(margin = margin(r = 0.8*half_line/2),
      #                           hjust = 1, colour = "#FFD60A"),
      #axis.title = element_text(colour = "#FFC300", size = rel(1.6)),
      #plot.title = element_text(colour = "#FFC300", size = rel(1.8), hjust=0,
      #                          margin = margin(b = half_line * 1.2)),
      #strip.background = element_rect(fill = "#FFC300", colour = NA),
      #strip.text = element_text(colour = "#000000", size = rel(1.2),  margin = margin( b = 3, t = 3,  l = 4, r = 4)),
      #legend.background = element_blank(),
      #legend.key = element_blank(),
      #legend.title = element_text(size = rel(1.2), colour = "#FFC300"),
      #legend.text = element_text(size = rel(1), colour = "#FFC300"),
    )
}

plot_palette <- function(yellows, reds, blues, extras){
  
  rgb_yellow =hex2RGB(yellows)
  hsv_yellow = rgb2hsv(r=t(rgb_yellow@coords), maxColorValue = 1)
  brightness_yellows =  (0.299 * rgb_yellow@coords[,1]^2 + 0.587 * rgb_yellow@coords[,2]^2 + .114 * rgb_yellow@coords[,1]^2 )^(1/2)
  
  d.yellow <- as_tibble(data.frame(name=yellows, 
                                   h=hsv_yellow[1,], 
                                   s=hsv_yellow[2,], 
                                   v=hsv_yellow[3,],
                                   brightness = brightness_yellows,
                                   xmin=seq(0,length(yellows)-1), xmax=seq(1, length(yellows)), 
                                   ymin=rep(2,length(yellows)), ymax=rep(3, length(yellows))))
  
  rgb_blue =hex2RGB(blues)
  hsv_blue = rgb2hsv(r=t(rgb_blue@coords), maxColorValue = 1)
  brightness_blues =  (0.299 * rgb_blue@coords[,1]^2 + 0.587 * rgb_blue@coords[,2]^2 + .114 * rgb_blue@coords[,1]^2 )^(1/2)
  
  d.blue<- as_tibble(data.frame(name=blues, 
                                h=hsv_blue[1,], 
                                s=hsv_blue[2,], 
                                v=hsv_blue[3,],
                                brightness = brightness_blues,
                                xmin=seq(0,length(blues)-1), xmax=seq(1, length(blues)), 
                                ymin=rep(0,length(blues)), ymax=rep(1, length(blues))))
  
  rgb_reds =hex2RGB(reds)
  hsv_red = rgb2hsv(r=t(rgb_reds@coords), maxColorValue = 1)
  brightness_reds =  (0.299 * rgb_reds@coords[,1]^2 + 0.587 * rgb_reds@coords[,2]^2 + .114 * rgb_reds@coords[,1]^2 )^(1/2)
  
  
  
  d.red<- as_tibble(data.frame(name=reds, 
                               h=hsv_red[1,], 
                               s=hsv_red[2,], 
                               v=hsv_red[3,],
                               brightness = brightness_reds,
                               xmin=seq(0,length(reds)-1), xmax=seq(1, length(reds)), 
                               ymin=rep(1,length(reds)), ymax=rep(2, length(reds))))
  
  rgb_extras =hex2RGB(extras)
  hsv_extras = rgb2hsv(r=t(rgb_extras@coords), maxColorValue = 1)
  brightness_extras =  (0.299 * rgb_extras@coords[,1]^2 + 0.587 * rgb_extras@coords[,2]^2 + .114 * rgb_extras@coords[,1]^2 )^(1/2)
  
  
  
  d.extras<- as_tibble(data.frame(name=extras, 
                               h=hsv_extras[1,], 
                               s=hsv_extras[2,], 
                               v=hsv_extras[3,],
                               brightness = brightness_extras,
                               xmin=seq(0,length(extras)-1), xmax=seq(1, length(extras)), 
                               ymin=rep(-1,length(extras)), ymax=rep(0, length(extras))))
  
  
  return(ggplot() +theme_color() + 
    geom_rect(mapping=aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, fill=hsv(h,s,v)), data=d.yellow) + 
      geom_text(mapping=aes(x=xmin + (xmax-xmin)/2, y=ymin + (ymax-ymin)/2, label=paste(name, sprintf("h=%.1f%%", 100*h), 
                                                                                        sprintf("s=%.1f%%", 100*s),
                                                                                        sprintf("v=%.1f%%", 100*v),
                                                                                        sprintf("bright=%.1f%%", 100*brightness), sep = '\n')), color='white', data=d.yellow)+
    geom_rect(mapping=aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, fill=hsv(h,s,v)), data=d.blue) + 
      geom_text(mapping=aes(x=xmin + (xmax-xmin)/2, y=ymin + (ymax-ymin)/2, label=paste(name, sprintf("h=%.1f%%", 100*h), 
                                                                                        sprintf("s=%.1f%%", 100*s),
                                                                                        sprintf("v=%.1f%%", 100*v),
                                                                                        sprintf("bright=%.1f%%", 100*brightness), sep = '\n')), color='white',data=d.blue)+
    geom_rect(mapping=aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, fill=hsv(h,s,v)), data=d.red) + 
    geom_text(mapping=aes(x=xmin + (xmax-xmin)/2, y=ymin + (ymax-ymin)/2, label=paste(name, sprintf("h=%.1f%%", 100*h), 
                                                                                      sprintf("s=%.1f%%", 100*s),
                                                                                      sprintf("v=%.1f%%", 100*v),
                                                                                      sprintf("bright=%.1f%%", 100*brightness), sep = '\n')),color='white', data=d.red)+
      geom_rect(mapping=aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, fill=hsv(h,s,v)), data=d.extras) + 
      geom_text(mapping=aes(x=xmin + (xmax-xmin)/2, y=ymin + (ymax-ymin)/2, label=paste(name, sprintf("h=%.1f%%", 100*h), 
                                                                                        sprintf("s=%.1f%%", 100*s),
                                                                                        sprintf("v=%.1f%%", 100*v),
                                                                                        sprintf("bright=%.1f%%", 100*brightness), sep = '\n')),color='white', data=d.extras)+
    scale_fill_identity() )
}

generate_hue_variance = function(color, s=NA, v=NA){
  
  rgb =hex2RGB(color)
  hsv = rgb2hsv(r=t(rgb@coords), maxColorValue = 1)
  if (is.na(s)){
    s = hsv[2,1]
  }
  if (is.na(v)){
    v = hsv[3,1]
  }
  
  data = data.frame(h=hsv[1,] + seq(-0.02, 0.02, length.out=5), s=rep(s,5), v=rep(v, 5))
  data[data$h < 0,]$h <- 1 +data[data$h < 0,]$h
  print(data)
  return (hsv(data$h, data$s, data$v))
}

base_yellow = '#FFC300'
base_blue = '#003566'
base_red = '#B32300'

step = 0.511
step_2 = 0.8

dark_blue = darken(base_blue,step)

dark_red = darken(base_red,step)

dark_yellow = darken(base_yellow,step)

desaturate_base_yellow = desaturate(base_yellow,0.25)

# Base nautilus palette
yellows = c('#FFD351','#FFD60A','#FFC300', '#E3930D', '#7A4E03')
blues = c('#6FA0D4','#0E63B3', '#003566','#001D3D', '#000814')


reds = c('#DC4432','#C63623',base_red, '#891800', '#620E00')

extras = generate_hue_variance(lighten(base_blue,0.75, space='combined'),s = 0.9)

extras = generate_hue_variance(lighten('#B32300',0.5, space='combined'))
extras #= c('#000000','#000000','#000000', '#000000', '#000000')  

plot_palette(yellows, reds, blues, extras)
ggsave('new_palette_october.png', width=2000, height=1600, units='px')


# New palette
highlight_yellow = '#FFD400'
darker_yellow = '#CC9C00'
very_light_yellow = '#FFE500'
very_dark_yellow = '#B28800'

base_red = '#B32300'
highlight_red = '#D92A00'
darker_red = '#801900'
very_light_red = '#FF3100'
very_dark_red = '#661400'

base_blue = '#003566'
highlight_blue = '#00488C'
darker_blue = '#001A33'
very_light_blue = '#005CB2'
very_dark_blue = '#000D19'

blues = c(very_light_blue, highlight_blue, base_blue, darker_blue, very_dark_blue)


yellows = c(very_light_yellow,highlight_yellow, base_yellow, darker_yellow, very_dark_yellow)

bases = c(base_yellow, base_blue, base_red)

reds = c(very_light_red,highlight_red, base_red, darker_red, very_dark_red)

rgb_yellow =hex2RGB(yellows)

rgb_blue =hex2RGB(blues)

rgb_bases =hex2RGB(bases)
rgb_reds =hex2RGB(reds)

brightness_reds =  (0.299 * rgb_reds@coords[,1]^2 + 0.587 * rgb_reds@coords[,2]^2 + .114 * rgb_reds@coords[,1]^2 )^(1/2)

brightness_blues =  (0.299 * rgb_blue@coords[,1]^2 + 0.587 * rgb_blue@coords[,2]^2 + .114 * rgb_blue@coords[,1]^2 )^(1/2)

brightness_yellows =  (0.299 * rgb_yellow@coords[,1]^2 + 0.587 * rgb_yellow@coords[,2]^2 + .114 * rgb_yellow@coords[,1]^2 )^(1/2)

hsv_yellow = rgb2hsv(r=t(rgb_yellow@coords), maxColorValue = 1)
hsv_blue = rgb2hsv(r=t(rgb_blue@coords), maxColorValue = 1)
hsv_bases = rgb2hsv(r=t(rgb_bases@coords), maxColorValue = 1)
hsv_red = rgb2hsv(r=t(rgb_reds@coords), maxColorValue = 1)
hsv(hsv_blue)

hsv


base_yellow_lum = 0.5
base_blue_lum = 0.20
base_red_lum = 0.35
col2hcl('#B32300')

point_data <- as_tibble(data.frame(name=bases, 
                                 h=hsv_bases[1,], 
                                 s=hsv_bases[2,], 
                                 v=hsv_bases[3,]))

blue_hue = point_data[2,]$h
yellow_hue = point_data[1,]$h

red_hue = blue_hue + (blue_hue - yellow_hue) -1
point_data <- bind_rows(point_data, data.frame(name='red_hue', h=as.numeric(red_hue), s=1, v=1))


# Create hsv grid
h_res = 0.01
v_res = 0.01
d=expand.grid(h=seq(0,0.95,h_res), s=1, v=seq(0,1,v_res))
ggplot() + theme_color() +
  coord_polar(theta="x") +
  scale_fill_identity() +
  geom_rect(data=d, mapping=aes(xmin=h, xmax=h+h_res, ymin=v, ymax=v+v_res, fill=hsv(h,s,v)), size=0.1) +
  geom_rect(data=point_data, mapping=aes(xmin=h, xmax=h+h_res, ymin=v, ymax=v+v_res, fill=hsv(h,s,v)), size=0.1, color='black')

res = 0.01
d.red=expand.grid(h=red_hue, s=1, v=0.7)
ggplot() + theme_color() +
  scale_fill_identity() +
  geom_rect(data=d.red, mapping=aes(xmin=s, xmax=s+1, ymin=v, ymax=v+1, fill=hsv(h,s,v))) 

res = 0.01
d.red=expand.grid(h=red_hue, s=seq(0,1,res), v=seq(0,1,res))
ggplot() + theme_color() +
  scale_fill_identity() +
  geom_rect(data=d.red, mapping=aes(xmin=s, xmax=s+res, ymin=v, ymax=v+res, fill=hsv(h,s,v)), size=0.1) 

d.yellow <- as_tibble(data.frame(name=yellows, 
                          h=hsv_yellow[1,], 
                          s=hsv_yellow[2,], 
                          v=hsv_yellow[3,],
                          brightness = brightness_yellows,
                          xmin=seq(0,length(yellows)-1), xmax=seq(1, length(yellows)), 
                          ymin=rep(2,length(yellows)), ymax=rep(3, length(yellows))))

#d.yellow$s <- d.yellow$s * 0.75
#d.yellow$v <- d.yellow$v * 0.75

d.blue<- as_tibble(data.frame(name=blues, 
                                 h=hsv_blue[1,], 
                                 s=hsv_blue[2,], 
                                 v=hsv_blue[3,],
                              brightness = brightness_blues,
                                 xmin=seq(0,length(blues)-1), xmax=seq(1, length(blues)), 
                                 ymin=rep(0,length(blues)), ymax=rep(1, length(blues))))

#d.blue$s <- d.blue$s * 0.75
#d.blue$v <- d.blue$v * 0.75

d.red<- as_tibble(data.frame(name=reds, 
                              h=hsv_red[1,], 
                              s=hsv_red[2,], 
                              v=hsv_red[3,],
                             brightness = brightness_reds,
                              xmin=seq(0,length(reds)-1), xmax=seq(1, length(reds)), 
                              ymin=rep(1,length(reds)), ymax=rep(2, length(reds))))
#d.red$s <- d.red$s * 0.75
#d.red$v <- d.red$v * 0.75


ggplot() +theme_color() + 
  geom_rect(mapping=aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, fill=hsv(h,s,v)), data=d.yellow) + 
  geom_rect(mapping=aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, fill=hsv(h,s,v)), data=d.blue) + 
  geom_rect(mapping=aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, fill=hsv(h,s,v)), data=d.red) + 
  geom_text(mapping=aes(x=xmin + (xmax-xmin)/2, y=ymin + (ymax-ymin)/2, label=paste(name, sprintf("h=%.1f%%", 100*h), 
                                                                                    sprintf("s=%.1f%%", 100*s),
                                                                                    sprintf("v=%.1f%%", 100*v),
                                                                                    sprintf("bright=%.1f%%", 100*brightness), sep = '\n')), data=d.yellow)+
  geom_text(mapping=aes(x=xmin + (xmax-xmin)/2, y=ymin + (ymax-ymin)/2, label=paste(name, sprintf("h=%.1f%%", 100*h), 
                                                                                    sprintf("s=%.1f%%", 100*s),
                                                                                    sprintf("v=%.1f%%", 100*v),
                                                                                    sprintf("bright=%.1f%%", 100*brightness), sep = '\n')), data=d.blue)+
  geom_text(mapping=aes(x=xmin + (xmax-xmin)/2, y=ymin + (ymax-ymin)/2, label=paste(name, sprintf("h=%.1f%%", 100*h), 
                                                                                    sprintf("s=%.1f%%", 100*s),
                                                                                    sprintf("v=%.1f%%", 100*v),
                                                                                    sprintf("bright=%.1f%%", 100*brightness), sep = '\n')), data=d.red)+
  scale_fill_identity() 
ggsave('new_palette_max_saturation.png', width=2000, height=1200, units='px')

d.yellow$mod_s <- d.yellow$s *seq(0.9, 1, length.out=length(yellows))
d.blue$mod_s <- d.blue$s *seq(0.9, 1, length.out=length(blues))
d.red$mod_s <- d.red$s *seq(0.9, 1, length.out=length(reds))

d.yellow$mod_v <- d.yellow$v *seq(1, 0.9, length.out=length(yellows))
d.blue$mod_v <- d.blue$v *seq(1, 0.9, length.out=length(blues))
d.red$mod_v <- d.red$v *seq(1, 0.9, length.out=length(reds))

d.yellow <- d.yellow %>% mutate(mod_hsv=hsv(h,mod_s,mod_v))
d.blue <- d.blue %>% mutate(mod_hsv=hsv(h,mod_s,mod_v))
d.red <- d.red %>% mutate(mod_hsv=hsv(h,mod_s,mod_v))

ggplot() +theme_color() + 
  geom_rect(mapping=aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, fill=mod_hsv), data=d.yellow) + 
  geom_rect(mapping=aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, fill=mod_hsv), data=d.blue) + 
  geom_rect(mapping=aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, fill=mod_hsv), data=d.red) + 
  geom_text(mapping=aes(x=xmin + (xmax-xmin)/2, y=ymin + (ymax-ymin)/2, label=paste(mod_hsv, sprintf("h=%.1f%%", 100*h), 
                                                                                    sprintf("s=%.1f%%", 100*mod_s),
                                                                                    sprintf("v=%.1f%%", 100*mod_v),
                                                                                    sprintf("bright=%.1f%%", 100*brightness), sep = '\n')), data=d.yellow)+
  geom_text(mapping=aes(x=xmin + (xmax-xmin)/2, y=ymin + (ymax-ymin)/2, label=paste(mod_hsv, sprintf("h=%.1f%%", 100*h), 
                                                                                    sprintf("s=%.1f%%", 100*mod_s),
                                                                                    sprintf("v=%.1f%%", 100*mod_v),
                                                                                    sprintf("bright=%.1f%%", 100*brightness), sep = '\n')), data=d.blue)+
  geom_text(mapping=aes(x=xmin + (xmax-xmin)/2, y=ymin + (ymax-ymin)/2, label=paste(mod_hsv, sprintf("h=%.1f%%", 100*h), 
                                                                                    sprintf("s=%.1f%%", 100*mod_s),
                                                                                    sprintf("v=%.1f%%", 100*mod_v),
                                                                                    sprintf("bright=%.1f%%", 100*brightness), sep = '\n')), data=d.red)+
  scale_fill_identity() 
ggsave('new_palette_modified_saturation.png', width=2000, height=1200, units='px')
d.yellow
d.blue
d.red
