variable "cluster_id" {
  description = "The ID of the eks cluster"
}

variable "post_api_policy_arn" {
  description = "The arn of the post-api iam policy"
}

variable "post_api_k8s_service_account" {
  description = "The name of the K8s ServiceAccount for post-api"

}
