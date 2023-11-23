##################################
#  VPC and Subnet Configuration  #
##################################
module "vpc" {
  source             = "../../modules/vpc"
  environment        = local.environment
  transit_gateway_id = "tgw-00cc59318a07e218e"
  vpc_cidr           = "10.248.192.0/21"
  public_subnets     = ["10.248.198.0/24", "10.248.199.0/24"]
  private_subnets    = ["10.248.192.0/23", "10.248.194.0/23"]
  contact_emails     = local.contact_emails
}

##################################
#  EKS                           #
##################################
module "eks" {
  source             = "../../modules/eks"
  kubernetes_version = "1.26"
  environment        = local.environment
  aws_region         = var.aws_region
  vpc_id             = module.vpc.id
  private_subnets    = module.vpc.private_subnets
  public_subnets     = module.vpc.public_subnets
  kubeconfig_path    = var.kubeconfig_path
  contact_emails     = local.contact_emails
  availability_zones = module.vpc.availability_zones
}

##################################
#  ACM                           #
##################################
module "certificates" {
  source                    = "../../modules/certificates"
  environment               = local.environment
  domain                    = "reecedev.us"
  subject_alternative_names = ["*.reecedev.us", "*.external-prod.reecedev.us"]
}

##################################
#  WAF                           #
##################################
module "web-application-firewall" {
  source      = "../../modules/web-application-firewall"
  environment = local.environment
}

##################################
#  Cloudfront for Max Subdomains #
##################################
module "cloudfront" {
  source            = "../../modules/cloudfront"
  WAF_id            = module.web-application-firewall.WAF_id
  WAF_enabled       = false
  environment       = local.environment
  cert_arn          = "arn:aws:acm:us-east-1:490524275591:certificate/12b0ff83-2345-468c-b3d5-48db24237a17"
  max_portal_lb_arn = "arn:aws:elasticloadbalancing:us-east-1:490524275591:loadbalancer/app/k8s-default-external-e1702a13d9/cc91cafffa0b0a0e"
  alternate_domain_names = [
    "devoreandjohnson.reece.com",
    "expresspipe.reece.com",
    "fortiline.reece.com",
    "fwcaz.reece.com",
    "morrisonsupply.reece.com",
    "toddpipe.reece.com",
    "morscohvacsupply.reece.com",
    "murraysupply.reece.com",
    "wholesalespecialties.reece.com",
    "expressionshomegallery.reece.com",
    "www.reece.com",
    "reece.com",
    "landbpipe.reece.com",
    "irvinepipe.reece.com"
  ]
}

##################################
#  POST API                      #
##################################
module "post-api" {
  source     = "../../modules/post-api"
  aws_region = var.aws_region
  lambda_function_post_name       = "post-processor"
  step_function_name_post         = "post-product-tagging-etl"
  environment       = local.environment
}

##################################
#  Bastion | Jump Box            #
#  must create ssh key pairs     #
#  manually in aws console       #
##################################
module "bastion" {
  source                     = "../../modules/bastion"
  environment                = local.environment
  vpc                        = module.vpc.id
  vpc_cidr                   = module.vpc.vpc_cidr
  public_subnet              = module.vpc.public_subnets[0].id
  private_subnet             = module.vpc.private_subnets[0].id
  contact_emails             = local.contact_emails
  bastion_key_pair_name      = "bastion_${local.environment}"
  private_host_key_pair_name = "private_host"
}

##################################
#  IAM Service Accounts          #
##################################
module "iam-service-accounts" {
  source                       = "../../modules/iam-service-accounts"
  cluster_id                   = module.eks.cluster_id
  post_api_policy_arn          = module.post-api.post_api_policy_arn
  post_api_k8s_service_account = "system:serviceaccount:default:external-prod-post-api-service"
}

##################################
#  ETL Kickoff                   #
##################################
module "etl-kickoff" {
  source                    = "../../modules/etl-kickoff"
  step_function_arn         = module.product_data_etl.step_function_arn
  step_function_arn_mincron = module.product_data_etl.step_function_arn_mincron
  step_function_arn_bk      = module.product_data_etl.step_function_arn_bk
  branches_lambda_arn       = module.product_data_etl.branches_lambda_arn
  branches_lambda_name      = module.product_data_etl.branches_lambda_name
  step_function_arn_post    = module.post-api.step_function_arn_post
  environment               = local.environment
}

##################################
#  Route53                       #
##################################
# This module has to be instantiated after the alb-ingress module
# After alb-ingress creates the load balancer, pass the root zone and load balancer arn here
# The root zone is being managed outside terraform
module "route53" {
  source                 = "../../modules/route53"
  environment            = local.environment
  root_zone_id           = "Z09662621LWH3VC84LW8I"
  lb_arn_max_api         = "arn:aws:elasticloadbalancing:us-east-1:490524275591:loadbalancer/app/k8s-default-external-8598661c00/c19ededa38c55b05"
  lb_arn_mobile_bff      = "arn:aws:elasticloadbalancing:us-east-1:490524275591:loadbalancer/app/k8s-default-external-c86c110776/39039dd038e7e910"
  lb_grafana_name        = "a10a64431d34040a293dc42d4f8efe5a-777604357.us-east-1.elb.amazonaws.com"
  lb_grafana_zone        = "Z35SXDOTRQ7X7K"
  cloudfront_dns         = module.cloudfront.cloudfront_domain_name
  cloudfront_hosted_zone = "Z2FDTNDATAQYW2" // There is one static zone on aws for this
  domain                 = "external-${local.environment}.reecedev.us"
}


##################################
#  SES                           #
##################################
# module "ses" {
#   source      = "../../modules/ses"
#   environment = local.environment
#   zone_id     = "Z09662621LWH3VC84LW8I"
#   domain      = "reecedev.us"
# }


##################################
#  Product Data ETL              #
##################################
module "product_data_etl" {
  source                          = "../../modules/product-data-etl"
  environment                     = local.environment
  lambda_function_extract_name    = "etl_extract"
  lambda_function_index_name      = "etl_index"
  lambda_function_extract_name_bk = "bath_kitchen_etl_extract"
  lambda_function_index_name_bk   = "bath_kitchen_etl_index"
  step_function_name              = "product_etl"
  step_function_name_mincron      = "mincron-etl"
  step_function_name_bk           = "bath_kitchen_etl"
  s3_bucket_name                  = "reece-external-snowflake-etl-extract"
  s3_bucket_name_mincron          = "reece-external-mincron-etl-extract"
  s3_bucket_name_bk               = "reece-external-bath-kitchen-etl-extract"
  s3_bucket_name_lambda_deps      = "reece-external-etl-lambda-deps"
  private_subnets                 = module.vpc.private_subnets
  vpc_id                          = module.vpc.id
}

##################################
#  RDS                           #
##################################
module "rds" {
  source                    = "../../modules/rds"
  environment               = local.environment
  db_subnet_group_name      = module.vpc.db_subnet_group_name
  vpc_id                    = module.vpc.id
  retention_period_in_days  = 35
}

##################################
#  Elasticache                   #
##################################
module "elasticache" {
  source      = "../../modules/elasticache"
  environment = local.environment
  vpc_id      = module.vpc.id
  vpc_cidr    = module.vpc.vpc_cidr
  subnet_ids  = module.vpc.private_subnets[*].id
  name        = "external"
}

##################################
#  Prometheus | Grafana | Jaeger #
#  need to be created after ACM
#  and EKS. See module for details
##################################
module "monitoring" {
  source             = "../../modules/monitoring"
  environment        = local.environment
  cluster_id         = module.eks.cluster_id
  cert_arn           = module.certificates.cert_arn
  availability_zones = module.vpc.availability_zones
}
##################################
#  S3                           #
##################################
module "s3" {
  source               = "../../modules/s3"
  environment          = local.environment
  bucket_name          = "reecemobilemaxiosapp"
  prevent_destroy      = true
}