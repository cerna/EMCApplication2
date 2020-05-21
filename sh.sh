#!/bin/bash
set -e

CONTROL="{\"branches\":[{\"local\":\"linuxcnc/master\",\"remote\":\"master\"}
                        ]}"

printf "$CONTROL" | jq -e '.'

LENGTH=$(printf "$CONTROL" | jq -e '.branches | length')
echo "$LENGTH"
ARRAY=()
for (( i=0; i < ${LENGTH}; i++ ))
do
    LOCAL_NAME=$(printf "$CONTROL" | \
        jq -e -r --arg I $i '.branches[$I|tonumber] | .local')
    LOCAL_REV=$(git rev-parse refs/remotes/origin/${LOCAL_NAME})
    REMOTE_REV=$(git rev-parse refs/remotes/upstream/${LOCAL_NAME})
    echo "$LOCAL_REV $REMOTE_REV"
    if [[ "$LOCAL_REV" != "$REMOTE_REV" ]]
    then
      printf "HEAD commits for $LOCAL_NAME not the same\n"
      ARRAY+=("$LOCAL_NAME")
    else
      printf "No difference in commits for $LOCAL_NAME found\n"
    fi
done
if (( ${#ARRAY[@]} > 0 ))
then
    echo "Yay"
    JSON=$(printf '%s\n' "${ARRAY[@]}" | jq -R . | jq -s '{local_names: .}')
else
    echo "nay"
fi

printf "$JSON" | jq '.'

for (( i=0; i < ${LENGTH}; i++ ))
do
    LOCAL_NAME=$(printf "$CONTROL" | \
        jq -e -r --arg I $i '.branches[$I|tonumber] | .local')
    LOCAL_REV=$(git rev-parse refs/remotes/origin/${LOCAL_NAME})
    REMOTE_REV=$(git rev-parse refs/remotes/upstream/${LOCAL_NAME})
    echo "$LOCAL_REV $REMOTE_REV"
    if git merge-base --is-ancestor ${LOCAL_REV} ${REMOTE_REV}
    then
      echo "Can be fast forwarded"
    else
      echo "Cannot be fast-forwarded"
    fi
done