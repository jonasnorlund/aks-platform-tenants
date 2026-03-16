# ./storage.sh cvbn1234 stg4tenants1234 rg-ninja-dev-01 nonprod-01-se
echo "name: $1"
echo "az-storage-account: $2"
echo "az-storage-account-rg: $3"
echo "cluster: $4"
echo "umi-kublet: $5"

destination="clusters/$4/$1"
echo "$destination"

cp templates/persistent-volume-template.yaml "$destination/persistent-volume.yaml"
cp templates/persistent-volume-claim-template.yaml "$destination/persistent-volume-claim.yaml"

# Persistent Volume
yq e -i '.metadata.name = "pv-'$1'"' $destination/persistent-volume.yaml
yq e -i '.spec.csi.volumeHandle = "pv-'$1'"' $destination/persistent-volume.yaml
yq e -i '.spec.csi.volumeAttributes.storageAccount = "'$2'.file.core.windows.net"' $destination/persistent-volume.yaml
yq e -i '.spec.csi.volumeAttributes.resourceGroup = "'$3'"' $destination/persistent-volume.yaml
yq e -i '.spec.csi.volumeAttributes.shareName = "fs-'$1'"' $destination/persistent-volume.yaml
yq e -i '.spec.csi.volumeAttributes.clientID = "'$5'"' $destination/persistent-volume.yaml


# Persistent Volume Claim
yq e -i '.metadata.name = "pvc-'$1'"' $destination/persistent-volume-claim.yaml
yq e -i '.metadata.namespace = "ns-'$1'"' $destination/persistent-volume-claim.yaml
yq e -i '.spec.volumeName = "pv-'$1'"' $destination/persistent-volume-claim.yaml


git add .
if git diff --staged --quiet; then
  echo "No changes to commit"
else
  echo "Changes detected, committing..."
  git commit -m "Storage added for $1."
  git push origin main
fi

