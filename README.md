# hashitalks-deploy-blue-green

This repo is intended to demonstrate how Hashicorp Waypoint pipelines can be used in conjunction with Nomad and Consul to do a [blue-green deployment](https://en.wikipedia.org/wiki/Blue-green_deployment). 

Hashicorp Waypoint pipelines enable highly customizable workflows. This project features their use of built-in Waypoint lifecycle operations (`build`, `deploy`, `release`) as pipeline steps, as well as custom `exec` steps to run Consul commands. What the pipelines in this project try to achieve are an application build and canary deployment to Nomad (using the Pack and Nomad jobspec plugins), followed by a Consul configuration update of a service splitter. This service splitter update enables traffic being sent to the application which is deployed to be split based on tags; in this case, during the canary deployment, 50% of traffic will flow to the existing blue-tagged instances of the service, and 50% will flow to the new canary instances of the service, tagged "green".

At this point, the conclusion of the `blue-green-deployment` pipeline run, the Nomad job's canaries will continue to exist and traffic will remain split by Consul until the next pipeline, `promotion-and-normalize-trafic` is run. During this pipeline, the canary deployment is promoted (using the Nomad jobspec canary plugin), and the Consul service splitter is updated to route 100% of the traffic back to the "blue" instances of the service.

## Pre-Requisites
1. Waypoint CLI installed
2. Waypoint server installed
3. Waypoint runner installed
4. Waypoint on-demand runner profile
5. Consul cluster
6. Nomad cluster integrated with Consul
7. Vault cluster
    - This is required only if you want Waypoint to pull secrets from Vault. To opt-out of this, remove the Vault provider from `terraform/providers.tf` and the Vault resources from `terraform/main.tf`. Additionally, to push your image to a private registry, when running the pipeline, supply the `username` and `password` variables manually.
8. Docker registry
9. Apply the Terraform configuration from `terraform/` in this repo to your Consul cluster, Vault cluster, and Waypoint server
    
# Steps
1. Run `waypoint pipeline run blue-green-deployment` to kick off the deployment to Nomad.
    - In Nomad, you'll see that your job has canary Nomad allocations now. You can do this on the CLI with the command `nomad job status my-app`.
    - In Consul, your "app" service's "routing" view will show a service splitter with a line to each resolver, where 50% of traffic is going to the "blue" resolver and 50% is going to the "green" resolver. You can do this on the CLI with the command `consul config read -kind=service-splitter -name=app`.
2. When you're ready to promote the deployment, run `waypoint pipeline run promotion-and-normalize-traffic`.
    - In Nomad, you'll notice that the canary allocations are gone, and the remaining allocations are running the version you deployed.
    - In Consul, you can see that the splitter still exists, but 100% of traffic is going to the "blue" tagged instances now, and that there are no more "green" instances registered to the "app" service.
