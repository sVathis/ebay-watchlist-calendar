
az group create --name svathis-ebay --location westeurope
az storage account create --name svathisebay --location westeurope --resource-group svathis-ebay --sku Standard_LRS
az functionapp create --name svathis-ebay --os-type Linux --storage-account svathisebay --consumption-plan-location westeurope --resource-group svathis-ebay --runtime python
func init --source-control --worker-runtime python --language python
func azure storage fetch-connection-string svathisebay
func new --name watchlist -l python --template "Http Trigger"
func azure functionapp publish svathis-ebay --nozip --python