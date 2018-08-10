# RACV Fuel Price Push Notifications

Get the latest RACV fuel prices delivered as push notifications to your phone. Works via [Heroku](https://www.heroku.com) + [IFTTT](http://ifttt.com).

<img src="https://i.imgur.com/yu7Vgty.jpg" width="50%" alt="Push notification">

## Setup

**You'll need to have an account with [Heroku](https://signup.heroku.com/) and [IFTTT](https://ifttt.com/join). Sign up to these free services first before continuing.**

1. [Create a new applet](https://ifttt.com/create) via IFTTT
2. Set _this_ to [Webhooks](https://ifttt.com/create/if-receive-a-web-request?sid=4):

    <img src="https://i.imgur.com/2pKLr75.png" width="25%" alt="Webhooks">
    
    If you haven't activated Webhooks before, be sure to go to the [Webhook settings](https://ifttt.com/services/maker_webhooks/settings) and make a note of your Webhook key as you will need it for Step 8:

    <img src="https://i.imgur.com/mvbYid2.png" width="50%" alt="Webhook key">

3. Choose an event name, such as `racv_fuel_price_updated`. _This needs to be the same value you use in Step 8._
4. Set _that_ to [Notifications](https://ifttt.com/create/if-receive-a-web-request-then-if_notifications?sid=14), and choose the rich notification:

    <img src="https://i.imgur.com/uhr0v8b.png" width="25%" alt="Rich notification">

5. Set the following details:

    i. **Title** - `Fuel prices are {{Value1}}`
    
    ii. **Message** - `Don't pay above {{Value2}}¢. Prices are {{Value3}} than yesterday.`
    
    iii. **Link URL** - `https://www.racv.com.au/on-the-road/driving-maintenance/fuel-prices.html`
    
6. Create the action, review and finish.
7. Go to wherever you have cloned this repo, and create and push the repo as a new Heroku app:

    ```
    $ cd /path/to/this/repo
    $ heroku create racv-fuel-notifications
    $ heroku git:remote -a racv-fuel-notifications
    $ git push heroku master
    ```
    
8. Set the following Heroku environment variables from the values you noted in Step 2 and 3:

    ```
    $ heroku config:set IFTTT_TRIGGER_NAME=racv_fuel_price_updated
    $ heroku config:set IFTTT_TRIGGER_NAME=[YOUR WEBHOOK KEY]
    ```
    
9. Test to see if it works. Download the IFTTT to your smartphone, sign in and then run:

    ```
    $ heroku run fuelprices.rb
    ```

    You can then force-check the app to see if it recieved the notification by tapping the _Check Now_ under the My Applet's settings:
    
    <img src="https://i.imgur.com/WEec4lo.png" width="25%" alt="Check now">
    
10. Add the Heroku scheduler to your app and schedule your event to run every day at UTC 11pm, which is 9am AEST (obviously you can set this to whenever you want):

    ```
    $ heroku addons:create scheduler:standard
    $ heroku addons:open scheduler
    ```
    
    Use the command `ruby fuelprice.rb` to run:
    
    <img src="https://i.imgur.com/tiadfFm.png" width="50%" alt="Fuelprice Scheduler">
    
11. Sit back, relax and enjoy whether or not you should fill up in the morning rather than waiting for petrol prices to unexpectedly double out of nowhere.
