#!/usr/bin/env Rscript

# Script to print Chord diagrams and Correlation plots for Nicole NIH Project
# Called as part of murcs_script.py.
# Reqires the user to imput the directory containing the output files from the count_NIH_spacers.py script
# Will look for files ending in the following:
#   spacer_combinations_withoutReplacement_value_for_Chord_Diagrams_forPlotting.txt
#   spacer_combinations_withReplacement_value_for_correlation_plots_forPlotting.txt
# Script will import the files, make the plots, write the plots to the file in the same directory
# This script has been tested on MacOS 12.6. Modification may be required to run on other operating systems
# Author:  kmyers2@wisc.edu

library(reshape2)
library(circlize)
library(ggplot2)

args <- commandArgs(TRUE)
working.dir <- args[1]
setwd(working.dir)

grid.col = c(lpg0059="aquamarine",lpg0086="bisque",lpg0107="blue",lpg0140="brown",
             lpg0171="brown1",lpg0246="burlywood4",lpg0404="cadetblue",lpg0439="cadetblue1",
             lpg0518="chartreuse",lpg0716="chartreuse4",lpg1099="chocolate",lpg1525="chocolate4",
             lpg1527="coral",lpg1621="coral4",lpg1661="cyan",lpg1701="cyan3",lpg1907="darkgoldenrod",
             lpg2223="purple",lpg2244="green",lpg2552="green4",lpg2584="honeydew",
             lpg2692="hotpink",lpg2874="indianred1",lpg2884="khaki1",lpg2888="red",
             lpg0016="lightblue1",lpg0096="lightgoldenrod3",lpg1959="lightpink",lpg2271="lightsalmon",
             lpg2804="lightskyblue",lpg2885="magenta",lpg3000="blue",lpg1689="mediumorchid3",
             lpg1776="mediumpurple1",lpg2628="olivedrab2",lpg0963="orange",lpg1137="orangered",
             lpg0621="palegreen1",lpg2733="royalblue1",lpg2806="seagreen1",lpg1702="purple1")

#Plot chord plots using files from murcs_script.py

chord_files <- list.files(path = working.dir, pattern = "spacer_combinations_withoutReplacement_value_for_Chord_Diagrams_forPlotting.txt")
for(i in chord_files){
  sample_name <- strsplit(i, split='.ccs')[[1]][1]
  fileName = paste(sample_name,"pairwise_minHit5_chordDiagram.pdf", sep = "_")
  pdf(fileName, width = 12, height = 12)
  
  list1 <- read.table(file = i, sep = "\t", header = TRUE)
  list1_minHit5 <- list1[list1$Count > 4,]
  matrix1 <- acast(list1_minHit5, Spacer_1~Spacer_2, value.var="Count")
  chordDiagram(matrix1, annotationTrack = "grid", transparency = 0.1, grid.col = grid.col, preAllocateTracks = list(track.height = max(strwidth(unlist(dimnames(matrix1))))))
  
  circos.track(track.index = 1, panel.fun = function(x, y) {
    circos.text(CELL_META$xcenter, CELL_META$ylim[1], CELL_META$sector.index, 
                facing = "clockwise", niceFacing = TRUE, adj = c(0, 0.5))
  }, bg.border = NA)
  
  title(paste(sample_name, " All Pairwise Connections (MinHit = 5)", sep = " "))
  dev.off()
}

#Plot correlation plots using files from murcs_script.py

correlation_files <- list.files(path = working.dir, pattern = "spacer_combinations_withReplacement_value_for_correlation_plots_forPlotting.txt")

for(i in correlation_files){
  sample_name <- strsplit(i, split='.ccs')[[1]][1]
  fileName = paste(sample_name,"pairwise_allHits_correlationPlot.pdf", sep = "_")
  fileName_minHit5 = paste(sample_name, "pairwise_minHit5_correlationPlot.pdf", sep = "_")

  list1 <- read.table(file = i, sep = "\t", header = TRUE) #needs to have all the possible combinations
  
  #gradient chart additional 0-5 bin
  list1_new <- list1
  list1_new$group <- cut(list1_new$Count, breaks = c(-1, 0, 4, 10, 100, 500, 1000, 5000, 10000))
  pdf(fileName, width = 12, height = 12)
  plt <- ggplot(list1_new, aes(x=Spacer_1, y=Spacer_2)) +
    geom_tile(aes(fill=group), color = "black") +
    coord_fixed() +
    scale_fill_manual(breaks = levels(list1_new$group), values = c("white", "wheat", "#BB9D00", "#F8766D", "#E76BF3", "#00C0B8", "#00A5FF", "black"), name = "Pairwise\nOccurances", labels = c("No Hit", "1-4", "5-10", "11-100", "101-500", "501-1000", "1001-5000", "Same Spacer")) +
    theme(axis.text.x = element_text(
      angle = 90)
    ) + 
    ggtitle(paste(sample_name, "Pairwise Gene Counts (gradient) updated scale", sep = " ")) +
    scale_x_discrete(name = "Spacer 1") +
    scale_y_discrete(name = "Spacer 2")
  print(plt)
  dev.off()
  
  #gradient chart ≥5
  list1_new <- list1
  list1_new$group <- cut(list1_new$Count, breaks = c(-1, 4, 10, 100, 500, 1000, 5000, 10000))
  pdf(fileName_minHit5, width = 12, height = 12)
  plt <- ggplot(list1_new, aes(x=Spacer_1, y=Spacer_2)) +
    geom_tile(aes(fill=group), color = "black") +
    coord_fixed() +
    scale_fill_manual(breaks = levels(list1_new$group), values = c("white", "#BB9D00", "#F8766D", "#E76BF3", "#00C0B8", "#00A5FF", "black"), name = "Pairwise\nOccurances", labels = c("0-4", "5-10", "11-100", "101-500", "501-1000", "1001-5000", "Same Spacer")) +
    theme(axis.text.x = element_text(
      angle = 90)
    ) + 
    ggtitle(paste(sample_name, "Pairwise Gene Counts (gradient) minimum 5 hits", sep = " ")) +
    scale_x_discrete(name = "Spacer 1") +
    scale_y_discrete(name = "Spacer 2")
  print(plt)
  dev.off()
}