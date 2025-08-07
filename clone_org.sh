#!/usr/bin/env bash

# This script depends on jq, curl and git
#   sudo apt-get install -y jq curl git
# It accepts two positional arguments, github org and github token
#   eg invocation: ./clone_org.sh <org> <gh_token>

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BOLD_NORMAL='\033[1;39m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_RED='\033[1;31m'
END='\033[0m' # No Color

org=$1
token=$2
s3_bucket=$3

fetch_and_clone () {
  local url=$1

  echo "Fetching repos from ${url}"

  {
    curl -H "Authorization: token ${token}" -s --dump-header /dev/stderr -X GET ${url} 2>&3 | jq -r '.[].full_name' | \
    while read repo_name; do
      echo -e "${BOLD_NORMAL}$(printf '%-10s' Start:)"$(printf "%-100s\n" "${repo_name}" | tr " " -)"${END}"
      mkdir -p ${repo_name}
      pushd ${repo_name}
      git init
      git pull "https://${token}@github.com/${repo_name}.git"
      success=$?
      popd
      if [ ${success} -eq 0 ]; then
        echo -e "${BOLD_GREEN}$(printf "%-10s"  "Success:")"$(printf "%-100s" "${repo_name}" | tr " " -)"${END}"
      else
        echo -e "${BOLD_RED}$(printf "%-10s"  "Failure:")"$(printf "%-100s" "${repo_name}" | tr " " -)"${END}"
      fi
    done
  } \
  3>&1 1>&2 | grep -Po '(?<=Link:\s<)[^>]+(?=>;\s*rel="next")' | \
  while read link; do
    echo Found next link ${link}
    fetch_and_clone ${link}
  done
}

date_suffix=$(date +%s)
url="https://api.github.com/orgs/${org}/repos?per_page=100"
tmp_path="/tmp/${org}-gh-archive-${date_suffix}"
archive_name="${org}-gh-archive-${date_suffix}.tar.gz"

echo "Cloning repos to ${tmp_path}"

mkdir "${tmp_path}"
pushd "${tmp_path}"

fetch_and_clone ${url}

echo "Archiving repos to ./${archive_name}"
tar czvf "../${archive_name}" .

if [[ ! -z "${s3_bucket}" ]]; then
  echo "Sending archive ${archive_name} to s3 bucket ${s3_bucket}"
  aws s3 cp "../${archive_name}" "${s3_bucket}"

  rm -rf "/tmp/${archive_name}"
fi

rm -rf "${tmp_path}"

popd

