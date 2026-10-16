# 2026-10-16 — Session 2: music sales and styles

## Dataset summary: Rolling Stone Album Rankings (TidyTuesday 2024-05-07)

Rolling Stone's "500 Greatest Albums of All Time" lists from **2003, 2012 and 2020**,
merged into one table by The Pudding for
[*What makes an album the greatest of all time?*](https://pudding.cool/2024/03/greatest-music/).
Cached at `data/tt-2024-05-07-rolling_stone.csv`; the
[source week](https://github.com/rfordatascience/tidytuesday/tree/main/data/2024/2024-05-07)
states no licence.

**Grain:** one row per album. 691 rows × 21 columns. An album appears once whichever
lists it was on.

**Overlap between lists:** 319 albums are in all three lists. 154 appear only in 2020
and 29 only in 2003. Each rank column is about 28% missing, because missing means "not
on that list". Ranks run from 1 to 500, with two ties in 2003 (at 314 and 493).

**Variables, in grammar terms:**

- **Ranks:** `rank_2003`, `rank_2012` and `rank_2020` are continuous, but 1 is best, so
  the scale must be reversed.
- **`differential`:** almost always 2003 rank minus 2020 rank, with a missing rank
  counted as 501. Kanye West's *My Beautiful Dark Twisted Fantasy* (+484) was new in
  2020. The −501 rows include albums on neither list. Treat it as derived, and
  recompute it if it's used.
- **Time:** `release_year` covers 1955–2019. There are also artist timing columns:
  `debut_album_release_year`, `years_between` (from debut to this album), and
  `ave_age_at_top_500`.
- **Chart success:** `peak_billboard_position` runs from 1 to 201, where 201 is a code
  for "never charted" (117 albums). `weeks_on_billboard` runs from 1 to 741 with a long
  right tail, and is 17% missing. `spotify_popularity` runs from 10 to 91.
- **Categories:**
  - `genre` has 16 levels and is 24% missing. One level is a misspelled duplicate:
    "Blues/Blues ROck".
  - `type` has 5 levels and is 88% Studio (608 of 691).
  - `artist_gender` has 3 levels: Male 522, Female 100, Male/Female 64.
  - `artist_member_count` is whole numbers from 1 to 12, which could be treated as
    discrete or continuous. That is a decision for the room.
- **Identifiers:** `album_id`, `album`, `spotify_url` and `sort_name`/`clean_name`
  (386 artists) are labels only.

**Mappings the data suggests (proposals, not choices):**

- A slope or bump chart of rank across the three lists (x = list year, y = reversed
  rank, one line per album). It has to handle albums that join or leave a list.
- Release year against 2020 rank, coloured by genre or gender, to see which eras the
  2020 voters rewarded.
- Critics against the market: peak Billboard position or weeks on the chart against
  rank. This needs a decision about the 201 code and whether to log weeks.
- Small multiples by `type` or `genre`.

**Notable rows:** *Sgt. Pepper's* went from 1st in 2003 and 2012 to 24th in 2020.
*What's Going On* rose from 6th to 1st, and Joni Mitchell's *Blue* from 30th to 3rd.
*Pet Sounds* was 2nd in all three lists.

**What it can't say:** these are critics' rankings, not sales or listening. For 2020, Rolling
Stone polled a new panel of voters, so a change in rank mixes changing taste with
changing voters. Billboard and Spotify figures are
US-centric, and Spotify popularity is a snapshot from when the data was collected.

Facilitator: Jon Minton. No consent record was taken, so no participant is named.

Grammar layer: **not fixed in advance**. The series arc puts *2. Geoms and stats* next. The room chose
Rolling Stone (2024-05-07), which stresses scales and position most.
Candidate datasets are in `shortlist.md`, all pre-cached in `data/`, each marked with the
layer it stresses best.

## Standing constraints

- **Vendor-neutral:** if both agents are in use, name them only as interchangeable
  examples. For a University-hosted session, mention ELM once.
- **The analyst decides** (AGENTS.md): the room makes every design decision, and gg-spec
  runs in interactive mode.
- **Recording and naming:** decide at the start. If recording, announce it and note the
  announcement here. Naming anyone on a later page needs `consent.md` to be filled in.
  Chatham House applies by default either way.

## Pre-flight

- [ ] `git pull`, then open the repo folder itself in Positron, so the skills load.
- [ ] `sh scripts/workshop preflight`.
- [ ] Each agent in use lists tt-fetch, gg-spec and dataset-scout.
- [ ] Shortlist data present: `ls data/tt-2025-08-26-* data/tt-2024-05-07-*
      data/tt-2020-09-29-* data/tt-2020-01-21-*`.
- [ ] Editor layout: left, the current spec YAML; right,
      `sessions/2026-10-16/figures/latest.png`. Terminal minimised.

## Live flow

1. The room picks from `shortlist.md`, or names any other TidyTuesday week.
2. **tt-fetch**: describe the chosen week, which is already cached. Read the grain,
   the types and the candidate aesthetics aloud. Also read the "can't say" line from
   the shortlist.
3. **gg-spec** (interactive): data and grain, then question, x and y, one further
   aesthetic, geom/stat, and render. The room then revises, for two or three rounds.
   Specs go in `specs/`, numbered.
4. Close with what the data can't say.

## Decisions and pain points (log live)

- Shortlist scouted on 2026-10-16. The brief was music sales or styles. TidyTuesday has
  no dedicated music-sales week; the only sales figures are in 2020-09-29's 48-row table.
- The room chose Rolling Stone Album Rankings (2024-05-07).
- Spec 01 (release year against 2020 rank) was proposed by the agent before the session.
- Figure 02 was requested by the facilitator: the genre of each list's top five as a
  Sankey-style chart. Five of the nine albums have no genre; the agent labelled them
  "Rock/Pop (assumed)". It needs `ggalluvial`, so it is a script, not a gg-spec YAML.
- Pain point caught by looking: `geom_flow()` and `stat = "alluvium"` labels sort lodes
  differently, so labels landed on the wrong ribbons with no warning. Fixed by drawing
  each album with `geom_alluvium()`.
