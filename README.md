<div align="center">
	<p>
	<img alt="Thoughtworks Logo" src="https://raw.githubusercontent.com/twplatformlabs/static/master/psk_banner.png" width=800 />
	<h2>psk-platform-svc-metrics-server</h2>
	<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/github/license/twplatformlabs/psk-platform-svc-metrics-server"></a> <a href="https://aws.amazon.com"><img src="https://img.shields.io/badge/-deployed-blank.svg?style=social&logo=amazon"></a>
	</p>
</div>

Release pipeline for metrics-server service on Labs AWS platform

Define desired helm chart version and values setting for each cluster role.  

Generates the application.yaml Application resources definition used by ArgoCD Core to manage the desired version for the metrics-server service. Once resource is synced and healthy, runs integration test suite to confirm metrics-server health.  

A "deployment" means the application.yaml and the <role>-values.yaml files are copied to the specific roles/<role>/metrics-server folder in the psk-aws-control-plane-configuration repository.  

Default values are per/role and will not trigger all-roles to sync new values just because one role is changed.  

### upgrade

Set new chart version in environment/<role>.json.  

`git push` will update sandbox role and `git tag` updates production role in simplified psk labs control plane pipeline.
