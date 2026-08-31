
# 1. Get file list
files <- list.files(pattern = ".llik", full.names = FALSE)
results <- data.frame(m = numeric(), likelihood = numeric())

for (f in files) {
  # Parse filename to get 'm' (treemix.i.m.llik)
  parts <- strsplit(f, "\\.")[[1]]
  m_val <- as.numeric(parts[3]) 
  
  # Read file lines
  lines <- readLines(f, warn = FALSE)
  
  # Find the line that has the final result
  # We look for the line containing "Exiting"
  final_line <- grep("Exiting", lines, value = TRUE)
  
  if (length(final_line) > 0) {
    # Split the line by spaces
    # "Exiting" "ln(likelihood)" ... "events:" "-112.169"
    line_parts <- strsplit(final_line, " ")[[1]]
    
    # Take the LAST element (the number)
    lik_str <- tail(line_parts, 1)
    
    # Convert to numeric
    lik_val <- as.numeric(lik_str)
    
    results <- rbind(results, data.frame(m = m_val, likelihood = lik_val))
  }
}

# 2. Calculate Stats
library(dplyr)
summary_stats <- results %>%
  group_by(m) %>%
  summarise(
    mean_lik = mean(likelihood),
    sd_lik = sd(likelihood)  )
print(summary_stats)
# 4. Plot
plot(summary_stats$m, summary_stats$mean_lik, type = "b", pch = 19, col = "blue",
     xlab = "Migration Events (m)", ylab = "Log-Likelihood",
     main = "TreeMix Elbow Plot")
