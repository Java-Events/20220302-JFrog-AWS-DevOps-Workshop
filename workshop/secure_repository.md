## Using Open Policy Agent (OPA) for policy-based control in EKS

Security and governance is a critical component of configuring and managing fine-grained control for Kubernetes clusters and applications. Amazon EKS provides secure, managed Kubernetes clusters by default, but you still need to ensure that you configure and administer the applications appropriately that you run as part of the cluster. 

The Open Policy Agent (OPA, pronounced “oh-pa”) is an open source, general-purpose policy engine that unifies policy enforcement across the stack. OPA provides a high-level declarative language that let’s you specify policy as code and simple APIs to offload policy decision-making from your software.

- AWS Blogs on OPA:
[Using Open Policy Agent on Amazon EKS](https://aws.amazon.com/blogs/opensource/using-open-policy-agent-on-amazon-eks/)
[Realize Policy-as-Code with AWS Cloud Development Kit through Open Policy Agent](https://aws.amazon.com/blogs/opensource/realize-policy-as-code-with-aws-cloud-development-kit-through-open-policy-agent/)
[OCI Artifact Support in Amazon ECR](https://aws.amazon.com/blogs/containers/oci-artifact-support-in-amazon-ecr/)


In this chapter, we take a look at how to implement OPA on an Amazon EKS cluster and take a look at a scenario to restrict container images from JFrog Artifactory using a OPA policy.


### Step-1: Deploy Open Policy Agent Gatekeeper

```shell
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.1/deploy/gatekeeper.yaml
```

### Step-2: Deploy Constraint Template

```shell
kubectl apply -f https://raw.githubusercontent.com/Java-Events/20220302-JFrog-AWS-DevOps-Workshop/master/workshop/code/constraint_template.yaml
```

### Step-4: Create a constraint to include JFrog Artifactory URL

Create a file with following content.Name this file as constraint.yaml. Replace `REPLACE-ME-WITH-JFROG-ARTIFACTORY-URL` in this file with JFrog Artifactory URL and save the file. Deploy using `kubectl apply -f constraint.yaml`

```shell
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sAllowedRepos
metadata:
  name: allow-only-private-registry
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
  parameters:
    repos:
      - "REPLACE-ME-WITH-JFROG-ARTIFACTORY-URL"
```

### Step-5 : Test

Deploy a busybox image from DockerHub. This deployment will fail as we allow listed only JFrog Artifactory URL

```shell
kubectl run php-pod --image nginx
```

Now create a remote repository in your artifactory instance to pull through and cache the same image from DockerHub. Follow instructions mentioned [here](https://www.jfrog.com/confluence/display/JFROG/Docker+Registry#DockerRegistry-RemoteDockerRepositories)

Once you create the remote repository on artifactory, run the same command again, but this time trying to pull the image from Artifactory (which we allow listed)


```shell
kubectl run nginx --image=REPLACE_WITH_YOUR_ARTIFACTORY_URL/default-docker-remote/nginx/nginx
```

