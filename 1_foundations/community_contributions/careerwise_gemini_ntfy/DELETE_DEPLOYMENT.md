# 🗑️ How to Delete Your GCP Deployment

Guide to clean up your CareerWise GCP Cloud Run deployment.

---

## 🚀 Quick Delete (Automated Script)

The easiest way is to use the deletion script:

```bash
cd /Users/jglover/jgdynamite/projects/agentic_ai/1_foundations/community_contributions/careerwise_gemini_ntfy

./delete-gcp-deployment.sh
```

The script will:
- Ask for confirmation
- Delete the Cloud Run service
- Optionally delete Artifact Registry repositories
- Show you what was deleted

---

## 🔨 Manual Delete (Step by Step)

### Step 1: Delete Cloud Run Service

```bash
gcloud run services delete careerwise-chatbot \
  --region us-central1 \
  --project careerwise-chatbot \
  --quiet
```

**Or without --quiet to confirm:**
```bash
gcloud run services delete careerwise-chatbot \
  --region us-central1 \
  --project careerwise-chatbot
```

### Step 2: Delete Artifact Registry Repositories (Optional)

If you want to clean up the Docker images too:

```bash
# Delete the source deploy repo (created automatically)
gcloud artifacts repositories delete cloud-run-source-deploy \
  --location us-central1 \
  --project careerwise-chatbot \
  --quiet

# Delete the custom repo (if you created it)
gcloud artifacts repositories delete careerwise-repo \
  --location us-central1 \
  --project careerwise-chatbot \
  --quiet
```

### Step 3: Verify Deletion

Check that everything is deleted:

```bash
# List Cloud Run services (should be empty or not show careerwise-chatbot)
gcloud run services list --region us-central1

# List Artifact Registry repos (should be empty or not show the repos)
gcloud artifacts repositories list --location us-central1
```

---

## 🌐 Delete via GCP Console (GUI)

### Delete Cloud Run Service:

1. Go to: https://console.cloud.google.com/run
2. Select your project: `careerwise-chatbot`
3. Find `careerwise-chatbot` service
4. Click on it
5. Click **"Delete"** at the top
6. Confirm deletion

### Delete Artifact Registry:

1. Go to: https://console.cloud.google.com/artifacts
2. Select your project
3. Find the repositories:
   - `cloud-run-source-deploy`
   - `careerwise-repo` (if exists)
4. Click on each → **Delete**
5. Confirm deletion

---

## ⚠️ Important Notes

### What Gets Deleted:
- ✅ Cloud Run service (no more API endpoint)
- ✅ All revisions of the service
- ✅ Container images (if you delete Artifact Registry)

### What Stays:
- ⚠️ **Billing charges** - You may still see charges for:
  - Storage (if images weren't deleted)
  - Requests made before deletion
  - Any resources still running

### Check Billing:
1. Go to: https://console.cloud.google.com/billing
2. Check for any remaining charges
3. Verify everything is stopped

---

## 🔍 Verify Everything is Deleted

### Check Cloud Run:
```bash
gcloud run services list --region us-central1 --project careerwise-chatbot
```
Should return: `Listed 0 items.`

### Check Artifact Registry:
```bash
gcloud artifacts repositories list --location us-central1 --project careerwise-chatbot
```
Should show no repositories (or empty list)

### Check GCP Console:
- Cloud Run: https://console.cloud.google.com/run
- Artifact Registry: https://console.cloud.google.com/artifacts
- Both should show no careerwise-related resources

---

## 💰 Cost Cleanup

### After Deletion:

1. **Wait 24-48 hours** - Charges may take time to appear/disappear
2. **Check billing dashboard** - https://console.cloud.google.com/billing
3. **Monitor costs** - Make sure charges stop

### If You See Charges After Deletion:

- Check other GCP resources that might be running
- Verify no other services are using resources
- Cloud Run usually stops charging immediately after deletion
- Storage charges stop after images are deleted

---

## 🆘 Troubleshooting

### Issue: "Service not found"

**Solution:** Service is already deleted! ✅

### Issue: "Permission denied"

**Solution:**
```bash
# Re-authenticate
gcloud auth login

# Verify project
gcloud config set project careerwise-chatbot

# Check permissions
gcloud projects get-iam-policy careerwise-chatbot
```

### Issue: "Cannot delete repository because images exist"

**Solution:**
```bash
# Delete all images first, then repository
# Or use --force flag (if available)
gcloud artifacts repositories delete careerwise-repo \
  --location us-central1 \
  --project careerwise-chatbot \
  --force
```

---

## ✅ Cleanup Checklist

After deletion:

- [ ] Cloud Run service deleted
- [ ] Artifact Registry repositories deleted (optional)
- [ ] Verified no services running
- [ ] Checked billing dashboard
- [ ] Confirmed no charges (after 24-48 hours)

---

## 📝 Quick Command Reference

```bash
# Delete service
gcloud run services delete careerwise-chatbot --region us-central1 --project careerwise-chatbot

# Delete repositories
gcloud artifacts repositories delete cloud-run-source-deploy --location us-central1 --project careerwise-chatbot
gcloud artifacts repositories delete careerwise-repo --location us-central1 --project careerwise-chatbot

# Verify deletion
gcloud run services list --region us-central1
gcloud artifacts repositories list --location us-central1
```

---

**That's it! Your GCP deployment should be completely cleaned up.** 🎉
