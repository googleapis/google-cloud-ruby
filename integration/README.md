## Integration Tests

The google-cloud-ruby integration tests are end-to-end tests that validate library functionality on real Google Cloud Platform hosting environments. The integration process deploys several Rack-based applications to Google Cloud Platform one by one, then validates google-cloud-ruby code by making requests to these test applications.

All integration tests require [Cloud SDK](https://cloud.google.com/sdk/) for deployment. Following the instructions in [Authentication guide](../AUTHENTICATION.md) for installation and authentication.

### Configuration
First, make sure a Google Cloud Platform project is setup that satisfies the following requirements:
1. Enable the [Stackdriver Error Reporting API](https://console.cloud.google.com/apis/api/clouderrorreporting.googleapis.com/overview).
2. Make sure a [Google Container Engine Cluster](https://cloud.google.com/container-engine/docs/clusters/operations) with permissions to access all the GCP services this library implements is properly setup and ready to use. It's easier to create the Cluster through [Cloud Platform Console](https://console.cloud.google.com/kubernetes/list). Keep in mind once the Cluster is created, the service permissions cannot be updated. 

Once Google Cloud SDK is installed and authenticated, make sure the following items are also configured properly:
1. Set Project ID:
```sh
$ gcloud config set project PROJECT_ID
```
2. Set Container Cluster name:
```sh
$ gcloud config set container/cluster CLUSTER_NAME
```
3. Extend Cloud Build timeout to an hour:
```sh
$ gcloud config set container/build_timeout 3600
```
In addition to Cloud SDK, Google Container Engine requires [Docker](https://www.docker.com/) for building Docker images, and the [Kubernetes commandline tool](http://kubernetes.io/docs/user-guide/kubectl-overview/) for image deployment. 

Follow the [Docker website](https://www.docker.com/products/docker) for Docker installation instructions.

The Kubernetes commandline tool can be installed through Cloud SDK:
```sh
$ gcloud components install kubectl
```

### Usage
To kick off the full integration test suite:
```sh
$ rake integration
```

### Integration tests on Google App Engine
To run the integration tests just on Google App Engine:
```sh
$ rake integration:gae
```
This rake task automates the Google App Engine deployment by deploying the google-cloud-ruby libraries with sample applications using the `gcloud app deploy` shell command. Each of the sample applications contains an app.yaml.example file that defines specific deployment procedure for that application. For example, the [Rails 5 app.yaml.example](rails5_app/app.yaml.example) file defines a custom entrypoint that allows bundler to install the sample application's dependencies and launch the application.

After a successful deployment, each google-cloud-ruby libraries can then run its integration tests against the deployed sample application. For example, the [google-cloud-logging tests](../google-cloud-logging/integration/) send HTTP requests to redefined routes on the sample application to trigger logs being generated. Then it's able to verify the result logs through Cloud SDK. 

### Integration tests on Google Container Engine
To run the integration tests on Google Container Engine:
```sh
$ rake integration:gke
```
Similar to the workflow of `integration:gae` task, the `integration:gke` task uses the `Dockerfile.example` file from each sample application as the template to build a Docker image, deploy it to Google Container Registry, and deploy Google Container pods to launch the application. In the case of GKE pods configuration, all sample application shares a same configuration defined in [integration_rc.yaml.example](integration_rc.yaml.example) file.

After the integration tests finish run against the deployed GKE sample application, the `integration:gke` application is also able to clean up all the resources created during the deployment. These resources include local test Docker image, GCR test Docker image, GKE ReplicationController, and GKE pods.  

### Integration tests on Google Compute Engine
We're currently not supporting automated tests on Google Compute Engine environment for the following reasons:
* Major functionalities such as metadata service accisibility, application default authentication are, operating system, and API accessibility are already covered by other automated tests.
* Both GAE and GKE are currently hosted on GCE VMs.
* It's harder to automate deployment on GCE environment than GAE or GKE, due to GCE's IaaS nature.

### Write tests

Each google-cloud-ruby libraries should define its own set of integration tests. It it doesn't already, make sure a corresponding `integration:gae` or `integration:gke` task exists at the package level. These tasks will be invoked by top level `integration` task when deployment is finished. Otherwise these package level tasks can also be invoked independently assume deployment already happened.

Common test cases defined in `google-cloud-*/integration/` directory will be run on both GAE and GKE environments. Environment specific test cases can be defined in `google-cloud-*/integration/gae/` or `google-cloud-*/integration/gke/` directories. Such test cases will only be run against the corresponding environment.
