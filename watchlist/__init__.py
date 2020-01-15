import logging

import azure.functions as func

from ebaysdk.trading import Connection as Trading
from ebaysdk.exception import ConnectionError
import json
from collections import namedtuple
from ics import Calendar, Event
import os


def main(req: func.HttpRequest) -> func.HttpResponse:

    try:
        api = Trading(appid=os.environ["EBAY_APPID"],
                      devid=os.environ['EBAY_DEVID'],
                      certid=os.environ['EBAY_CERTID'],
                      token=os.environ['EBAY_TOKEN'],
                      siteid=os.environ['EBAY_SITEID'],
                      config_file=None)

        response = api.execute('GetMyeBayBuying',  {'DetailLevel': 'ReturnAll'})
        r = response.dict()

        r_named = namedtuple("object",r.keys())(*r.values())
        watchlist = r_named.WatchList["ItemArray"]["Item"]
        c = Calendar()
        for item in watchlist:

            event = Event()
            event.uid = item["ItemID"]
            event.name = item["Title"]
            event.url = item["ListingDetails"]["ViewItemURL"]
            event.begin = item["ListingDetails"]["EndTime"]
            event.end = event.begin

            price = "N/A"
            if item["SellingStatus"] is not None:
                try:
                    price = "{} {}".format(item["SellingStatus"]["ConvertedCurrentPrice"]["_currencyID"],item["SellingStatus"]["CurrentPrice"]["value"])
                except KeyError as e:
                    price ="{} {}".format(item["SellingStatus"]["CurrentPrice"]["_currencyID"],item["SellingStatus"]["CurrentPrice"]["value"])
                    pass

            event.description = "{}\nPrice: {}\nURL: {}".format(event.name,price,event.url)

            c.events.add(event)

        s = ''.join(str(l) for l in c)
        return func.HttpResponse(s,mimetype="text/calendar", charset="utf-8", headers= {"Content-Disposition":"attachment; filename=\"ebay-watchlist.ics\""})
    except ConnectionError as e:
        return func.HttpResponse(
            str(e),
            status_code=400
        )