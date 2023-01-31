# Data

This folder contains the data collected via the online game [Unfun.me](http://unfun.me). The game as well as results are described in the [paper](https://dlab.epfl.ch/people/west/pub/West-Horvitz_AAAI-19.pdf):

> Robert West and Eric Horvitz: **Reverse-Engineering Satire, or “Paper on Computational Humor Accepted Despite Making Serious Advances”.** *Proceedings of the 33rd AAAI Conference on Artificial Intelligence,* 2019. 

When using this dataset, please cite the above paper. Here's a BibTeX entry you may use:

```
@inproceedings{west-horvitz-aaai2019-unfun,
  title={Reverse-Engineering Satire, or “Paper on Computational Humor Accepted Despite Making Serious Advances”},
  author={Robert West and Eric Horvitz},
  booktitle={Proceedings of the 33rd AAAI Conference on Artificial Intelligence},
  url={https://dlab.epfl.ch/people/west/pub/West-Horvitz_AAAI-19.pdf},
  year={2019}
}
```

Below, we describe each of the data files provided.


## unfun_YYYY-MM-DD.sql.gz

These files are complete database dumps of Unfun.me, for various dates:

- Version 1 (12 July 2018): [`unfun_2018-07-12.sql.gz`](unfun_2018-07-12.sql.gz)
- Version 2 (9 March 2020): [`unfun_2020-03-09.sql.gz`](unfun_2020-03-09.sql.gz)
- Version 2 - MySQL compatible (9 March 2020): [`unfun_2020-03-09-mysql_compatible.sql.gz`](unfun_2020-03-09-mysql_compatible.sql.gz)

Only the table of user profiles has been dropped, and IP addresses and user agent information has been salted and hashed.

These dumps have nearly all the information you will need, with these exceptions:
- The [chunked](https://web.archive.org/web/20190110112122/https://opennlp.apache.org/docs/1.9.1/manual/opennlp.html) versions of headlines from *The Onion* are available only in `headlines_for_game_ANALYZED_AUGMENTED_LOWERCASE_HEADLINESTYLE.tsv` (original, satirical headlines from *The Onion* only; unfunned versions are chunked on the fly in [`../code/R/analyze_unfun_data.Rmd`](../code/R/analyze_unfun_data.Rmd)).
- Script oppositions for pairs of satirical and similar-but-serious-looking headlines are available only in `pairs_editdist_1_SCRIPT-OPPOSITION.tsv`.

In what follows we briefly describe each table of the database.


### `batches`

Players of Unfun.me provide data in what we call "batches": In the "Real or Not?" task, players rate two headlines at a time, which in the database are grouped together in the same "batch". In the "Unfun the Headline!" task, users modify a single satirical headline, so each instance of a modified headline constitutes its own batch.

- `id`: unique batch id
- `uid`: id of the user who worked on this batch
- `date`: time at which the batch was generated and shown to the user
- `http_user_agent`: information about the user's browser software (salted and hashed)
- `ip_address`: user's IP address (salted and hashed)


### `headlines_original`

The set of serious and satirical headlines that serve as ground truth in the "Real or Not?" task.

- `id`: unique headline id
- `title`: headline text
- `truth_type`: whether this headline is `real` (i.e., serious) or `satirical`
- `domain`: domain of the website that published the headline
- `url`: URL of the news article with this headline
- `date`: time at which the article with this headline was published


### `headlines_original_NP_VP_NP_PP_NP`

Headlines of the most common chunk pattern NP VP NP PP NP (as determined by the [OpenNLP maximum-entropy chunker](https://web.archive.org/web/20190110112122/https://opennlp.apache.org/docs/1.9.1/manual/opennlp.html)).

- `headline_id`: id of the headline (refers to `id` in `headlines_original`)


### `headlines_unfunned`

Modified headlines collected via the "Unfun the Headline!" task.

- `id`: unique id for the modified headline
- `uid`: id of the user who modified the headline
- `batch_id`: id of the batch corresponding to this task instance (refers to `id` in `batches`)
- `original_headline_id`: id of the serious headline that was modified (refers to `id` in `headlines_original`)
- `title`: text of the headline after modification (`NULL` if the user did not submit a modified version, either because they clicked the skip button or because they stopped playing)
- `date`: time at which the task was generated and shown to the user
- `skip_button_clicked`: `1` if the user clicked the skip button (thus not providing a modified version of the headline), `NULL` otherwise


### `ratings`

Seriousness ratings collected via the "Real or Not?" task.

- `id`: unique id for the rating
- `uid`: id of the user who rated the headline
- `batch_id`: id of the batch corresponding to this task instance (refers to `id` in `batches`)
- `headline_id`: id of the headline that was rated (refers to `id` in `headlines_original` if `headline_type = 'original'`, and to `id` in `headlines_unfunned` if `headline_type = 'unfunned'`)
- `headline_type`: `original` if the rated headline came from a serious or satirical news outlet without modification; `unfunned` if the rated headline was produced via the "Unfun the Headline!" task
- `date`: time at which the task was generated and shown to the user
- `position`: we always show two headlines at a time to the user for rating, and this field shows whether the headline rated here appeared in the first or second position (`0` or `1`, respectively)
- `rating`: the rating given by the user via the slider bar; `0`: serious, `1`: satirical, `NULL`: no rating given (i.e., user stopped playing); note that, in the paper, the meaning of `0` and `1` is reversed for a more intuitive exposition


## headlines_for_game.tsv

Satirical headlines from *The Onion* that served has input for the "Unfun the Headline!" task. All the information of this file is also contained in the database dump.

Tab-separated columns:

- headline text
- type of headline (always `satirical`)
- domain of the website that published the headline (always `theonion.com`)
- URL of the news article with this headline
- time at which the article with this headline was published


## headlines_for_game_ANALYZED_AUGMENTED_LOWERCASE_HEADLINESTYLE.tsv

Chunked versions of the satirical headlines from headlines_for_game.tsv (chunked using the [OpenNLP maximum-entropy chunker](https://web.archive.org/web/20190110112122/https://opennlp.apache.org/docs/1.9.1/manual/opennlp.html)).

Tab-separated columns:

- headline text
- headline annotated with chunk tags ([description of tags](https://web.archive.org/web/20190110101722/https://www.ling.upenn.edu/courses/Fall_2003/ling001/penn_treebank_pos.html))
- sequence of chunk tags


## original_headlines_with_ratings.tsv

Data from the "Real or Not?" task: rated original headlines from *The Onion* as well as from serious outlets. All the information of this file is also contained in the database dump.

Tab-separated columns:

- id of the rated headline
- id of the user who provided the rating
- batch id: headlines rated by the same user in the same task share the same batch id; note that usually only one original headline is shown per batch (the second headline being a modified headline collected via the "Unfun the Headline!" task), but in the early stages of the game's history, there were not enough modified headlines, so we showed two original headlines instead
- position of the rated headline among the two headlines shown (`0` or `1`)
- rating given by the user; `0`: serious, `1`: satirical; note that, in the paper, the meaning of `0` and `1` is reversed for a more intuitive exposition
- headline text
- truth type: whether the headline was sourced from a serious news outlet (`real`) or from *The Onion* (`satirical`)
- domain of the website that published the headline


## pairs_with_ratings.tsv

Pairs of satirical and modified headlines, collected via the "Unfun the Headline!" task. All the information of this file is also contained in the database dump.

Tab-separated columns:

- id of the user who provided the modified headline
- id of the original, satirical headline
- id of the modified version of the headline
- text of the original, satirical headline
- text of the modified version of the headline
- rating obtained for the modified version of the headline via the "Real or Not?" task (`NULL` if no rating has been obtained for this modified version yet)


## pairs_editdist_1_SCRIPT-OPPOSITION.tsv

Pairs of satirical and similiar-but-serious-looking headlines whose only difference consists in one modified chunk (called "single-substitution pairs" in the paper), manually annotated with script oppositions. This file does not include unsuccessful pairs, where the humor was not successfully removed from the original satirical headlines even though the ratings would indicate success.

Tab-separated columns:

- original, satirical headline text (normalized, chunks separated by underscores)
- modified headline text (normalized, chunks separated by underscores)
- tag of the modified chunk ([description of tags](https://web.archive.org/web/20190110101722/https://www.ling.upenn.edu/courses/Fall_2003/ling001/penn_treebank_pos.html))
- text of modified chunk before modification
- text of modified chunk after modification
- ratings obtained in the "Real or Not?" task (multiple ratings separated by commas)
- mean rating
- abstract script oppositions (3 columns): for each of 'actual/non-actual', 'normal/abnormal', 'possible/impossible', `1` if the headline follows that abstract script opposition, empty otherwise
- concrete script oppositions (6 columns): for each of 'life/death', 'non-violence/violence', 'good/bad intentions', 'reasonable/absurd response', 'high/low stature', 'non-obscene/obscene', `1` (or in some cases a more precise label for the opposition) if the headline follows that concrete script opposition, empty otherwise
- flag marking headlines where manual inspection revealed that the humor was not successfully removed from the original headline, even though the ratings indicate otherwise
- flag marking original satirical headlines that were not obviously humorous without additional context


## en-chunker_AUGMENTED_LOWERCASE_HEADLINESTYLE.bin

OpenNLP chunker model retrained in order to be able to deal with pithy, headline-style text.
Produced by `../code/bash/retrain_chunking_model.sh`; used by `../code/perl/chunk_headlines.pl`.
