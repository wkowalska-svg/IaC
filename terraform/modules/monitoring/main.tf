# High CPU Usage Alert Policy
resource "google_monitoring_alert_policy" "cpu_usage" {
  display_name = "High CPU Usage Alert"
  combiner     = "OR"
  project      = var.project_id

  conditions {
    display_name = "CPU usage above 80%"
    condition_threshold {
      filter          = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.email.id
  ]
}

# Notification Channel for Email Alerts
resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Notification Channel"
  type         = "email"

  labels = {
    email_address = var.alert_email
  }

  project = var.project_id
}



#Logs Bucket for Monitoring
resource "google_storage_bucket" "logs" {
  name          = "${var.project_id}-logs"
  location      = var.region
  force_destroy = true
}

# Sink for exporting logs to the bucket
resource "google_logging_project_sink" "export_error_logs" {
  name        = "export_error_logs"
  destination = "storage.googleapis.com/${google_storage_bucket.logs.name}"
  filter      = "severity>=ERROR"
  project     = var.project_id

  unique_writer_identity = true
}

# Grant the sink permission to write to the bucket
resource "google_storage_bucket_iam_member" "log_sink_writer" {
  bucket = google_storage_bucket.logs.name
  role   = "roles/storage.objectCreator"
  member = google_logging_project_sink.export_error_logs.writer_identity
}