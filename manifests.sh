# ./generate.sh ghij1234 e560a3b9-df9f-4ed8-80c7-a6a517d84b91 jonasnorlund/vcrs-aks-sample1 k8s SECRET nonprod-01-se

echo "name: $1"
echo "groupid: $2"
echo "gh_repo: $3"
echo "gh_repo_path: $4"
echo "gh_auth: $5"
echo "cluster: $6"

destination="clusters/$6/$1"
mkdir -p $destination

cp templates/argocd-application-template.yaml "$destination/application.yaml"
cp templates/argocd-project-template.yaml "$destination/project.yaml"
cp templates/argocd-repository-template.yaml "$destination/repository.yaml"
cp templates/networkpolicy-template.yaml "$destination/networkpolicy.yaml"


# Application
yq e -i '.metadata.name = "'$1'"' $destination/application.yaml
yq e -i '.metadata.namespace = "ns-'$1'"' $destination/application.yaml
yq e -i '.spec.project = "p-'$1'"' $destination/application.yaml
yq e -i '.spec.source.repoURL = "https://github.com/'$3'"' $destination/application.yaml
yq e -i '.spec.source.path = "'$4'"' $destination/application.yaml
yq e -i '.spec.destination.namespace = "ns-'$1'"' $destination/application.yaml
yq e -i '.spec.destination.name = "'$6'"' $destination/application.yaml

# Repository
yq e -i '.metadata.name = "repo-'$1'"' $destination/repository.yaml
yq e -i '.stringData.url = "https://github.com/'$3'"' $destination/repository.yaml
yq e -i '.stringData.password = "'$5'"' $destination/repository.yaml
yq e -i '.stringData.project = "p-'$1'"' $destination/repository.yaml

# Project
yq e -i '.metadata.name = "p-'$1'"' $destination/project.yaml
yq e -i '.spec.sourceRepos[0] = "https://github.com/'$3'"' $destination/project.yaml
yq e -i '.spec.destinations[0].namespace = "ns-'$1'"' $destination/project.yaml
yq e -i '.spec.destinations[0].name = "'$6'"' $destination/project.yaml
yq e -i '.spec.roles[0].groups[0] = "'$2'"' $destination/project.yaml
yq e -i '.spec.sourceNamespaces[0] = "ns-'$1'"' $destination/project.yaml 
yq eval '(.spec.roles[].policies[]) |= sub("IDSTRING", "'$1'")' -i $destination/project.yaml

# NetworkPolicy
yq e -i '.metadata.namespace = "ns-'$1'"' $destination/networkpolicy.yaml
yq e -i '.metadata.name = "np-'$1'"' $destination/networkpolicy.yaml