# Unfun.me

This repository contains data and code for the following [paper](https://dlab.epfl.ch/people/west/pub/West-Horvitz_AAAI-19.pdf), which describes the online game [Unfun.me](http://unfun.me):

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

Most important, we publish full database dumps of Unfun.me:
- Version 1 (12 July 2018): [`data/unfun_2018-07-12.sql.gz`](data/unfun_2018-07-12.sql.gz)
- Version 2 (9 March 2020): [`data/unfun_2020-03-09.sql.gz`](data/unfun_2020-03-09.sql.gz)
- Version 3 (2 February 2023): [`data/unfun_2023-02-02.sql.gz`](data/unfun_2023-02-02.sql.gz)

We also release R code for reproducing all results (incl. plots and tables) of the paper:
- [`code/R/analyze_unfun_data.Rmd`](code/R/analyze_unfun_data.Rmd)
- A [rendered version](https://epfl-dlab.github.io/unfun/code/R/analyze_unfun_data.html) of the above script
<!-- Here's how to make the GitHub Pages version: https://stackoverflow.com/a/8446391 -->

The above R script doesn't work with the raw database dump, but with data files derived from the dump, which can also be found in the [`data/`](data) folder. All data files (incl. the full database dump) are described here:
- [`data/README.md`](data/README.md)

Code for chunking headlines using the [OpenNLP maximum-entropy chunker](https://web.archive.org/web/20190110112122/https://opennlp.apache.org/docs/1.9.1/manual/opennlp.html) is also available:
- [`code/perl/chunk_headlines.pl`](code/perl/chunk_headlines.pl)
 