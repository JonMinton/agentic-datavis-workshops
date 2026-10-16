# Figure 02. Requested by the facilitator: the (assumed) genre of each list's top five,
# as a Sankey-style alluvial chart. Outside the gg-spec schema, because the alluvium and
# stratum geoms come from the ggalluvial extension, not from ggplot2 itself.
#
# The one assumption: all five top-five albums with no genre in the data are by the
# Beatles or the Beach Boys, and none of the dataset's 16 genre groups is plain rock or
# pop. They are labelled "Rock/Pop (assumed)".
library(tidyverse)
library(ggalluvial)

assumed_genre <- "Rock/Pop (assumed)"
outside       <- "Outside top 5"

short_title <- c(
  "Sgt. Pepper's Lonely Hearts Club Band" = "Sgt. Pepper's",
  "Highway 61 Revisited"                  = "Highway 61 Revisited",
  "Songs in the Key of Life"              = "Songs in the Key of Life"
)

rolling_stone <- read_csv("data/tt-2024-05-07-rolling_stone.csv", show_col_types = FALSE)

# Grain: one row per album per list, for the albums that were ever in a top five
top5 <- rolling_stone |>
  filter(pmin(rank_2003, rank_2012, rank_2020, na.rm = TRUE) <= 5) |>
  mutate(
    genre = replace_na(genre, assumed_genre),
    album = coalesce(short_title[album], album)
  ) |>
  pivot_longer(starts_with("rank_"), names_to = "list", names_prefix = "rank_",
               values_to = "rank") |>
  mutate(
    position = if_else(rank <= 5, genre, outside),
    position = fct_relevel(factor(position), outside, after = Inf),
    genre    = fct_relevel(factor(genre), assumed_genre)
  )

genre_cols <- c(
  set_names(unname(palette.colors(4, palette = "Okabe-Ito"))[2:4], levels(top5$genre)),
  set_names("grey85", outside)
)

p <- ggplot(top5, aes(x = list, stratum = position, alluvium = album, y = 1, fill = genre)) +
  geom_alluvium(alpha = 0.6, width = 1/4, colour = "white", linewidth = 0.3) +
  geom_stratum(aes(fill = position), width = 1/4, colour = "white") +
  geom_text(stat = "alluvium", hjust = 1, nudge_x = -0.16, size = 3.4, na.rm = TRUE,
            aes(label = after_stat(if_else(x == 1, as.character(alluvium), NA)))) +
  geom_text(stat = "alluvium", hjust = 0, nudge_x = 0.16, size = 3.4, na.rm = TRUE,
            aes(label = after_stat(if_else(x == 3, as.character(alluvium), NA)))) +
  scale_x_discrete(expand = expansion(add = c(1.1, 1.1))) +
  scale_fill_manual(values = genre_cols, breaks = names(genre_cols)) +
  labs(
    title = "Genre of Rolling Stone's top five albums, 2003–2020",
    subtitle = "Each band is one album.\nAlbums with no genre in the data are labelled Rock/Pop (assumed).",
    x = "List",
    y = NULL,
    fill = NULL
  ) +
  theme_minimal(base_size = 13) +
  theme(axis.text.y = element_blank(), panel.grid = element_blank(),
        legend.position = "bottom") +
  guides(fill = guide_legend(nrow = 2))

ggsave("sessions/2026-10-16/figures/02-top5-genre-sankey.png", p, width = 9, height = 6, dpi = 150)
file.copy("sessions/2026-10-16/figures/02-top5-genre-sankey.png",
          "sessions/2026-10-16/figures/latest.png", overwrite = TRUE)
