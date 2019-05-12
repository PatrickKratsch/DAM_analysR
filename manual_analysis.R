###############################################################################
#####################  ANALYSIS OF DAM BEHAVIOURAL DATA  ######################
###############################################################################
###############################################################################

# Load libraries
library("data.table")
library("dplyr")
library("ggplot2")
library("FSA")

###############################################################################
# Read in monitors
M103 <- read.table("../Monitor103.txt") %>% setDT()

# Select relevant day(s)
M103 <- M103[V2 == 29 | V2 == 30] %>% subset(V3 == "Oct") %>% subset(V4 == "18")

# Select relevant times
start <- which(M103$V2 == "29" & M103$V5 == "09:00:00") 
end <- which(M103$V2 == "30" & M103$V5 == "09:00:00")
start_testDead <- which(M103$V2 == "29" & M103$V5 == "21:00:00") 
end_testDead <- which(M103$V2 == "30" & M103$V5 == "09:00:00")

M103exp <- M103[start:end, ]

# Get fly movement data only
M103exp <- M103exp[, 13:44]

# Split monitors into relevant genotypes
a <- M103exp[, 1:16]
b <- M103exp[, 17:32]

# Sum up all beam crosses
a <- colSums(a) 
b <- colSums(b)

# Remove dead flies
M103exp_testDead <- M103[start_testDead:end_testDead, ]

# Get fly movement data only
M103exp_testDead <- M103exp_testDead[, 13:44]

# Split monitors into relevant genotypes
a <- M103exp_testDead[, 1:16]
b <- M103exp_testDead[, 17:32]

# Sum up all beam crosses
a_testDead <- colSums(a_testDead) 
b_testDead <- colSums(b_testDead)

# Remove dead flies
a[which(a_testDead == 0)] <- NA
b[which(b_testDead == 0)] <- NA

###############################################################################
## Combine replicates and plot
# Adjust lenghts
# Adjust length to max_length - choose arbitrary number of 128
max_length <- 128

length(a) <- max_length
length(b) <- max_length

# Combine into single dt
crosses <- cbind(a, b)

crosses <- melt(crosses)[, 2:3]
setDT(crosses)
colnames(crosses) <- c("genotype", "beam_crosses")
crosses <- na.omit(crosses)

gg <- ggplot(crosses, aes(x = genotype, y = beam_crosses)) + 
  geom_boxplot(outlier.shape = NA, na.rm = TRUE, aes(fill = Genotype)) +
  geom_jitter(position = position_jitter(0.2, 0), na.rm = TRUE, shape = 4, size = 4) +
  scale_x_discrete(name = NULL, labels = NULL) +
  scale_y_continuous(name = "Beam Breaks / 24 h") +
  scale_fill_manual(values = c("grey64", "firebrick")) +
  theme_bw() +
  theme(axis.title.y = element_text(size = 50, margin = margin(t = 0, r = 30, b = 0, l = 0)), 
        text = element_text(size = 50), 
        legend.text = element_text(size = 30, face = "italic"),
        legend.justification = c(1, 1), legend.position = c(1, 1),
        legend.box.margin = margin(c(10, 10, 10, 10)),
        legend.title = element_blank(),
        axis.text.x = element_text(face = "italic", angle = 45, hjust = 1, vjust = 1))

gg

# Stats
a <- crosses[Genotype == "a"]
b <- crosses[Genotype == "b"]

kruskal.test(a$beam_crosses ~ a$genotype, data = a)
dunnTest(a$beam_crosses ~ a$genotype, data = a)

kruskal.test(b$beam_crosses ~ b$genotype, data = b)
dunnTest(b$beam_crosses ~ b$genotype, data = b)

# Replicate numbers per genotype
crosses[, .N, by = genotype]

###############################################################################
###############################################################################
sessionInfo()
