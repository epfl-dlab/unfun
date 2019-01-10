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

Most important, we publish the full database dump of Unfun.me (as of July 12, 2018):
- [`data/unfun_2018-07-12.sql.gz`](data/unfun_2018-07-12.sql.gz)

We also release R code for reproducing all results (incl. plots and tables) of the paper:
- [`code/R/analyze_unfun_data.html`](code/R/analyze_unfun_data.html)

The above R script doesn't work with the raw database dump, but with data files derived from the dump, which can also be found in the [`data/`](data) folder. All data files (incl. the full database dump) are described here:
- [`data/README.md`](data/README.md)

Code for chunking headlines using the [OpenNLP maximum-entropy chunker](https://web.archive.org/web/20190110112122/https://opennlp.apache.org/docs/1.9.1/manual/opennlp.html) is also available:
- [`code/perl/chunk_headlines.pl`](code/perl/chunk_headlines.pl)
