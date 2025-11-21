output "alert_policy_id" {
  value = google_monitoring_alert_policy.cpu_usage.name
}

output "notification_channel_id" {
  value = google_monitoring_notification_channel.email.id
}