Project 17. main-terraform-project17-iac-vprofile local workspace, terraform-project17-iac-vprofile remote github repo

THere are two terraform branches in this workspace, a staging branch (stage) and a main branch.
The .github workflow steps are such that only the terraform validate, terraform, validate, terraform plan, etc are 
executed with a push from local to remote on stage branch.   The other steps consist of the following

terraform apply (this will only be executed with a push from remote main): this will create the VPC, NAT gw, EKS cluster, etc on AWS2 account infra.
AWS credentials (basically aws configure in the github runner that is executing the script)  (this is executed by either push to stage or main)
kubeconfig file fetch from EKS cluster to the github runner. This is only exxecuted with push from local to main
kubectl apply for the nginx deployment (yaml) onto the existing EKS cluster on AWS2. This is only executed with push from local to main

In reality there is the QA testing during the staging, prior to the merge of main <----stage

The manual staging for now is
git checkout stage (local)
git push origin stage (this will run pre-emptive checks on terraform scripts)
QA testing would follow here
git checkout main (local)
git merge stage   This will merge the staged code changes into the main local branch
git push origin main  This will finally terraform apply, aws configure, kubeconfig get onto runner and kubectl the nginix onto the existing EKS cluster.

In reality, once staging is complete, would create a pull request in the github repo for main <----- stage merge and compare the commits, etc.
If able to merge would then merge the code here.
Then on local workspace can do a git pull from remote to local on main branch to synch up the local main branch. (but this is not required as main local will be periodically synched up with the staging branch for latest changes; better to just do another git merge stage in the main local branch to synch it up with staging changes.)


The second local workspace is application-code-project17-vprofile-action and the remote for this is application-code-project17-vprofile-action. This is for the applicaton deployment onto the EKS frontend server 
See the README for that repository.



# Terraform code 

## Maintain vpc & eks with terraform for vprofile project

## Tools required
Terraform version 1.6.3

### Steps
* terraform init
* terraform fmt -check
* terraform validate
* terraform plan -out planfile
* terraform apply -auto-approve -input=false -parallelism=1 planfile
####
#####
