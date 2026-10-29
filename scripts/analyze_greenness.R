# Run from the project folder after downloading the GEE CSV to data/greenness/.
library(sf)
library(dplyr)
library(ggplot2)

setwd("/Users/bryan/Documents/Graduate/5320 Sustainable/assignment/1/shenzhen_greenness_pm25")
file.exists("data/greenness/shenzhen_district_greenness_2025.csv")

gee_file <- "data/greenness/shenzhen_district_greenness_2025.csv"

greenness <- read.csv(gee_file, stringsAsFactors = FALSE, check.names = FALSE)
pm25 <- read.csv("data/air_quality/pm25_district_2025.csv", stringsAsFactors = FALSE)
districts <- st_read("data/boundaries/shenzhen_districts.shp", quiet = TRUE)

# GEE's combined reducer names the output bands ndvi_mean and vegetated_pct_mean.
analysis <- pm25 %>%
  select(dist_id, dist_zh, mean_pm25, median_pm25, n_pm25, coverage_pct) %>%
  inner_join(greenness %>%
               select(dist_id, dist_zh, district, ndvi_mean,
                      vegetated_pct_mean, ndvi_count),
             by = c("dist_id", "dist_zh"))

write.csv(analysis, "outputs/district_results.csv",
          row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.csv(analysis, "outputs/district_greenness_pm25_2025.csv",
          row.names = FALSE, na = "", fileEncoding = "UTF-8")

map_data <- districts %>%
  left_join(analysis %>% select(-district), by = "dist_zh") %>%
  st_transform(32649)

ndvi_map <- ggplot(map_data) +
  geom_sf(aes(fill = ndvi_mean), color = "white", linewidth = 0.4) +
  geom_sf_text(aes(label = district), size = 2.8, color = "#17324D") +
  scale_fill_gradient(low = "#F7FCF5", high = "#238B45", na.value = "grey85",
                      name = "Mean NDVI") +
  labs(title = "Greenness across Shenzhen districts",
       subtitle = "2025 annual median Sentinel-2 NDVI, averaged over valid land pixels") +
  theme_void(base_size = 12) +
  theme(plot.title = element_text(face = "bold", color = "#123B68"),
        plot.subtitle = element_text(color = "grey35"))
ggsave("outputs/map_ndvi_2025.png", ndvi_map, width = 8, height = 6,
       dpi = 300, bg = "white")

pm_map <- ggplot(map_data) +
  geom_sf(aes(fill = mean_pm25), color = "white", linewidth = 0.4) +
  geom_sf_text(aes(label = district), size = 2.8, color = "#17324D") +
  scale_fill_gradient(low = "#DEEBF7", high = "#08519C", na.value = "grey85",
                      name = "PM2.5\n(ug/m3)") +
  labs(title = "Annual mean PM2.5 across Shenzhen districts",
       subtitle = "2025 district-level daily summaries") +
  theme_void(base_size = 12) +
  theme(plot.title = element_text(face = "bold", color = "#123B68"),
        plot.subtitle = element_text(color = "grey35"))
ggsave("outputs/map_pm25_2025.png", pm_map, width = 8, height = 6,
       dpi = 300, bg = "white")

association_plot <- ggplot(analysis,
                           aes(x = vegetated_pct_mean, y = mean_pm25)) +
  geom_point(size = 3.5, color = "#2171B5") +
  geom_text(aes(label = district), nudge_y = 0.35, size = 3.2,
            check_overlap = TRUE) +
  geom_smooth(method = "lm", se = TRUE, color = "#4D4D4D",
              fill = "#D9EAF7", linewidth = 0.8) +
  labs(title = "District greenness and PM2.5 in Shenzhen",
       subtitle = "Each point is one district; the line is a descriptive linear fit",
       x = "Annual median vegetation-threshold indicator (%)",
       y = "Annual mean PM2.5 (ug/m3)") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold", color = "#123B68"),
        panel.grid.minor = element_blank())
ggsave("outputs/greenness_pm25_scatter_2025.png", association_plot,
       width = 8, height = 6, dpi = 300, bg = "white")

correlation <- cor.test(analysis$vegetated_pct_mean, analysis$mean_pm25,
                        method = "spearman", exact = TRUE)
without_dapeng <- analysis %>% filter(district != "Dapeng")
sensitivity <- cor.test(without_dapeng$vegetated_pct_mean,
                        without_dapeng$mean_pm25,
                        method = "spearman", exact = TRUE)
summary <- data.frame(
  districts = nrow(analysis),
  spearman_rho = unname(correlation$estimate),
  p_value_exact = correlation$p.value,
  rho_excluding_dapeng = unname(sensitivity$estimate),
  p_exact_excluding_dapeng = sensitivity$p.value,
  note = "Only ten districts; association is exploratory and not causal."
)
write.csv(summary, "outputs/exploratory_association.csv", row.names = FALSE)
print(analysis)
print(summary)
