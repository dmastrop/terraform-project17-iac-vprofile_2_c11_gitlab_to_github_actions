Project 17. main-terraform-project17-iac-vprofile local workspace, terraform-project17-iac-vprofile remote github repo


# Basic process flow

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



# Terraform destroy

the scripts for this are not complete yet.  For now do the following:

in a new terminal
export AWS_PROIFLE=project17-k8s-EKS-user



confirm with aws configure list;

% aws configure list
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile   project17-k8s-EKS-user              env    ['AWS_PROFILE', 'AWS_DEFAULT_PROFILE']
access_key     ******************** shared-credentials-file    
secret_key     ******************** shared-credentials-file    
    region                us-east-1      config-file    ~/.aws/config


next, set KUBECONFIG so that exisitng ~/.kube/config is not overwritten

export KUBECONFIG=(path to kubeconfig for this project)
echo $KUBECONFIG


Next, execute the following to pull the .kube/config off of the controller on the deployed EKS cluster
aws eks update-kubeconfig --region us-east-1 --name project17-eks-vprofile


test with 
kubectl get nodes
kubectl get pods -n ingress-nginx
kubectl get ns
kubectl get service -n ingress-nginx
kubectl get pods -n kube-system
etc.....


Delete the nginx controller
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.3/deploy/static/provider/aws/deploy.yaml

cd into /terraform directory

in terraform.tf change required_version temporarily to 1.5.1
  required_version = "~> 1.5.1"

download the s3 bucket file in terraform-state-project17-vprofile-gitops for backup

do the terraform init
terraform init -backend-config="bucket=terraform-state-project17-vprofile-gitops"

do the terraform destroy

revert the 1.5.1 back to 1.6.6 for the required_version in terraform.tf file



# to view the node and pod information in AWS console with root user, do the following (otherwise this information is not shown)

Step1:
First as shown in video create a new token access key and secret for the IAM user that was used to create the EKS cluster (it must be the same user that you configured in the Github secrets, but can be new keys.  If you try to use a different IAM user even with Admin access this will fail.)

verify the new key with "aws configure list" in the terminal

Step2:
what i do in this terminal is use KUBECONFIG variable and export a new path to the kubeconfig file because I don't want to overwrite my existing .kube/config file that is using docker k8s.   

export KUBECONFIG=(new path to .kube/config file)

Note you must have a dummy config file (zero bytes is fine) for this to work. It will fill it in with the .kube/config file from the controller node in the cluster, once you run step3 below

Step3:  fill in the AWS_REGION and EKS_CLUSTER as indicated in the video for your setup
1.	aws eks update-kubeconfig --region ${{ env.AWS_REGION }} --name ${{ env.EKS_CLUSTER }}

Step4:
verify kubectl is working by running a simple kubectl get nodes


Step5:
Next run this command to edit the configmap on the k8s controller in the EKS cluster


kubectl edit configmap aws-auth -n kube-system


This will open a vi editor.  


Step6:  Add the following line below using your specific account ID (12 digit account id in upper right corner when you are logged into AWS web console)

1.	  mapUsers: "- groups: \n  - system:masters\n  userarn: arn:aws:iam::671177010163:root\n"

the complete file will look something similar to this, but the only line added is this mapUsers line
Make sure it is at the same indentation as mapRoles
1.	apiVersion: v1
2.	data:
3.	  mapRoles: |
4.	    - groups:
5.	      - system:bootstrappers
6.	      - system:nodes
7.	      rolearn: arn:aws:iam::671177010163:role/eksctl-manu-eks-new2-nodegroup-ng-NodeInstanceRole-1NYUHVMYFP2TK
8.	      username: system:node:{{EC2PrivateDNSName}}
9.	  mapUsers: "- groups: \n  - system:masters\n  userarn: arn:aws:iam::671177010163:root\n"
10.	kind: ConfigMap
11.	metadata:
12.	  creationTimestamp: "2022-02-13T11:03:30Z"
13.	  name: aws-auth
14.	  namespace: kube-system
15.	  resourceVersion: "11362"
16.	  uid: ac36a1d9-76bc-40dc-95f0-b1e7934357



Step7:
save the file (vi editor save) and you will see the new config map loaded

kubectl edit configmap aws-auth -n kube-system
configmap/aws-auth edited



Step8: refresh the root AWS Web console user browser and the nodes and all node information will show up and the "error" banner will no longer show.



# General review of steps to get the entire setup up

Stage1
In terraform workspace
1.	Git checkout stage
2.	Git push origin stage
3.	Git checkout main
4.	Git merge stage
5.	Git push origin main

Stage2
Once infra is up go to application workspace: git push origin main
This will run a new build and deploy the helm chart based on yml files in templates folder

Stage3
Add a CNAME entry in Google Cloud DNS for holinessinloveofchrist.com domain
Vprofile-project17.holinessinloveofchrist.com

# General review to destroy 


From the kubectl terminal and from the /terraform directory in the first repo (either branch, main or stage is fine)
1.	Remove the nginix controller
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.3/deploy/static/provider/aws/deploy.yaml
        1.b. optional: helm uninstall vprofile-stack (this is not absolutely necessary)
2.	Edit the terraform.tf to version 1.5.1 temporarily
3.	Download current s3 bucket in case something fails
4.	Run terraform init on the bucket
terraform init -backend-config="bucket=terraform-state-project17-vprofile-gitops”
5.	Terraform destroy
6.	Revert the 1.5.1 version in terraform.tf back to 1.6.6 with: git reset --hard HEAD



# Added as self-hosted github runner ubuntu22 on EC2 on AWS2

see word doc on this.
sudo apt udpate

also install unzip
sudo apt-get install unzip

also install node js
sudo apt install nodejs

create a symlink of the node js
ln -s /usr/bin/nodejs /usr/bin/node




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
