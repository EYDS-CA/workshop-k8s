# Workshop - Azure Kubernetes

BC Government is getting more invested in their OpenShift Container Platform (OCP), so we need to upskill to meet their demand. Since OpenShift clusters are expensive, we will be learning Kubernetes (K8s) instead (OpenShift is 90% just K8s), on top of the Azure Kubernetes Service.

Learning is broken down into "milestones", and each milestone in this repository will be a PR into the branch of the milestone before it. The `main` branch has all milestones so please check the Pull Requests of this repository to see each milestone/lesson separately.

You are encouraged to not follow the exact steps we have used here, and to focus just on the GitHub level learning goals, using this repository as an example.

## Milestone 1

### Goals

- Get your own project namespace set-up on our K8s cluster
- Deploy some HTTP service of your choice to AKS in your project namespace. Something like nginx or http-echo. Confirm external connectivity – can you reach it from the internet.
- Create a GitHub repository (EY GitHub account repository) and use the GitHub workflow action (deploy.yml) for deploying your Hello World service. You will need to configure your Azure connection credentials as a GitHub secret.
- Please experiment with the Kubernetes config files. Maybe change the docker container being deployed to something else.

#### Initial Set Up:

Azure/Kubernetes resources are created in several ways. In this milestone, we will focus on using autodeployment via GitHub actions, which we have already configured in this repository. The following steps will configure the .kube/config file on your local device, and you will use the contents of this file as your `KUBE_CONFIG` GitHub secret. 

#### Get the source code: 
 Either fork, or, clone and then set the remote origin to a new repository in your own GitHub account to use the source files from this repository. 

example: 
```
 git clone https://GitHub.com/EYDS-CA/workshop-Kubernetes
 cd workshop-Kubernetes
 rm -rf .git
 git init
 git remote add origin git@GitHub.com:chelsea-ey/<YOUR repository NAME>.git
 git branch -M main
 git push -u origin main
 git checkout milestone-1
```

#### Azure Access
You'll want to verify that you can access the azure portal prior to proceeding. 

  - Access the portal [here](https://portal.azure.com/#@EYGS.onmicrosoft.com/resource/subscriptions/ec7d31e7-d1df-465e-b131-1d1fe4178fc4/resourcegroups/learning-sandbox/providers/Microsoft.ContainerService/managedClusters/sandbox/overview).

Now that you have confirmed access, you will need to install the azure cli to authenticate locally and copy the contents of the generated ~/.kube/config file into a GitHub secret

  **Install azure cli (on mac):**

  ```bash
  brew update && brew install azure-cli
  ```

  **Install azure cli (on windows):** 
  
  - Instructions can be found [here](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)

  Once the installation is complete, you should be able to log in via your terminal

  ```bash
  az login
  ```

  You will be redirected to the browser. Continue to login with your ey credentials. 

  Once you have authenticated, you can proceed with local configuration:
  
  - Set the subscription id
    ```
    az account set --subscription ec7d31e7-d1df-465e-b131-1d1fe4178fc4
    ```
- note: if you're on an EY mac you may need to install the admin rights tool prior to executing these commands. 

- Set your az credentials in your local .kube/config:
  ```
  az aks get-credentials --resource-group learning-sandbox --name sandbox
  ```

#### Create a Namespace

Namespaces allow resources to appear grouped, by attaching a metadata field called 'namespace'. This was you can easily identify which resources you have created. This can be done in a few different ways:

- Using the kubectl cli: 

  ```
  kubectl create namespace <name>
  ```

- With a yaml file: 

  ```yaml 
  kind: Namespace
  apiVersion: v1
  metadata:
    name: <name>
  ```
  Then, either run the kubectl command `kubectl apply -f <filepath to this yaml>` or visit the portal and create a namespace in the sandbox cluster following the format above. 
  
*Optional:*

You can set your local .kube/config context with your namespace so that if you create any Kubernetes resources via kubectl cli the namespace metadata for each resource will be properly configured.

```
kubectl config set-context --current --namespace=<name>
```

#### Add GitHub Secrets

Now that you have authenticated with azure, configured your local .kube/config file, and created a namespace, you can proceed to set up GitHub secrets. The file at `.GitHub/workflows/deploy.yml` is set-up to deploy when a commit is pushed or merged to `milestone-1`. There are three GitHub secrets you will need to add in order for the action to authenticate with azure and deploy your build. 

##### NAMESPACE

- This should be the name of your Kubernetes namespace on the cluster that you have previously created.

##### KUBE_CONFIG

- This is the contents of `~/.kube/config` on your local machine - this has your credentials to connect to the cluster.
- Assuming you have set the aks credentials locally, as well as the context for your namespace set, run `cat ~/.kube/config | pbcopy`
- Paste this into a GitHub secret

##### ACR_PASSWORD

- password can be found [here](https://portal.azure.com/#@EYGS.onmicrosoft.com/resource/subscriptions/ec7d31e7-d1df-465e-b131-1d1fe4178fc4/resourceGroups/learning-sandbox/providers/Microsoft.ContainerRegistry/registries/eydscasandbox/users)


*Optional:*

If you plan to push an image from your local machine to the container registry, you'll first need to authenticate. This step will happen in the repository automatically, but you may want to know how to do this. 
- Log in to the container registry

    ```
    az acr login --name=eydscasandbox.azurecr.io
    ```

    - password can be found [here](https://portal.azure.com/#@EYGS.onmicrosoft.com/resource/subscriptions/ec7d31e7-d1df-465e-b131-1d1fe4178fc4/resourceGroups/learning-sandbox/providers/Microsoft.ContainerRegistry/registries/eydscasandbox/users)
    - You will not be pushing anything until the second milestone, but you want to ensure that you are able to log in


#### Build and Deploy

At this point, your GitHub repository should contain the three secrets needed to build and deploy resources to the azure sandbox cluster. In milestone 1 you will be deploying the official nginx image with no custom configuration. The GitHub action file `deploy.yml` will run when you push to the milestone-1 branch. 

- Save, commit, and push to your repository

You should see your project now live at `http://$NAMESPACE.k8s.freshworks.club`



*Optional:*

You can also create resources locally, or from within the azure portal (in the sandbox azure site). 

##### Local:

- First, update .env with your namespace
- Now you can try running `make apply` which _should_ deploy the infrastructure defined here.

##### Azure Portal:

- Visit the learning-sandbox azure site
- Go to the sandbox cluster, select the resource you want to create (see list below), choose to "create from yaml" and copy/paste the corresponding yaml files.
  - You'll need to create:
    - ingress.yaml
    - namespace.yaml (if not already created)
    - deployment.yaml (in workloads)
    - service.yml
  - The corresponding files can be found in the k8's directory

### Useful commands

- Create resources:

```
  kubectl apply -f k8s -n <yournamespace>
```

- See a list of your resources:

```
  kubectl get <deployments/services/pods/ingress> -n <yournamespace>
```

- Describe a resource:

```
  kubectl describe <deployments/services/pods> <name of resource> -n <yournamespace>
```

- View resource logs:

```
  kubectl logs <name of resource> -n <yournamespace>
```
