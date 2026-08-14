module "network" {
  source = "./network"
}

module "server" {
  source = "./server"

  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
}

module "ecr" {
  source           = "./ecr"
  project_name     = "ivolve"
  repository_names = ["ivolve-auth", "ivolve-roadmap", "ivolve-frontend"]
}

module "eks" {
  source             = "./eks"
  cluster_name       = "ivolve-eks-cluster"
  project_name       = "ivolve"
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  desired_capacity   = 2
  min_size           = 2
  max_size           = 4
}