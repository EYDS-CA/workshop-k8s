# Workshop - Azure Kubernetes

BC Government is getting more invested in their OpenShift Container Platform (OCP), so we need to upskill to meet their demand. Since OpenShift clusters are expensive, we will be learning Kubernetes (K8s) instead (OpenShift is 90% just K8s), on top of the Azure Kubernetes Service.

Learning is broken down into "milestones", and each milestone in this repo will be a PR into the branch of the milestone before it. The `main` branch has all milestones so please check the Pull Requests of this repo to see each milestone/lesson separately.

You are encouraged to not follow the exact steps we have used here, and to focus just on the high level learning goals, using this repo as an example.

#### You will need the following already installed:

- docker
- node
- kubectl cli

## Milestone 1

### Goals

- Get your own project namespace set-up on our K8s cluster
- Deploy some HTTP service of your choice to AKS in your project namespace. Something like nginx or http-echo. Confirm external connectivity – can you reach it from the internet.
- Create a github repo (EY github account repo) and create a github workflow action for deploying your Hello World service. You will need to configure your Azure connection credentials as a github secret.
- Please experiment with the kubernetes config files. Maybe change the docker container being deployed to something else.

### Initial Set Up

#### Azure Access

- From the browser (to ensure access):

  - Access the AKS console [here](https://portal.azure.com/#@EYGS.onmicrosoft.com/resource/subscriptions/ec7d31e7-d1df-465e-b131-1d1fe4178fc4/resourcegroups/learning-sandbox/providers/Microsoft.ContainerService/managedClusters/sandbox/overview).

- From your terminal:

  - Install azure cli:

    ```bash
    brew update && brew install azure-cli
    ```

  - Log-in to Azure using
    ```
    az login
    ```
  - Set the subscription id
    ```
    az account set --subscription ec7d31e7-d1df-465e-b131-1d1fe4178fc4
    ```

#### Local Kubectl Config

- note: if you're on an EY mac you may need to install the admin rights tool prior to executing these commands. This is needed in order to automatically update your .kube/config

* Update your local .kube/config:
  ```
  az aks get-credentials --resource-group learning-sandbox --name sandbox
  ```
* Create a namespace:

  ```
  kubectl create namespace <name>
  ```

  or create this in the browser by adding a yaml to the namespaces resource in the sandbox cluster, or, by running `kubectl apply -f <filepath to this yaml>`:

  ```yaml
  kind: Namespace
  apiVersion: v1
  metadata:
    name: <name>
  ```

  - Set your local .kube/config to use this namespace:
    ```
    kubectl config set-context --current --namespace=<name>
    ```
  - Log in to the container registry

    ```
    az acr login --name=eydscasandbox.azurecr.io
    ```

    - password can be found [here](https://portal.azure.com/#@EYGS.onmicrosoft.com/resource/subscriptions/ec7d31e7-d1df-465e-b131-1d1fe4178fc4/resourceGroups/learning-sandbox/providers/Microsoft.ContainerRegistry/registries/eydscasandbox/users)
    - You will not be pushing anything until the second milestone, but you want to ensure that you are able to log in

### Set Up Repo

- Create a github repo (EY github account repo)
- You can clone this repo and push to your own branch, or change the remote to your own repo, or fork this one (which will create your own repo)
- #### Checkout branch milestone1
  example (clone):

```
 git clone https://github.com/EYDS-CA/workshop-kubernetes
 cd workshop-kubernetes
 rm -rf .git
 git init
 git remote add origin git@github.com:chelsea-ey/<YOUR REPO NAME>.git
 git branch -M main
 git push -u origin main
 git checkout milestone1
```

### Add Secrets

- The file at `.github/workflows/deploy.yml` is set-up to deploy when a commit is pushed or merged to `milestone1`, or with a manual trigger (go to asctions, click on the action, click on run workflow)
- We need to get GitHub Actions working so this deploys in CI/CD.
- You'll first need to add three GitHub secrets.

##### NAMESPACE

- this should be the name of your kubernetes namespace on the cluster.

##### KUBE_CONFIG

- should be the contents of `~/.kube/config` on your local machine - this has your credentials to connect to the cluster (previously configured).
- assuming you have set the aks credentials locally, as well as the context for your namespace set, run `cat ~/.kube/config | pbcopy`

##### ACR_PASSWORD

- password can be found [here](https://portal.azure.com/#@EYGS.onmicrosoft.com/resource/subscriptions/ec7d31e7-d1df-465e-b131-1d1fe4178fc4/resourceGroups/learning-sandbox/providers/Microsoft.ContainerRegistry/registries/eydscasandbox/users)

### Deploy an official image

Deploy the official nginx image as found in the milestone 1 branch (no custom configuration, this is just the official docker image to ensure your automated deployments are working as expected)

#### Auto-Deploy (reccomended):

- **\*Be sure you have checked out milestone1**
- First you need to update the makefile set the `NAMESPACE` environment variable to the name of your new namespace, e.g. `export NAMESPACE=milestones`.
- Set the REPO variable to your repo name `ACR_REPO=eydscasandbox.azurecr.io/<YOUR NAMESPACE>`
- Now you can try running `make apply` which _should_ deploy the infrastructure defined here.
- Commit, push to milestone1, and check your "actions"
- You should see your project now live at `http://$NAMESPACE.k8s.freshworks.club`

#### Deploy with Kubectl (optional):

- Ensure the namespace context is set locally, and update any k8's file so that your namespace is properly added.
- From project root:

```
  kubectl apply -f k8s
```

#### Deploy From the azure site (optional):

- Visit the learning-sandbox azure site
- Go to the sandbox cluster, select the resource you want to create (see list below), choose to "create from yaml" and copy/paste the corresponding yaml files.
  - You'll need to create:
    - ingress.yaml
    - namespace.yaml (if not already created)
    - deployment.yaml (in workloads)
    - service.yml
  - The corresponding files can be found in the k8's directory

### Useful commands

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

## Milestone 2

### Goals

- Deploy a custom docker image to our Azure Container Registry repository as part of your build pipeline.
- Use this docker image in place of your existing one for your web service.
- Add a Kubernetes Secret and supply it to this pod somehow.

### Steps

- Add a custom Dockerfile for your new image. We have created one in this repo at `services/custom-nginx`.
- Log-in to the Azure Container Registry we are using with the command
  ```
  az acr login --name=eydscasandbox
  ```
  - password can be found in the Azure portal in the eydscasandbox container registry under "Access Keys".
- See the `nginx-build` and `nginx-push` commands in the makefile for building your new docker image and pushing it to the Azure repository.
- Replace the docker image in your kubernetes deployment file with this new image, e.g. `eydscasandbox.azurecr.io/${NAMESPACE}/custom-nginx:latest`.
- Run the pipeline to test that this new image can be successfully deployed.
- Add a build and deploy step for your new image into your GitHub workflow file, before the kubernetes deployment, so the image is built and pushed as part of the pipeline.
- Add a secret to your namespace using e.g.
  ```
  kubectl create secret generic nginx-message --from-literal=message='Hello World!'
  ```
  - This will create a secret called `nginx-message` with the key `message` set to the value `Hello World!`.
- Update the k8s/deployment.yml file with:

  ```
  spec:
    containers:
    - name: nginx
      image: eydscasandbox.azurecr.io/milestones/custom-nginx:latest
      ports:
      - containerPort: 80
      env:
      - name: MESSAGE
        valueFrom:
          secretKeyRef:
            name: nginx-message
            key: message
            optional: false
  ```

- Find a way to get this secret to influence the behaviour of your docker container, so that you know it is being accessed properly. For example, in this repo we are templating the nginx config file with a response message given by the `$MESSAGE` environment variable.
