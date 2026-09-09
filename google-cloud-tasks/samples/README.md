# Ruby Google Cloud Tasks sample

This sample application shows how to use the
[Google Cloud Tasks](https://cloud.google.com/cloud-tasks/) client library.

`create_http_task.rb` is a simple command-line program to create tasks with an
HTTP target.

## Setup

Before you can run or deploy the sample, you need to do the following:

1.  Enable the Cloud Tasks API in the [Google Cloud Console](https://console.cloud.google.com/apis/api/tasks.googleapis.com).
1.  Set up [Google Application Credentials](https://cloud.google.com/docs/authentication/getting-started).
1.  Install dependencies:
    ```
    bundle install
    ```

## Creating a queue

To create a queue (named `my-queue`), use the following gcloud command:

    gcloud tasks queues create my-queue


## Run the Sample Using the Command Line

Set environment variables:

First, your project ID:

```
export GOOGLE_CLOUD_PROJECT=<PROJECT_ID>
```

Then the queue ID, as specified at queue creation time. Queue IDs already
created can be listed with `gcloud tasks queues list`.

```
export QUEUE_ID=my-queue
```

And finally the location ID, which can be discovered with
`gcloud tasks queues describe my-queue`, with the location embedded in
the "name" value (for instance, if the name is
"projects/my-project/locations/us-central1/queues/my-queue", then the
location is "us-central1").

```
export LOCATION_ID=us-central1
```

### Creating Tasks with HTTP Targets
Set an environment variable for the endpoint to your task handler. This is an
example url:

```
export URL=https://example.com/taskhandler
```
Running the sample will create a task and send the task to the specific URL
endpoint, with a payload specified:

```
ruby create_http_task.rb $LOCATION_ID $QUEUE_ID $URL
```
