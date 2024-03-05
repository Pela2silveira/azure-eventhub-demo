data "terraform_remote_state" "etapa_1" {
  backend = "local"

  config = {
    path = "../etapa_1/terraform.tfstate"
  }
}