library(ggplot2)
#library(ggpubr)
theme_set(
  theme_minimal() +
    theme(legend.position = "top")
  )

# Load data
data("mtcars")
df <- mtcars
# Convert cyl as a grouping variable
df$cyl <- as.factor(df$cyl)
# Inspect the data
#head(df[, c("wt", "mpg", "cyl", "qsec")], 4)

# b <- ggplot(df, aes(x = wt, y = mpg))

# b <- b + geom_point(aes(color = mpg), size = 3) +
#   scale_color_gradientn(colors = c("#00AFBB", "#E7B800", "#FC4E07"))

n=100
from=0
to=1

cl_from=0
cl_to=0.1

a<-seq(cl_from,cl_to, length.out=n)
b<-rep(1,n)
c<-runif(n, from, to)

df <- data.frame("a" = a, "b" = b, "c" = c)

a<-seq(cl_from,cl_to, length.out=n)
b<-rep(2,n)
c<-runif(n, from, to)
df2 <- data.frame("a" = a, "b" = b, "c" = c)
df <- rbind(df,df2)

a<-seq(cl_from,cl_to, length.out=n)
b<-rep(3,n)
c<-runif(n, from, to)
df2 <- data.frame("a" = a, "b" = b, "c" = c)
df <- rbind(df,df2)

a<-seq(cl_from,cl_to, length.out=n)
b<-rep(4,n)
c<-runif(n, from, to)
df2 <- data.frame("a" = a, "b" = b, "c" = c)
df <- rbind(df,df2)

a<-seq(cl_from,cl_to, length.out=n)
b<-rep(5,n)
c<-runif(n, from, to)
df2 <- data.frame("a" = a, "b" = b, "c" = c)
df <- rbind(df,df2)

pdf(width = 10, height = 5)
graph <- ggplot(df, aes(a,b)) + geom_raster(aes(fill=c))+
        theme(legend.position = "right", 
              axis.line = element_line(colour="black"),
              axis.ticks= element_line(colour="black"))+
        guides(fill = guide_colourbar(barwidth = 1, barheight = 15, ticks.colour = "black"))+
        scale_fill_gradientn(limits = c(0,1), breaks = c(0, 0.2, 0.4, 0.6, 0.8,1), colors = c("#1f22ff", "#18a0c9","#41f469","#d9f83f", "#ffa628","#ff1b15"))+
        labs(title="TITOLO",
         x="C/L", #non voglio l'etichetta sulla x
         y="SCADENZE",
         fill = "VALORE")+
         scale_y_continuous(breaks=c(1,2,3,4,5), labels=c("+12/+24","+24/+36","+36/+48","+48/+60","+60/+72"),expand = c(0, 0))+
         scale_x_continuous(breaks=seq(cl_from,cl_to,by=cl_to/10),expand = c(0, 0))


# graph <- graph + 
#         geom_rect(data= df, aes(x = a, y = b, color = c), shape=15,size = 3) +
#         geom_point(data= df2, aes(x = a, y = b, color = c),shape=15, size = 3) +
#   scale_color_gradientn(colors = c("#00AFBB", "#E7B800", "#FC4E07"))


# graph <- graph+ggplot(df2, aes(x = a, y = b))

print(graph)