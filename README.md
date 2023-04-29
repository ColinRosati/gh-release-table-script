# gh-release-table-script
Helper script to create a table with all contributors

## Problem
In my company our release process we have a pain point of QA'ing PRs included in a release. To QA we want to distribute a table of PRs to QA to non-technical people. Creating this table was a time consuming and error prone task.

## Solution
Create a helper script which automates creating a table used for QA purposes

## Dependencies
This script uses [gh cli](https://cli.github.com/)

## Table with Title Author & URL

Use this bash script to generate a table with title,m author and PR url in table. This script writes a release.tsv file

### Steps:

1. Copy bash script into file release-template.sh

2. Make file executable chmod +x release-template.sh

3. Execute script  release-template.sh

```
#!/bin/bash

get_url_by_pr_number(){
    echo | gh pr view $1 --json url --jq '.url'
}

# clear any previous file data
echo "" > release.tsv

# fetch staging PR commits and iterate over
# use jq and format table with title, author, pr number
# URL is constructed from PR number but has to make a seperate call to gh api to explicity get the URL
gh pr list --search "Staging Deployment" --json "commits" --jq ' "title\tAuthor\tURL",(.[].commits.[] | "\(.messageHeadline)\t\(.authors.[].name)\t#\(.messageHeadline | match("#([1-9]+)").captures[].string)" )' |
while read -r column; do
    # regex to find PR number from column input
    REGEX_FIND_NUMBER="#([0-9]+)"

    if [[ $column =~ $REGEX_FIND_NUMBER ]]; then
        # call get_url_by_pr_number with PR matched (with no # in number) URL
        url=$(get_url_by_pr_number ${BASH_REMATCH[1]})

        # append line into to column
        echo "$column $url" >> release.tsv
    else
        # append line into to column this is the first row with header
        echo "$column" >> release.tsv
    fi;
done
```


### Output

| Title | Author | Url |
| --- | --- | --- |
| Feat: Something cool | Paul Staments | https:www.github.com/repo/pr-123
| Bug: Fix nav | Michael Burnham | https:www.github.com/repo/pr-124
