```
gcloud run deploy crdemo --concurrency 20 --no-cpu-throttling  --region=europe-north1 --port=80 --allow-unauthenticated
gcloud run deploy crdemo --image gcr.io/wtfpr-develop-in-gcp-kuu/crdemo:v1 --concurrency 20 --no-cpu-throttling  --region=europe-north1 --port=80 --allow-unauthenticated

gcloud builds submit --tag gcr.io/wtfpr-develop-in-gcp-kuu/crdemo:v1
```