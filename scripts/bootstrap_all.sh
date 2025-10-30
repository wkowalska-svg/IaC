#!/bin/bash
set -euo pipefail

PROJECT_ID="$1"
STATE_BUCKET="${2:-tf-state-${PROJECT_ID}}"
REGION="${3:-us-central1}"
CB_SA_NAME="${4:-cloudbuild-runner}"

if [ -z "$PROJECT_ID" ]; then
  echo "Usage: $0 <PROJECT_ID> [state-bucket-name] [region]"
  exit 1
fi

echo "Bootstrapping project: $PROJECT_ID"
gcloud config set project "$PROJECT_ID"

# 1️⃣ Enable required APIs
echo "Enabling required APIs..."
gcloud services enable \
  cloudbuild.googleapis.com \
  compute.googleapis.com \
  storage.googleapis.com \
  monitoring.googleapis.com \
  serviceusage.googleapis.com \
  secretmanager.googleapis.com \
  --project "$PROJECT_ID"

# 2️⃣ Create Terraform state bucket if it doesn't exist
if gsutil ls -b "gs://$STATE_BUCKET" >/dev/null 2>&1; then
  echo "Bucket gs://$STATE_BUCKET already exists."
else
  echo "Creating Terraform state bucket: gs://$STATE_BUCKET"
  gsutil mb -p "$PROJECT_ID" -c STANDARD -l "$REGION" -b on "gs://$STATE_BUCKET"
fi

echo "Enabling versioning for bucket gs://$STATE_BUCKET"
gsutil versioning set on "gs://$STATE_BUCKET"

# 3️⃣ Create a new user-managed Cloud Build service account
CB_SA_EMAIL="${CB_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
if gcloud iam service-accounts list --filter="email:$CB_SA_EMAIL" --format="value(email)" | grep -q "$CB_SA_EMAIL"; then
  echo "Service account $CB_SA_EMAIL already exists."
else
  echo "Creating service account: $CB_SA_EMAIL"
  gcloud iam service-accounts create "$CB_SA_NAME" \
    --description="Service account for Cloud Build" \
    --display-name="Cloud Build Runner"
fi

# Grant the new SA necessary project roles
echo "Assigning IAM roles to Cloud Build SA: $CB_SA_EMAIL"

CB_ROLES=(
  "roles/compute.admin"
  "roles/compute.networkAdmin"
  "roles/iam.securityAdmin"
  "roles/storage.admin"
  "roles/monitoring.editor"
  "roles/serviceusage.serviceUsageAdmin"
  "roles/logging.logWriter"
)

for ROLE in "${CB_ROLES[@]}"; do
  gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$CB_SA_EMAIL" \
    --role="$ROLE" \
    --condition=None \
    --quiet
done

# Grant Cloud Build SA storage.admin on the state bucket explicitly
echo "Granting bucket-level roles/storage.admin to Cloud Build SA on $STATE_BUCKET"
gsutil iam ch serviceAccount:$CB_SA_EMAIL:roles/storage.admin gs://$STATE_BUCKET

echo "Bootstrap complete."
echo "Terraform state bucket: $STATE_BUCKET"
echo "Cloud Build service account: $CB_SA_EMAIL"
