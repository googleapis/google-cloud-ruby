
CHANGED_DIRS="$(git --no-pager diff --name-only HEAD $(git merge-base HEAD master) | grep "/" | cut -d/ -f1 | sort | uniq || true)"

GEMSPECS=($(git ls-files -- */*.gemspec | cut -d/ -f1))
UPDATED_GEMS=()

for i in "${GEMSPECS[@]}"; do
    for j in "${CHANGED_DIRS[@]}"; do
        if [ $i = $j ]; then
            UPDATED_GEMS += $i
        fi
    done
done


echo $UPDATED_GEMS