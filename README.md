# creating-gke-cluster-workload-identity-and-gcp-service-account-with-IAM-permission-with-terraform


it will create gke cluster and enable workload identity on cluster and node level and also create gcp service account and assign permission on that service account...

 # i have check with terraform  resource block for kubernetes serviceacount is not working. We can do with with gcloud command as well..
  metadata 


    kubectl create serviceaccount gke-areez --namespace=default
    
    gcloud iam service-accounts add-iam-policy-binding gke-areez@my-project-id.iam.gserviceaccount.com \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:my-project-id.svc.id.goog[default/gke-areez]"
    
    kubectl annotate serviceaccount gke-areez \
    --namespace default \
    iam.gke.io/gcp-service-account=gke-areez@my-project-id.iam.gserviceaccount.com
    
terraform init
terraform plan
terraform apply
