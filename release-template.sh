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
