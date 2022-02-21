## Create a EKS Cluster

Collecting and analyzing [audit] logs is useful for a variety of different reasons. Logs can help with root cause analysis and attribution, i.e. ascribing a change to a particular user. When enough logs have been collected, they can be used to detect anomalous behaviors too. On EKS, the audit logs are sent to Amazon Cloudwatch Logs.

### Step-1: Create Amazon Elastic Kubernetes Cluster (EKS)

Create a Amazon EKS Cluster by running the following command. This command will

* Create a VPC
* Create a EKS Cluster in that VPC
* Add managed nodes to the EKS Cluster created
* Update kubeconfig, so that you can run kubectl commands.


```shell
eksctl create cluster
```

**This step will take around 15 minutes to complete**

### Step-2: Enable EKS Control Plane audit logging

The audit logs are part of the EKS managed Kubernetes control plane logs that are managed by EKS. Instructions for enabling/disabling the control plane logs, which includes the logs for the Kubernetes API server, the controller manager, and the scheduler, along with the audit log, can be found here, https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html#enabling-control-plane-log-export.

```
eksctl utils update-cluster-logging --enable-types audit
```

Kubernetes audit logs include two annotations that indicate whether or not a request was authorized authorization.`k8s.io/decision` and the reason for the decision `authorization.k8s.io/reason`. Use these attributes to ascertain why a particular API call was allowed.



### Step-3: Generate some events

#### Create a Kubernetes Secret with JFrog API Keys

```shell
kubectl create secret docker-registry regcred \ --docker-server=REPLACE_YOUR_JFROG_ARTIFACTORY_URL \ --docker-username=REPLACE_JFROG_USERNAME \ --docker-password=REPLACE_WITH_JFROG_USER_TOKEN \
--docker-email=REPLACE_WITH_JFROG_USER_EMAIL
```


### Step-4: Analyze the events using AWS CloudWatch Insights

Open the [AWS CloudWatch Insights](https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#logsV2:logs-insights) and run the following queries to visialize the data

Lists updates to the aws-auth ConfigMap:


```
fields @timestamp, @message
| filter @logStream like "kube-apiserver-audit"
| filter verb in ["update", "patch"]
| filter objectRef.resource = "configmaps" and objectRef.name = "aws-auth" and objectRef.namespace = "kube-system"
| sort @timestamp desc
```

List of failed anonymous requests:

```
fields @timestamp, @message, sourceIPs.0
| sort @timestamp desc
| limit 100
| filter user.username="system:anonymous" and responseStatus.code in ["401", "403"]
```

Plots any action for secrets:

```
fields @timestamp, @message
| sort @timestamp desc
| limit 100
| filter objectRef.resource="secrets"
| stats count() by bin(1m)
```



