# 148.Step 03 - Creating Azure DevOps Pipeline for Azure Kubernetes Cluster IAAC. 
When you create a service connection to azure resource manager, the screens changed a bit. Choose Azure Resource Manager as explained in the video and the next screens look as below
1. Choose option Service Principle (Automatic)
![How to create a new service connection](./images/azure-devops-new-azure-resourcemanager-serviceconnection.png)
2. Choose the azure subscription from drop down, leave Resource Group Empty, provide the service connection name ![How to create a new service connection](./images/azure-devops-new-azure-resourcemanager-serviceconnection-02.png)
Also choose Grand access permission to all pipelines and click Save

# 152. Step 06 - Creating Azure DevOps Pipeline for Deploying Microservice to Azure AKS 1:30

Creating service connection for Kubernetes has to be done differently because of the open issue.

![How to create a new service connection](./images/azure-aks-connection.png)

1. Do az login in your cmd. This will open up your browser and need to select the account and log in.
2. run az aks get-credentials --name <name of the kubernetes cluster created> --resource-group <name of the resource group> --admin;
3. run cat ~/.kube/config; this command will show you config file details.
4. copy all content of files to your favourite text editor.
5. go to your service connection and choose KubeConfig from top radio button.
6. paste notepad's content in KubeConfig box.
7. choose cluster context <name of the cluster>
8. click on verify if its success then your job done. If you face any problems here, take a back up of the config file (~/.kube/config) and delete it. Run the command in step 2 again so that the config file contains only this kubernetes cluster.
9. Give connection name and click on last checkbox for permission.


 # 159. Step 01 - Review Terraform Configuration for AWS EKS Cluster Creation

AWS EKS has changed some of the configurations so we have udpated our repository with latest code.

1. The main.tf file now contains sections for creating EKS and then creating policy bindings after EKS is created. The sections which needs to be executed after the EKS creation are commented out now.
2. Follow the instructions given in the video to create the EKS cluster. There is no change in that.
3. Once the cluster is created, edit the main.tf and uncomment the sections marked as below

```
//>>Uncomment this section once EKS is created - Start
//>>Uncomment this section once EKS is created - End
```
and commit the file again. This will trigger the pipeline and policy bindings will be created.

4. Your final main.tf should look like the file final-main.txt in the same folder. You can compare your file with this one.