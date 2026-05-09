# psk-platform-svc-metrics-server
Release pipeline for Metrics-Server service on Labs AWS platform


creates a folder called `deploy-files` then writes the desired files to this folder. Then uses wildcard to push all files to role/metrics-server in configuration repo.  

by convention, tag the repo to release - tag the same value as the chart or app vlue to be deployed