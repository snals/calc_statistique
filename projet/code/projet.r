#USELESS CHANGE TO PATH
#
#stwd("")
#
#


#TODO comment
compute_cens <- function(vector, file_to_save){
  f <- table(vector)

  data_to_write <- matrix(c(f[[1]], f[[1]]/length(vector), f[[2]], f[[2]]/length(vector)),
    nrow=2, ncol=2) 
  rownames(data_to_write) <- c("Effectif", "Fréquence")
  colnames(data_to_write) <- c("Censuré","Non censuré")

  sink(file=file_to_save, append=TRUE)
  print(data_to_write, digits=2)
  sink()
}

#TODO comment
compute_treat <- function(vector, file_to_save){
  f <- table(vector)
  n <- sum(is.na(vector))
  l <- length(vector)
  data_to_write <- matrix(c(f[[1]], f[[1]]/l, f[[2]], f[[2]]/l, n, n/l),
    nrow=2, ncol=3) 
  rownames(data_to_write) <- c("Effectif", "Fréquence")
  colnames(data_to_write) <- c("Traitement A","Traitement B", "NA")

  sink(file=file_to_save, append=TRUE)
  print(data_to_write, digits=2)
  sink()
}

#
# data is a clean matrix where all of the elements are meaningful
# for the statistical measurement
# for this case it will be data[data["CENS"] == 1,] 
#
stat_descr <- function(data, file_to_save){
  #todo : improve the function to hava generic col name  
  T = gsub("[,]",".", data$T)
  AGE = gsub("[,]",".", data$AGE)
  summary_T <- summary(as.vector(T, mode="numeric"), na.rm=TRUE)
  names <- names(summary_T)
  summary_AGE <- summary(as.vector(AGE, mode="numeric"), na.rm=TRUE)
  sd_T <- sd(T, na.rm=TRUE)
  sd_AGE <- sd(AGE, na.rm=TRUE)

  data_to_write <- matrix(c(summary_T, sd_T, summary_AGE[1:6], sd_AGE),
			  nrow=7, ncol=2)
  rownames(data_to_write) <- c(names, "Ecart-type")
  colnames(data_to_write) <- c("T","AGE")
  sink(file=file_to_save, append=TRUE)
  print(data_to_write, digits=4)
  sink()
  #write.table(data_to_write, file_to_save, append=TRUE) #does shitty print
}

#
# Fifth point of the Part A. Standardize a column. 
# To use the function to standardize age, you have to give data$AGE to 
# the parameter data of the function.
#
standardization <- function(data){
  AGE <- as.vector(gsub("[,]", ".", data), mode="numeric")
  sd_AGE <- sd(AGE, na.rm=TRUE)
  mean_AGE <- mean(AGE, na.rm=TRUE)
  return (na.omit((AGE - mean_AGE)/sd_AGE))
}


plot_graphs <- function(lambda, beta1, beta2, zone){
  jpeg(paste(n, "postérieur.jpeg", sep="_"), width = 640, height = 640, units = "px", quality = 90)
  par(mfrow = c(2,3))
  plot(lambda[,2], type = "l", ylab = "lambda", xlab = "nb iteration")
  plot(beta1[,2], type = "l", ylab = "AGE", xlab = "nb iteration")
  plot(beta2[,2], type = "l", ylab = "TRT", xlab = "nb iteration")
  hist(lambda[,2], probability=TRUE, main = "", ylab = "Density", xlab = "lambda")
  lines(density(lambda[,2]), col="blue")
  hist(beta1[,2], probability=TRUE, main = "", ylab = "Density", xlab = "AGE")
  lines(density(beta1[,2]), col="blue")
  hist(beta2[,2], probability=TRUE, main = "", ylab = "Density", xlab = "TRT")
  lines(density(beta2[,2]), col="blue")
  op <- dev.off()
}

plot_function <- function(lambda, beta1, beta2, zone, data){
  jpeg(paste(n, "survie.jpeg", sep="_"), width = 640, height = 640, units = "px", quality = 90)
  t <- seq(from = 0, to = 7, by = 0.1)
  lamb <- median(lambda[,2]) #should I use lambda ?
  stAge <- standardization(data$AGE) 
  mBeta1 <- median(beta1[,2])
  mBeta2 <- median(beta2[,2])
  beta <- c(mBeta1, mBeta2)
  x <- c(median(stAge), 0)  #median(stAge) renvoie de la merde ... sd(f[[1]]$AGE
  exponent <- x%*%beta
  S <- exp(-lamb*t)^exp(exponent)
  plot(t, S, type = "l", col="blue")
  x <- c(median(stAge), 1)  #median(stAge) renvoie de la merde
  exponent <- x%*%beta
  S <- exp(-lamb*t)^exp(exponent)
  lines(t, S, type = "l", lty = "longdash", col="red")
  op <- dev.off()
}

data <- read.table("../resources/ProjetR.txt", header=TRUE, sep="*", skip=1)

s <- split(data, data$PROV)

for(i in 1:length(s)){
  p <- s[i]

  n <- names(p)
  n <- gsub(" ", "_", n)
  filename <- paste(n, ".txt", sep="")

  file.create(filename)

  #Part 1
  cat("Statistiques descriptives pour le province  Brabant Wallon  : \n", file=filename, append=TRUE)
  cat("_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _  \n\n", file=filename, append=TRUE)
  cat("Nombre de patient ayant subi l'événement versus les patients censurés : \n\n", file=filename, append=TRUE)
  #compute censure freq
  compute_cens(p[[1]]$CENS, filename)

  cat("\nNombre de patient ayant reçu le traitement A vs les patients ayant reçu le traitement B : \n\n", file=filename, append=TRUE)
  #compute treatment freq
  compute_treat(p[[1]]$TRT, filename)

  cat("\nStatistiques descriptives pour les concernant les temps de rechute\nainsi que l'âge des patients ayant subi une rechute :\n\n", file=filename, append=TRUE)
  #compute desc stats
  stat_descr(p[[1]][p[[1]]["CENS"]==1,], filename)
}


#Part B.1
  
#TODO comment
lambda <- read.table("../resources/lambda_Flandre.txt")
beta1 <- read.table("../resources/beta1_Flandre.txt")
beta2 <- read.table("../resources/beta2_Flandre.txt")

plot_graphs(lambda, beta1, beta2, "Flandre")

#Part B.2

plot_function(lambda, beta1, beta2, "Flandre", s[3][[1]])



