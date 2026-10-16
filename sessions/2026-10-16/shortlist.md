# Shortlist — 2026-10-16, music sales and styles

The brief was TidyTuesday weeks on music sales or musical styles. Four weeks are
pre-cached in `data/` so the session doesn't depend on venue wifi. Dates were checked
against the `rfordatascience/tidytuesday` year indexes on 2026-10-16. The room may pick
**any other week** live (`sh scripts/workshop r scripts/tt_fetch.R YYYY-MM-DD`).

**About sales:** no TidyTuesday week is a music-sales dataset. The only sales figures
are in the 48-row side table of the Beyoncé and Taylor Swift week. The other weeks
measure success by chart position, weeks on the chart, critics' ranks, or Spotify
popularity, and those are proxies for sales.

| Week | What it is | Grammar decisions it provokes | Rows × cols | Source / licence | Cached files |
|---|---|---|---|---|---|
| [2025-08-26](https://github.com/rfordatascience/tidytuesday/tree/main/data/2025/2025-08-26) Billboard Hot 100 Number Ones | Every US #1 single from Aug 1958 to Jan 2025, hand-coded by one listener: genre and sub-genre, key, BPM, length, 54 yes/no columns for instruments and features (banjo, cowbell, fade-out …), lyrical topic, and who wrote and produced it. | **Geoms and stats.** Song length or BPM over 66 years needs points plus a smoother, or a distribution per decade. The instrument columns are 54 values of one variable, so pivot longer before mapping; the plotted value is then a proportion per decade. Genre (`cdr_genre`) can hold several values ("Rock;Funk/Soul"), so the group must decide how to split it before mapping. | 1,177 × 105 | Chris Dalla Riva's [Billboard #1s database](https://docs.google.com/spreadsheets/d/1j1AUgtMnjpFTz54UdXgCKZ1i4bNxFjf01ImJ-BqBEt0/), compiled for *Uncharted Territory*. No licence stated. | `tt-2025-08-26-billboard.csv` (2.3 MB), `tt-2025-08-26-topics.csv`, readme |
| [2024-05-07](https://github.com/rfordatascience/tidytuesday/tree/main/data/2024/2024-05-07) Rolling Stone Album Rankings | 691 albums that appeared in Rolling Stone's "500 Greatest Albums" list in 2003, 2012 or 2020, with genre, release year, weeks on the Billboard 200, peak position and Spotify popularity. | **Scales and position.** Rank 1 is best, so the axis must be reversed. Peak position 201 is a code for "never charted". Weeks on the chart run from 1 to 741 with a long right tail, which raises whether to log the axis. Three list years suggest a slope chart from 2003 to 2020, and albums that drop off a list are missing values, not zeros. | 691 × 21 | The Pudding, [*What makes an album the greatest of all time?*](https://pudding.cool/2024/03/greatest-music/), from Chris Eckert's spreadsheet. No licence stated. | `tt-2024-05-07-rolling_stone.csv` (0.1 MB), readme |
| [2020-09-29](https://github.com/rfordatascience/tidytuesday/tree/main/data/2020/2020-09-29) Beyoncé and Taylor Swift | **Sales:** copies sold for each album and country, 48 rows covering 14 albums. **Charts:** each album's peak position in 10 national charts. Large lyrics tables are included too. | **Scales.** Sales run from 5,700 to 12,000,000, more than three orders of magnitude, so a linear axis hides most countries. The worldwide rows ("WW"/"World") already include the country rows, a part–whole trap for stacking. Country codes are inconsistent ("FRA"/"FR"). The readme says "dollars", but the values look like copies sold. | sales 48 × 8; charts 140 × 8 | Compiled by Rosie Baillie and Sara Stoudt from Billboard and Wikipedia. No licence stated. | `tt-2020-09-29-sales.csv`, `-charts.csv`, `-beyonce_lyrics.csv` (2.0 MB), `-taylor_swift_lyrics.csv`, readme |
| [2020-01-21](https://github.com/rfordatascience/tidytuesday/tree/main/data/2020/2020-01-21) Spotify Songs | About 28,000 tracks from Spotify playlists in 6 genres and 24 sub-genres, with audio features (danceability, energy, valence, tempo …) and popularity. Release dates run from 1957 to 2020. | **Facets and stats.** The 6 genres are similar in size (4,951 to 6,043 rows each), which makes them a clean facet. 32,833 points overplot, so the room has to choose between alpha, 2D bins and densities. A trap about what one row is: the 32,833 rows hold only 28,356 distinct tracks, and 1,687 tracks sit in more than one genre. | 32,833 × 23 | `spotifyr` pull by [Kaylin Pavlik](https://www.kaylinpavlik.com/classifying-songs-genres/). Spotify API terms; no licence stated. | `tt-2020-01-21-spotify_songs.csv` (7.6 MB), readme |

All cached CSVs are under the 20 MB ceiling; the largest is 7.6 MB. **None of these
weeks states a licence.** That is common for music data, which is mostly scraped or
compiled by hand. They are fine as live teaching material with the source cited.
Check the source before republishing derived data on a writeup page. Data files are
cached locally and not yet committed. Commit only the week the room chooses.

## Considered, not shortlisted

- [2021-09-14](https://github.com/rfordatascience/tidytuesday/tree/main/data/2021/2021-09-14)
  Billboard Top 100, weekly 1958–2021, with Spotify audio features. `billboard.csv` is
  46 MB, over the 20 MB ceiling. 2025-08-26 covers the same questions at #1 level.
- [2022-05-17](https://github.com/rfordatascience/tidytuesday/tree/main/data/2022/2022-05-17)
  Eurovision results and country-to-country votes. Good for tiles and networks, but
  it's about contests, not sales or styles.
- [2020-04-14](https://github.com/rfordatascience/tidytuesday/tree/main/data/2020/2020-04-14)
  BBC critics' poll of hip-hop tracks. Small (311 songs) and a single genre.
- [2023-10-17](https://github.com/rfordatascience/tidytuesday/tree/main/data/2023/2023-10-17)
  Taylor Swift albums and tracks. One artist, 274 tracks; the 2020-09-29 week
  includes the sales data.
- [2026-08-25](https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-08-25)
  Country music lyrics and writers. Mostly text, so it's a tidytext session more than a
  grammar one.
- [2019-12-24](https://github.com/rfordatascience/tidytuesday/tree/main/data/2019/2019-12-24)
  Christmas songs on the Billboard Hot 100. Seasonal and thin.

## What the data can't say (one line each, for the describe step)

- **Billboard #1s:** only the songs that reached #1, so it says nothing about what failed.
  Genre, topic and instrument codes are one listener's judgement, and audio features come
  from Spotify's models.
- **Rolling Stone:** critics' rankings, not sales. The voter pool changed between lists,
  so a moving rank mixes changing taste with changing voters. "201" is a code for "never
  charted", not a position.
- **Sales:** two artists, with whichever countries the source happened to report for each
  album. Totals are not comparable across countries or eras, and *Folklore* has no sales row.
- **Spotify:** genre belongs to the playlist, not the track, and the playlists came from
  one analyst's search terms. Popularity is a snapshot from January 2020.
