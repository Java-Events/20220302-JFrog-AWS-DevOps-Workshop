## Audit Logging

Collecting and analyzing [audit] logs is useful for a variety of different reasons. Logs can help with root cause analysis and attribution, i.e. ascribing a change to a particular user. When enough logs have been collected, they can be used to detect anomalous behaviors too. On EKS, the audit logs are sent to Amazon Cloudwatch Logs.

### Step-1: Enable EKS Control Plane audit logging

The audit logs are part of the EKS managed Kubernetes control plane logs that are managed by EKS. Instructions for enabling/disabling the control plane logs, which includes the logs for the Kubernetes API server, the controller manager, and the scheduler, along with the audit log, can be found here, https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html#enabling-control-plane-log-export.

```
echo "export EKS_CLUSTERNAME=$(cut -d . -f 1 <<< $(cut -d @ -f 2 <<< $(kubectl config current-context)))" >> ~/.bashrc
bash
eksctl utils update-cluster-logging --cluster $EKS_CLUSTERNAME --enable-types audit --approve

```

Kubernetes audit logs include two annotations that indicate whether or not a request was authorized authorization.`k8s.io/decision` and the reason for the decision `authorization.k8s.io/reason`. Use these attributes to ascertain why a particular API call was allowed.



### Step-2: Generate some events

#### Create a Kubernetes Secret with JFrog Access Tokens

**NOTE** Refer [here](https://www.jfrog.com/confluence/display/JFROG/Access+Tokens#AccessTokens-ScopedTokens) if required to learn how to generate a scoped **user** token.

Supply the `docker-server`, `docker-username`, `docker-password` and `docker-email` values

```shell
kubectl create secret docker-registry regcred --docker-server=REPLACE_YOUR_JFROG_ARTIFACTORY_URL --docker-username=REPLACE_JFROG_USERNAME --docker-password=REPLACE_WITH_JFROG_USER_TOKEN --docker-email=REPLACE_WITH_JFROG_USER_EMAIL
```
### Step-3: Analyze the events using AWS CloudWatch Insights

Open the [AWS CloudWatch Insights](https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#logsV2:logs-insights) and run the following queries to visialize the data


Any action for secrets:

```
fields @timestamp, @message
| sort @timestamp desc
| limit 100
| filter objectRef.resource="secrets"

```

Lists creation of new or changes to validation webhooks:

```
fields @timestamp, @message
| filter @logStream like "kube-apiserver-audit"
| filter verb in ["create", "update", "patch"] and responseStatus.code = 201
| filter objectRef.resource = "validatingwebhookconfigurations"
| sort @timestamp desc

```

Lists create, update, delete operations to Roles:

```
fields @timestamp, @message
| sort @timestamp desc
| limit 100
| filter objectRef.resource="roles" and verb in ["create", "update", "patch", "delete"]
```

List of failed anonymous requests:

```
fields @timestamp, @message, sourceIPs.0
| sort @timestamp desc
| limit 100
| filter user.username="system:anonymous" and responseStatus.code in ["401", "403"]
```



