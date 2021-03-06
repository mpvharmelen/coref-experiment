# coref-experiment
This collection of bash scripts can be used to run a coreference resolution experiment using the code from [coref_draft][], [naf2conll][] and the reference [CoNLL scorer][].

By default the coreference resolution system is instructed to keep singleton references (if supported).
Look for the `-s` option in `...-args.txt` files in the `config` directory to see when this is the case.

# Requirements
These scripts require the following programs:

 - git (to download the necessary repositories)
 - virtualenv (to create the virtual environments)
 - python3 (to run experiment code)
 - perl (to run the evaluation)

# Usage
Have a look at `Directory Configuration` in `src/shared_constants.sh` and
make sure they point to the correct locations:

 - `expdir` main working directory.
   All environments,
   downloaded code,
   logs,
   and output
   will be saved here by default.
 - `configdir` directory with configuration files. By default it points to the `config` directory of this repository.
 - `indir` directory with input files in NAF format
 - `golddir` directory with gold data in CoNLL format

Choose a tag from one of the [releases][] (or anything else that `git checkout` will understand, e.g. the name of a branch or the hash of a commit) and run:

```bash
src/run.sh <tag>
```
If all goes well, everything needed is downloaded automatically.

You can run separate parts of the experiment manually by calling the script that does it.

# Data Selection
`$allfiles` in `collect_data.sh` determines which files are considered as input data. By default a development set of 103 random files from SoNar-1 are used, but you can use all data by commenting the lines with the 103 files and uncommenting the following line:

    allfiles=`ls "$indir"`


# What it does
Every script `source`s `shared_constants.sh` for the configuration and `run.sh` orchestrates everything. If the output directory does not exist, `run.sh` creates it and otherwise exits to prevent overwriting a previous experiment. Then it calls the following scripts in the order listed:

 1. `create_environment.sh` verifies the tag, downloads all the necessary code and creates the necessary virtual environments:
     + environment for [coref_draft][] that implicitly downloads the code from Github
     + code and environment for [naf2conll][]
     + code for the [CoNLL scorer][]
 1. `collect_data.sh` finds the NAF files in `$indir` that can be used for the experiment and collects the gold data from `$conlldir` in a single file `$goldfile`. Skipped files are reported in `$skippedfileslog` and the files to be used for the experiment are saved in `$infileslog`. Those files:
     + are not listed in `$ignoredfiles` in `shared_constants.sh`
     + exist and are not empty
     + have a corresponding gold file that exists and is not empty
 1. `experiment_only.sh` reads the NAF files from `$infileslog` and
    runs [coref_draft][] (with command line arguments from `$msc_args_file`)
    and [naf2conll][] (with configuration file `$naf2conllconfig`)
    on each of them.
    The output NAF files are saved in `$nafdir`
    and the converted CoNLL files are saved in `$conlldir`.
 1. if `$verifygold` is `yes`, `verify_gold.sh` is invoked to run the [CoNLL scorer][] with the gold data as both gold and system response.
    If there are documents that do not score 100%, they are reported and the experiment is stopped.
    By default `$verifygold` is `no`, but all documents that are not in `$ignoredfiles` in `shared_constants.sh` have been verified.
 1. `aggregate_output.sh` copies the content of all files in `$conlldir` into a single file `$outfile`.
 1. `evaluate.sh` runs the [CoNLL scorer][] and saves the output to `$resultsfile`.
 1. `results_to_markdown.py` summarizes the results in a nice Markdown table.

[coref_draft]: https://www.github.com/mpvharmelen/coref_draft.git
[naf2conll]: https://www.github.com/cltl/FormatConversions.git
[CoNLL scorer]: https://www.github.com/conll/reference-coreference-scorers.git
[releases]: https://github.com/mpvharmelen/coref_draft/releases
