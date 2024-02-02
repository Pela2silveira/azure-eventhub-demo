# azure-eventhub-demo

## instructions
```
Create your tfvars file:
subscription_id = "xxxxxx"
client_id       = "yyyyyy"
client_secret   = "rrrrrrr"
tenant_id       = "cccccc"

client     = "cliente"
project    = "event-hub"
env        = "demo"
repository = "https://github.com/Pela2silveira/azure-eventhub-demo"
```


```
terraform init
terraform apply --auto-approve
 . ./post-apply.sh
cd scripts
sh instructions.sh
python3 producer.py
python3 consumer.py
```
