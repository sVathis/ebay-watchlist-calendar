# eBay Watchlist as iCalendar (Azure Function)


This [Azure Function](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview) creates an [iCalendar](https://icalendar.org/) that contains the auction expiration date/time of the items in your [eBay Watchlist](https://www.ebay.com/myb/WatchList), as events. You can subscribe to this iCalendar from your favorite calendaring program and have calendar entries created on every watchlist item auction ending, so you can e.g. set alarms accordingly.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See [Cloud deployment](#Cloud-deployment) for notes on how to deploy the project on Azure.

### Prerequisites

In order for this service to work you will need:

 1. A valid [Azure subscription](https://azure.microsoft.com/en-us/)
 2. An [eBay developer account](https://www.developer.ebay.com/)

You will also need the following software installed in your dev enviroment:

 1. [Python 3.x](https://www.python.org/downloads/)
 2. [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest)
 3. [Azure Function Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local)
 4. [Node.js](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm) (required for Azure Functions Core Tools)

## Installing

### eBay API access

To use eBay’s APIs, you need to register with the [eBay developer program](https://developer.ebay.com/) and create a unique title for your application, using [this form](https://developer.ebay.com/my/keys).

Generate a unique set of keys (a keyset) that will serve as your application’s credentials:

 * App ID/Client ID: This uniquely identifies your application.

 * Dev ID: This uniquely identifies your developer account.

 * Cert ID/Secret: This is a client secret (like a password for your App ID), which should be kept confidential.

eBay supports two environments:
 * Production: This is the eBay website, where eBay members buy and sell items.
 * Sandbox: This is a test version of the eBay website, where developers can simulate buying and selling items

Generate a separate keyset for each environment, using [this form](https://developer.ebay.com/my/keys). The App IDs (Client IDs) will be different. The Dev ID will be shared. Your keyset will be stored here in your  [eBay developer account](https://developer.ebay.com/).

After you generate your keyset, use the User Tokens option next to your App ID to learn more about tokens and how to create them. For APIs like the Trading API, used in this application, I recommend that you use OAuth; but eBay's older Auth 'n' Auth process is also still available.

You should copy and save your Production enviroment keys locally in the [credentials.sh](credentials.sh) file, for use in this application, as follows:

```
EBAYAPPID=<App ID>
EBAYDEVID=<Dev ID>
EBAYCERTID=<Cert ID>
EBAYTOKEN=<User Token>
```

These credentials will be privatly uploaded to Azure as [App settings](https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings) by the [bootstrap.sh](bootstrap.sh) script.

### Python enviroment

It is stongly advised to create a local Python virtual environment and install all required Python modules there:

```shell
$ python -m venv .venv
```
Activate the virtual environment by runing the `activate` script inside the `.venv/Scripts/` directory.

Install locally all required modules as follows:
```shell
$ pip install -r requirements.txt
```

## Deploying

First you will need to set the values of the following variables in [definitions.sh](definitions.sh) file:

```shell
rgName=<Resource Group Name>
storageName=<Storage Account Name>
functionAppName=<FunctionApp Name>
location=<Location>
```

*Note*: `rgName` and `storageName` should be unique across your Azure subscription. `functionAppName` should be unique across Azure(!). `location` should be an [Azure Location](https://azure.microsoft.com/en-us/global-infrastructure/locations/) preferably be as close as possible to your physical location. 

### Local deployment

Before running this function localy for the **first time**, you will need to execute the [bootstrap.sh](bootstrap.sh) script:

```shell
$ ./bootstrap.sh
```

This script will:
 * create an Resource Group where all resources required for this function will belong
 * create a Storage Account, required by the Azure Functions framework
 * create the Azure Function App
 * create a Key Vault
 * securely upload to Key Vault all eBay credentials 
 * will fetch these credentials as [App settings](https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings) locally so that can be used for local function execution. However, per [this bug](https://github.com/Azure/azure-functions-host/issues/3907) Key Vault secrets can not be referenced locally, for now.

After bootstraping, the Azure Function can be executed locally (always within your Python virtual environment) as follows:

```shell
$ func host start

Hosting environment: Production
Content root path: \ebay-watchlist-calendar
Now listening on: http://0.0.0.0:7071
[15/1/2020 9:10:12 πμ] Application started. Press Ctrl+C to shut down.
 INFO: Received WorkerInitRequest, request ID <removed>

Http Functions:
[15/1/2020 9:10:12 πμ]  INFO: Received FunctionLoadRequest, request ID: <removed>, function ID: <removed>
        watchlist: [GET,POST] http://localhost:7071/api/watchlist

```

While the Azure Function is running locally, you can send an HTTP request towards the URL above ([http://localhost:7071/api/watchlist](http://localhost:7071/api/watchlist)) in order to retrieve your eBay Watchlist in iCalendar format:

```shell
$ wget -4  http://localhost:7071/api/watchlist
--2020-01-15 11:17:37--  http://localhost:7071/api/watchlist
Resolving localhost (localhost)... 127.0.0.1
Connecting to localhost (localhost)|127.0.0.1|:7071... connected.
HTTP request sent, awaiting response... 200 OK
Length: unspecified [text/calendar]
Saving to: ‘watchlist’

watchlist                               [ <=>                                                                      ]  11.60K  --.-KB/s    in 0s

2020-01-15 11:17:40 (35.2 MB/s) - ‘watchlist’ saved [11882]

$ file watchlist
watchlist: vCalendar calendar file
```

### Cloud deployment

In order to publish to Azure, execute the [deploy.sh](deploy.sh) script:

```shell
$ ./deploy.sh
Creating archive for current directory...
Performing remote build for functions project.
Deleting the old .python_packages directory
Uploading 15,32 MB [##############################################################################]
Remote build in progress, please wait...

Deployment successful.
Remote build succeeded!
Syncing triggers...
Functions in ebaywatchlistfunc:
    watchlist - [httpTrigger]
        Invoke url: https://ebaywatchlistfunc.azurewebsites.net/api/watchlist?code=<unique_code>
```

After succesfull deployment you can send HTTPS request towards the `Invoke url` above in order to retrieve your eBay Watchlist in iCalendar format. You can use this `Invoke url` to subscribe to this iCalendar in your favorite calendaring platform, e.g. [Google Calendar](https://support.google.com/calendar/answer/37100?co=GENIE.Platform%3DDesktop&hl=en) or [Outlook](https://support.office.com/en-us/article/Import-or-subscribe-to-a-calendar-in-Outlook-on-the-web-503ffaf6-7b86-44fe-8dd6-8099d95f38df).

## Built With

 * [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest)
 * [Azure Function Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local)
 * [Node.js](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm) (required for Azure Functions Core Tools)
 * [Python 3.x](https://www.python.org/downloads/)
 * [eBay API SDK for Python](https://github.com/timotheus/ebaysdk-python)
 * [Python ICS](https://github.com/C4ptainCrunch/ics.py)

## Authors

* **Spiros Vathis** - github: [sVathis](https://github.com/sVathis) - Twitter: [@svathis](https://twitter.com/svathis)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

