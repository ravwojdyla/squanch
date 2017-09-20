Squanch
=======

[![Docker Automated build](https://img.shields.io/docker/automated/jrottenberg/ffmpeg.svg)](https://hub.docker.com/r/ravwojdyla/squanch/)
[![GitHub license](https://img.shields.io/github/license/ravwojdyla/squanch.svg)](./LICENSE)

## Raison d'être:

This allows to monitor/graph JMX stats of Google Cloud Dataflow workers.

## Example:

```
> gcloud compute instances create df-monitor --image-family=cos-stable --image-project=cos-cloud --metadata-from-file=user-data=conf/cloud-config --scopes cloud-platform --machine-type=n1-standard-8 --boot-disk-size=500GB --metadata=job-id=2017-09-20_03_58_00-8704996699804360613
> gcloud compute ssh df-monitor -- -L3000:localhost:3000
> open http://localhost:3000
```
