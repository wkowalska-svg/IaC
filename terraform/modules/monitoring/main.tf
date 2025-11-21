resource "google_monitoring_alert_policy" "cpu_usage" {
  display_name = "High CPU Usage Alert"
  combiner     = "OR"
  project      = var.project_id

  conditions {
    display_name = "CPU usage above 80%"
    condition_threshold {
      filter     = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
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

resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Notification Channel"
  type = "email"

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