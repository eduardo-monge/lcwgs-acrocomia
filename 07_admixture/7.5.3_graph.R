library(RevGadgets)
library(ggplot2)
library(dplyr)
library(patchwork)

# Load files
base_dir <- "./output"
pops <- c("Amazonas", "Costarican", "Intumescens", "Mesoamerica",
          "Mineiro", "Roraima", "Sudeste", "Totai")

pop_colors <- c(
  Amazonas    = "#70548F",
  Costarican  = "#1634CB",
  Intumescens = "#A77D07",
  Mesoamerica = "#FFC104",
  Mineiro     = "#BBCC33",
  Roraima     = "#2AA49B",
  Sudeste     = "#D81B60",
  Totai       = "#00C2F9")

#Process each population:
plot_list <- list()
all_data  <- data.frame()

for (pop in pops) {
  Ne_log    <- file.path(base_dir, pop, "StairwayPlot_iid_Ne.log")
  times_log <- file.path(base_dir, pop, "StairwayPlot_iid_times.log")
          
  df <- processPopSizes(
    Ne_log, times_log,
    burnin          = 0.1,
    probs           = c(0.025, 0.975),
    summary         = "median",
    num_grid_points = 2000
  )
  
  # 2. Individual plot with  intervals
  p <- ggplot(df, aes(x = time, y = value)) +
    geom_ribbon(aes(ymin = lower, ymax = upper),
                fill  = pop_colors[pop],
                alpha = 0.3) +
    geom_line(color = pop_colors[pop], linewidth = 0.8) +
    scale_x_log10(
      limits = c(1e2, 2e5),
      breaks = c(1e2, 1e3, 1e4, 1e5, 2e5),
      labels = c("100", "1K", "10K", "100K", "")
    ) +
    scale_y_log10(
      limits = c(1e2, 1.5e4),
      breaks = c(1e2, 1e3, 1e4, 1.5e4),
      labels = c("100", "1K", "10K", "")
    ) +
    ggtitle(pop) +
    xlab("Time before present (years)") +
    ylab("Effective Population Size (Ne)") +
    theme_classic(base_size = 11) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      axis.title = element_text(face = "bold")
    )

  ggsave(
    filename = file.path(base_dir, paste0(pop, "_demography.pdf")),
    plot = p, width = 5, height = 4
  )
  
  plot_list[[pop]] <- p
  
  #Add to combined dataframe 
  df$Population <- pop
  all_data <- rbind(all_data, df)
  
  cat("Done:", pop, "\n")
}

#OUTPUT 1: Panel of 8 plots (individual curves with CIs)
panel_plot <- wrap_plots(plot_list, ncol = 4) +
  plot_annotation(theme  = theme(
      plot.title    = element_text(face = "bold", size = 14, hjust = 0.5),
      plot.subtitle = element_text(size = 10, hjust = 0.5)
    )
  )

print(panel_plot)

#OUTPUT 2: All populations overlaid — median lines only
p_lines_only <- ggplot(all_data, aes(x = time, y = value, color = Population)) +
  geom_line(linewidth = 1.2) +
  scale_color_manual(values = pop_colors) +
  scale_x_log10(
    limits = x.lim,
    breaks = c(1e2, 1e3, 1e4, 1e5),
    labels = c("100", "1K", "10K", "100K")
  ) +
  scale_y_log10(
    limits = c(1e3, 1e4),
    breaks = c(1000, 2000, 3000, 5000, 7000, 10000),
    labels = c("1K", "2K", "3K", "5K", "7K", "10K")
  ) +
  xlab("Time before present (years)") +
  ylab("Effective Population Size (Ne)") +
  theme_classic(base_size = 13)

print(p_lines_only)


#Climcaitic Events
library(patchwork)
# Last Glacial Period (full span)
last_glacial <- data.frame(
  xmin = 11700,
  xmax = 115000)

# Cold events
cold_events <- data.frame(
  event = c("LIA", "4.2 ka", "8.2 ka", "YD", "HS1", "Eemian"),
  xmin  = c(100,   4000,     8000,    11700,   14700,  115000),
  xmax  = c(600,   4400,     8400,    12900,   17000,  130000))

# Warm events
warm_events <- data.frame(
  event = c("Early warming", "Holocene Optimum", "B-A"),
  xmin  = c(9000,  5000,  12900),
  xmax  = c(11700, 9000,  14700))

# LGM (stronger blue)
lgm <- data.frame(
  xmin = 19000,
  xmax = 26500)

# Epoch boundaries
epochs <- data.frame(
  epoch = c("Holocene", "Late Pleistocene"),
  xmin  = c(100,   11700),
  xmax  = c(11700, 200000))

# Holocene subdivisions (Walker et al. 2018)
holocene_sub <- data.frame(
  stage = c("Meghalayan", "Northgrippian", "Greenlandian"),
  xmin  = c(100,    4200,    8326),
  xmax  = c(4200,   8326,    11700))

#Graoh
p_geo <- ggplot() +
  geom_rect(data = epochs,
            aes(xmin = xmin, xmax = xmax, ymin = 0, ymax = 1, fill = epoch),
            alpha = 0.6, color = "black", linewidth = 0.4) +
  geom_text(data = epochs,
            aes(x = sqrt(xmin * xmax), y = 0.5, label = epoch),
            size = 3.2, fontface = "bold") +
  scale_fill_manual(values = c("Holocene" = "#FFE4B5",
                               "Late Pleistocene" = "#F4A460")) +
  scale_x_log10(limits = x.lim) +
  ylim(0, 1) +
  theme_void() +
  theme(legend.position = "none",
        plot.margin     = margin(5, 5, 0, 5))

#Holocene subdivisions bar
p_holo <- ggplot() +
  geom_rect(data = holocene_sub,
            aes(xmin = xmin, xmax = xmax, ymin = 0, ymax = 1, fill = stage),
            alpha = 0.7, color = "black", linewidth = 0.3) +
  geom_text(data = holocene_sub,
            aes(x = sqrt(xmin * xmax), y = 0.5, label = stage),
            size = 2.6, fontface = "bold") +
  scale_fill_manual(values = c("Meghalayan"     = "#FFDAB9",
                               "Northgrippian"  = "#FFCC99",
                               "Greenlandian"   = "#FFBB77")) +
  scale_x_log10(limits = x.lim) +
  ylim(0, 1) +
  theme_void() +
  theme(legend.position = "none",
        plot.margin     = margin(0, 5, 0, 5))

#Main demographic plot
p_main <- ggplot(all_data, aes(x = time, y = value)) +
  geom_rect(data = last_glacial,
            inherit.aes = FALSE,
            aes(xmin = xmin, xmax = xmax, ymin = 1e3, ymax = 1e4),
            fill = "#B0E0E6", alpha = 0.30) +
  geom_rect(data = cold_events,
            inherit.aes = FALSE,
            aes(xmin = xmin, xmax = xmax, ymin = 1e3, ymax = 1e4),
            fill = "#87CEEB", alpha = 0.5) +
  geom_rect(data = warm_events,
            inherit.aes = FALSE,
            aes(xmin = xmin, xmax = xmax, ymin = 1e3, ymax = 1e4),
            fill = "#FFB6A3", alpha = 0.4) +
  geom_rect(data = lgm,
            inherit.aes = FALSE,
            aes(xmin = xmin, xmax = xmax, ymin = 1e3, ymax = 1e4),
            fill = "#1E90FF", alpha = 0.35) +
  geom_vline(xintercept = c(100, 600, 4000, 4400, 5000, 8000, 8400, 9000,
                            11700, 12900, 14700, 17000, 19000, 26500,
                            115000, 130000),
             linetype = "dotted", color = "gray40", linewidth = 0.3) +
  
  #  Event labels
  annotate("text", x = sqrt(100 * 600),        y = 9500, label = "LIA",
           size = 2.3, fontface = "bold", color = "gray20") +
  annotate("text", x = sqrt(4000 * 4400),      y = 9500, label = "4.2 ka",
           size = 2.3, fontface = "bold", color = "gray20") +
  annotate("text", x = sqrt(5000 * 9000),      y = 9500, label = "HCO",
           size = 2.5, fontface = "bold", color = "gray30") +
  annotate("text", x = sqrt(8000 * 8400),      y = 8500, label = "8.2 ka",
           size = 2.3, fontface = "bold", color = "gray20") +
  annotate("text", x = sqrt(9000 * 11700),     y = 8500, label = "EW",
           size = 2.3, fontface = "bold", color = "gray30") +
  annotate("text", x = sqrt(11700 * 12900),    y = 9500, label = "YD",
           size = 2.3, fontface = "bold", color = "gray20") +
  annotate("text", x = sqrt(12900 * 14700),    y = 8500, label = "B-A",
           size = 2.3, fontface = "bold", color = "gray30") +
  annotate("text", x = sqrt(14700 * 17000),    y = 9500, label = "HS1",
           size = 2.3, fontface = "bold", color = "gray20") +
  annotate("text", x = sqrt(19000 * 26500),    y = 9500, label = "LGM",
           size = 3, fontface = "bold", color = "gray20") +
  annotate("text", x = sqrt(26500 * 115000),   y = 9500, label = "Last Glacial Period",
           size = 3, fontface = "italic", color = "gray30") +
  annotate("text", x = sqrt(115000 * 130000),  y = 9500, label = "Eemian",
           size = 2.5, fontface = "bold", color = "gray20") +
  
  # Population curves 
  geom_line(aes(color = Population), linewidth = 1.2) +
  scale_color_manual(values = pop_colors) +
  scale_x_log10(
    limits = x.lim,
    breaks = c(1e2, 1e3, 1e4, 1e5, 2e5),
    labels = c("100", "1K", "10K", "100K", "200K")
  ) +
  scale_y_log10(
    limits = c(1e3, 1e4),
    breaks = c(1000, 2000, 3000, 5000, 7000, 10000),
    labels = c("1K", "2K", "3K", "5K", "7K", "10K")
  ) +
  xlab("Time before present (years)") +
  ylab("Effective Population Size (Ne)") +
  theme_classic(base_size = 13) +
  theme(
    legend.position = "right"
  )

p_main

#Stack all three panels
final_plot <- p_geo / p_holo / p_main +
  plot_layout(heights = c(0.5, 0.4, 6)) 
final_plot

