#!/bin/bash

set -e

MSGERROR=""
export HGENCODING=utf8

if [[ "$1" == prepare ]]; then

  rm -rf /hg-repositories/{,tmp.}hg.authors.map
  rm -rf /hg-repositories/*.hg.branches.map
  rm -rf /hg-repositories/*.hg.tags.map

  for hg_repo in /hg-repositories/*/ ; do
    echo "Preparing: $hg_repo"
    cd $hg_repo
    hg log | grep user: | sed 's/user: *//' >> /hg-repositories/tmp.hg.authors.map

    # Branches list
    hg branches -c | awk '{print $1}' | sort > ../${PWD##*/}.tmp.hg.branches.map
    while read -r line
    do
      echo "\"$line\"=\"$line\"" >> ../${PWD##*/}.hg.branches.map
    done < ../${PWD##*/}.tmp.hg.branches.map
    rm ../${PWD##*/}.tmp.hg.branches.map

    # Tags list
    hg tags | awk '{print $1}' | sort > ../${PWD##*/}.tmp.hg.tags.map
    while read -r line
    do
      echo "\"$line\"=\"$line\"" >> ../${PWD##*/}.hg.tags.map
    done < ../${PWD##*/}.tmp.hg.tags.map
    rm ../${PWD##*/}.tmp.hg.tags.map

  done

  sort -u -o /hg-repositories/tmp.hg.authors.map /hg-repositories/tmp.hg.authors.map
  while read -r line
  do
    echo "\"$line\"=\"$line\"" >> /hg-repositories/hg.authors.map
  done < /hg-repositories/tmp.hg.authors.map | sort | uniq
  rm /hg-repositories/tmp.hg.authors.map

  exit 0
fi;

if [[ "$1" == migrate ]]; then
  echo "Migrating from mercurial to git..."

  for hg_repo in /hg-repositories/*/ ; do
    echo "Processing: $hg_repo"
    cd $hg_repo

    PROJECT_NAME=${PWD##*/}
    PARAM=

    # Tags param
    if [ -s ../${PROJECT_NAME}.hg.tags.map ]; then
      PARAM="-T /hg-repositories/${PROJECT_NAME}.hg.tags.map"
    fi;

    # Branches param
    if [ -s ../${PROJECT_NAME}.hg.branches.map ]; then
      PARAM="$PARAM -B /hg-repositories/${PROJECT_NAME}.hg.branches.map"
    fi;

    # Authors param
    if [ -s /hg-repositories/hg.authors.map ]; then
      PARAM="$PARAM -A /hg-repositories/hg.authors.map"
    fi;

    rm -rf /git-repositories/$PROJECT_NAME
    mkdir /git-repositories/$PROJECT_NAME
    git init /git-repositories/$PROJECT_NAME
    cd /git-repositories/$PROJECT_NAME
    git config core.ignoreCase false

    OUTFILE=/git-repositories/$PROJECT_NAME.log
    PARAM="-r $hg_repo --force $PARAM"
    /opt/fast-export/hg-fast-export.sh $PARAM 2>&1 | tee "$OUTFILE"

    if fgrep "Error:
Fatal:" "$OUTFILE" > /dev/null 2>&1
    then
        MSGERROR="$MSGERROR
**** ERROR ON FILE $OUTFILE - Please verify ****"
    fi
    
  done

  #	Show errors
  if [ -n "$MSGERROR" ]
  then
      echo "$MSGERROR"
  fi

  exit 0
fi;

if [[ "$1" == *bash ]]; then
  /bin/bash
  exit 0
fi;

echo ""
echo "usage: docker run \\"
echo "--volume [/your/hg/repositories/path/]:/hg-repositories \\"
echo "--volume [/your/empty/output/folder/]:/git-repositories \\"
echo "ralexsander/hg-git-migration [prepare,migrate,bash] "
echo ""
echo "Options available are:";
echo ""
echo "prepare = Creates a list of Branches, Tags and Authors."
echo "migrate = Perform the migration."
echo "bash = Bash session for debuging."
exit 0
