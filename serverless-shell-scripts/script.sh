# Replace [BUCKET NAME] below with the name of your Google Cloud Storage bucket.
#!/bin/bash
gcloud container images list --repository=gcr.io/global-mobility-services > f.txt
m=$(cut -d "/" -f 3 f.txt)

for f in $m
do
main(){
  date=$(date --date='-21 day' +%Y-%m-%d)
  local C=0
  for digest in $(gcloud container images list-tags gcr.io/global-mobility-services/$f --sort-by=TIMESTAMP \
    --filter "NOT tags:master AND NOT tags:staging AND NOT tags:latest AND NOT tags:dev AND NOT tags:dev-master AND NOT tags:prod-master AND timestamp.datetime < '$date'" --format='get(digest)'); do
    (
      set -x
      gcloud container images delete -q --force-delete-tags "gcr.io/global-mobility-services/$f@${digest}"
    )
    let C=C+1
  done
  echo "Deleted ${C} images in $f" >&2
}
main "gcr.io/global-mobility-services/$f" "$date"

done