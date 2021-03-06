rm(list=ls())
require(geoR)
load('ibm.Rdata')

# wafer outlier
n <- 14
ibm$idno <- ibm$lot_ID*100 + ibm$wafer_ID
ww <- matrix(0, nrow=M, ncol=1+n)
ww2 <- matrix(0, nrow=M, ncol=1+n)
for (i in 1:M) {
ww[i, ] <- colMeans(ibm[ibm$idno == unique(ibm$idno)[i], 5:dim(ibm)[2]])
ww2[i, ] <- colSums((ibm[ibm$idno == unique(ibm$idno)[i], 5:dim(ibm)[2]])^2)/dim(ibm[ibm$idno == unique(ibm$idno)[i], 5:dim(ibm)[2]])[1]
}
head(ww)
## w ~ MVN(mu, Sigma)
## d2 ~ chisq2 test
mu <- colMeans(ww[ ,-ncol(ww)])
llsig <- list()
for (i in 1:M){
  llsig[[i]] <- tcrossprod(ww[i,-ncol(ww)] - mu)
}
Sigma <- 1/M * Reduce('+', llsig)

d2 <- rep(0, M)
for (i in 1:M){
  d2[i] <- t(ww[i,-ncol(ww)] - mu) %*% solve(Sigma) %*% (ww[i,-ncol(ww)] - mu)
}
z <- qnorm(pchisq(d2,n)) #BH Fdr
hist(z)



wwmu <- rowMeans(ww[ ,-ncol(ww)])
wwv <- rowMeans(ww2[ ,-ncol(ww2)])
bad2 <- unique(ibm$idno)[which(wwmu > 9.1 | wwmu < 7.9)]
bad3 <- unique(ibm$idno)[which(wwv > 80 | wwv < 60)]
bad <- unique(ibm$idno)[which(abs(z) > 3)]
bad[which(!(bad %in% ll))]
bad2[which(!(bad2 %in% ll))]
bad3[which(!(bad3 %in% ll))]

## wafer meas heatmap
plotWmap <- function(dm, id){
  title <- sprintf("Lot%dWafer%d", id$l, id$w)
  fn <- sprintf("%s.jpeg",title)
  fig <- ggplot(dm, aes(x = chipX, y = chipY)) + scale_x_continuous(breaks=1:13) + scale_y_continuous(breaks=1:13)
  fig <- fig + geom_point(aes(colour = dieMean),shape = 15,size = 10) + ggtitle(title)
  fig <- fig + guides(colour = guide_colorbar(barwidth = 0.5, barheight = 20))
  fig
  ggsave(filename=fn, plot=fig)
}



#IBMC <- read.table("IBMC.csv", sep=",", header=T)
id <- IBMC$lot_ID*100 + IBMC$wafer_ID
wid <- unique(id)
for (mi in wid){
#mi=707
  pid <- lw.id(mi)
  wwData <- IBMC[IBMC$lot == pid$l & IBMC$wafer == pid$w,  ]
  dieMean<-rowMeans(wwData[  ,grep("psro", names(IBMC))])
  dm <- cbind(wwData[  ,c('chipX','chipY')], dieMean)
  plotWmap(dm, pid)
}






