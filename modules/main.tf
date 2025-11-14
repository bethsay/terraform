module "file-gen" {
  source = "./child_module"
  env    = ["dev", "stage", "qa", "edge", "demo", "prod", "dr"]
  component = {
    "client"   = "Welcome client. You will recieve data from frontend and you can repond to it"
    "frontend" = "Client has connected. Serve content. Forward responses to backend"
    "backend"  = "Data from frontend will be processed here"
  }
}

output "file-gen" {
  value = {
    count = module.file-gen.count
    path  = module.file-gen.path
    items = module.file-gen.items
  }
}
