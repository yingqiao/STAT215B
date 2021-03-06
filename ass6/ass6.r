#### Ying Qiao
#### SID: 21412301
#### STAT 215B, Assignment 6, 3/22/2013


rm(list=ls())

#### Prostate microarray data
## load data
load("prostatedata.Rda")
N <- dim(prostatedata)[1]
#i: gene
#j: 1-50   normal patients
#   51-102 cancer patients

## Figure 2.1
x1 <- rowMeans(prostatedata[ ,1:50])
x2 <- rowMeans(prostatedata[ ,51:102])

s2 <- (1/50 + 1/52)/100 * (rowSums((prostatedata[ ,1:50] - x1)^2) + rowSums((prostatedata[ ,51:102] - x2)^2))
t <- (x2 - x1) / sqrt(s2)
z <- qnorm(pt(t, 100)) #greater
hist(z, breaks=100, xlim=c(-5,5), xlab="z values->", ylab="Frequency", main="", col="grey")

## Figure 4.2
q <- 0.1
p <- pt(-t, 100)
p.sort <- sort(p)
R <- length(p.sort[p.sort <= q/N*(1:N)])
q*R # false discovery?
plot(1:50, p.sort[1:50], typ="p", pch="*", col="black", xlab="index i", ylab="ordered p-values")
lines(x=1:50, y=q/N*(1:50), lwd=2)

