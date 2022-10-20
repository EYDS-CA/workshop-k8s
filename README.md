# Workshop - Azure Kubernetes

BC Government is getting more invested in their OpenShift Container Platform (OCP), so we need to upskill to meet their demand. Since OpenShift clusters are expensive, we will be learning Kubernetes (K8s) instead (OpenShift is 90% just K8s), on top of the Azure Kubernetes Service.

Learning is broken down into "milestones", and each milestone in this repo will be a PR into the branch of the milestone before it. The `main` branch has all milestones so please check the Pull Requests of this repo to see each milestone/lesson separately.

You are encouraged to not follow the exact steps we have used here, and to focus just on the high level learning goals, using this repo as an example.

## Milestone 1

### Goals

- Get your own project namespace set-up on our K8s cluster
- Deploy some HTTP service of your choice to AKS in your project namespace. Something like nginx or http-echo. Confirm external connectivity – can you reach it from the internet.
- Create a github repo (EY github account repo) and create a github workflow action for deploying your Hello World service. You will need to configure your Azure connection credentials as a github secret.

### Steps

- Access the AKS console [here](https://portal.azure.com/#@EYGS.onmicrosoft.com/resource/subscriptions/ec7d31e7-d1df-465e-b131-1d1fe4178fc4/resourcegroups/learning-sandbox/providers/Microsoft.ContainerService/managedClusters/sandbox/overview).

- Create a new namespace for yourself. Here is the YAML we used to create the `milestones` namespace:

```yaml
kind: Namespace
apiVersion: v1
metadata:
  name: milestones
```

- Log-in to Azure using `az login` (you can install Azure CLI on Mac using `brew install azure-cli`).
- Click "Connect" in the Azure console and run the two commands that get `kubectl` connected to this cluster.
- Copy this repository to get you started. First you need to set the `NAMESPACE` environment variable to the name of your new namespace, e.g. `export NAMESPACE=milestones`. Now you can try running `make apply` which _should_ deploy the infrastructure defined here.
- You should see your project now live at http://$NAMESPACE.k8s.freshworks.club. This example is running at http://milestones.k8s.freshworks.club.
- Please experiment with the kubernetes config files. Maybe change the docker container being deployed to something else.
- Next we need to get GitHub Actions working so this deploys in CI/CD. First step is to create your own personal GitHub repo for this project and copy your files into it.
- You'll first need to add two GitHub secrets. `NAMESPACE`, which should be the name of your kubernetes namespace on the cluster. `KUBE_CONFIG` should be the contents of `~/.kube/config` on your local machine - this has your credentials to connect to the cluster.
- The file at `.github/workflows/deploy.yml` is set-up to deploy when the `dev` tag is attached to a commit. Attach the `dev` tag to your latest commit and push it. You should see everything deploy automatically in GitHub Actions for your repo!

# Milestone 2

#### Make sure you have run `git checkout -b milestone-2`

### Goals

- Deploy a custom docker image to our Azure Container Registry repository as part of your build pipeline.
- Use kubectl cmds to check pods, deployments, ingress, etc
- Use this docker image in place of your existing one for your web service.
- Create a Kubernetes Secret and reference it in your deployment.

### Create a custom docker container to deploy

- Add a custom Dockerfile ex: `services/custom-nginx/Dockerfile`.
  - When we run docker build, this will create a new nginx image based on the specification in .conf
- Add and image name to your .env file (ie: IMAGE=`custom-nginx`)
- Your env file should now include:

```
  ACR_REPO=eydscasandbox.azurecr.io
  NAMESPACE=<your name>
  IMAGE=<whatever>
```

### Update k8s/deployment

- Replace image in your kubernetes deployment file with this new image:
  ```
  spec:
    containers:
      image: `eydscasandbox.azurecr.io/<YOUR REPO NAME>/<YOUR IMAGE NAME>:latest`.
  ```
- Run the pipeline to test that this new image can be successfully deployed.
- Add a build and deploy step for your new image into your GitHub workflow file, before the kubernetes deployment, so the image is built and pushed as part of the pipeline.
- Add a secret to your namespace using e.g.

```
  kubectl create secret generic nginx-message --from-literal=message='Hello World!' -n <YOUR NAMESPACE>
```

- This will create a secret called `nginx-message` with the key `message` set to the value `Hello World!`.
- Update your k8s/deployment.yml to apply this secret as an environment variable to your deployed pod using this syntax:

```
spec:
  containers:
  - name: nginx
    image: eydscasandbox.azurecr.io/$NAMESPACE/$IMAGE:latest
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

### Build, Tag, Push, Deploy

- Run `make nginx-build` then `make nginx-push` to build, tag and push to the Azure repository, and finally `make apply` to deploy.
- Verify the custom build with your message. In this repo we are templating the nginx config file with a response message given by the `$MESSAGE` environment variable.
