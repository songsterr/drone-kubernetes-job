# Kubernetes Job Runner Plugin for Drone

This plugin allows to run a job on a Kubernetes cluster.

## Usage  

This pipeline will run the `rake-db-migrate` job described in `./infra/kubernetes/staging/rake-db-migrate-job.yml`.

  migrate_staging_db:
    when:
      branch: develop
    image: songsterr/drone-kubernetes-job
    kubernetes_server: "${KUBERNETES_SERVER}"
    kubernetes_token: "${KUBERNETES_TOKEN}"
    namespace: staging-ns
    spec: ./infra/kubernetes/staging/rake-db-migrate-job.yml
    job: rake-db-migrate

## Required secrets

    drone secret add --image=songsterr/drone-kubernetes-job \
        your-user/your-repo KUBERNETES_SERVER https://mykubernetesapiserver

    drone secret add --image=songsterr/drone-kubernetes-job \
        your-user/your-repo KUBERNETES_CERT <base64 encoded CA.crt>

    drone secret add --image=songsterr/drone-kubernetes-job \
        your-user/your-repo KUBERNETES_TOKEN eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJ...

When using TLS Verification, ensure Server Certificate used by kubernetes API server 
is signed for SERVER url (could be a reason for failures if using aliases of kubernetes cluster)

### Special thanks

Inspired by [drone-kubernetes](https://github.com/honestbee/drone-kubernetes).
