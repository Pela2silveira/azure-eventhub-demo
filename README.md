# azure-eventhub-demo

# Introduction 
Esta es una POC para el manejo de logs en Azure

Todo el ecosistema es privado, se compone de fluentbit para la ingesta, EventHub como un kafka intermedio para el encolamiento de logs y Data Exporer para el almacenamiento final y consulta utilizando KQL.

Este ecosistema utiliza un docker con fluent en una VM para levantar métricas dummy en un resource group aparte.

# Getting Started
1.	El proyecto está repartido en tres carpetas con código terrafom, se ejecutan en órden con terraform init / plan / approve
2.	En la carpeta etapa_3 hay un script para recuperar la key de la vm que corre el fluent, ademas un README con el comando para entrar en la VM, una vez dento se puede correr un "docker logs fluent" para ver si se conectó bien. 
3.	En el portal de azure se pueden realizar queries a la tabla logs para ver el resultado. Nótese que se debe whitelistear la ip del usuario que quiere realizar el proceso. Además de habilitar el permiso en la BD.


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
In etapa_3 folder
 . ./post-apply.sh

if you want to try this scripts:
export the outputs of etapa_1
cd scripts
sh instructions.sh
python3 producer.py
python3 consumer.py
```
