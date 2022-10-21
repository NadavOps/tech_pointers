# Terraform

### Table of Content
* [Terraform commands](#git-commands)

* [Links](#links)

## Terraform commands
```
terraform validate 
terraform plan 
terraform plan -out=tfdev_plan -var env=dev 
terraform apply 
terraform show 
terraform taint; command manually marks a Terraform-managed resource as tainted, forcing it to be destroyed and recreated on the next apply. 
terraform untaint 
terraform console 
terraform workspace; didn’t played with it but seems somewhat like git branches. With that said IT IS NOT GIT in the meaning of versioning 
terraform workspace show; the current running workspace 
terraform workspace list; list all available workspaces 
terraform workspace select workspace_name; changes to the desired workspace 
With workspaces terraform will create the "terraform.tfstate.d" directory where each workspace tfstate will be saved in its own directory
```

```
Using system environment variables in terraform: (require testing- I might have understood it slightly different
export TF_VAR_variablename=variablevalue
Can be tested with terraform console -> lookup(var.variablename)
```


## Links
* [Set multiple ssh keys for multiple github accounts](https://gist.github.com/jexchan/2351996).
