# Satori Fitness Demo

![Satori Image](satori-logo-banner.jpg)

The Satori platform transfers large amounts of live data at high
speed. It uses a publish/subscribe model: Apps *publish* data
as *messages* to *channels*. Apps also *subscribe* to channels so they
can listen for messages and retrieve them when they arrive. Based on
WebSocket, the platform transfers messages of almost any size with
almost no delay.

To publish to channels, subscribe to channels, and retrieve data,
you use the high-level Satori *RTM SDK* API libraries. For
special cases, Satori also offers a low-level library called the
*RTM API*.

The Satori platform also provides ways to customize messages:
* *Streambots* subscribe to a channel and execute custom code
on each incoming message. You create streambots in Java.
* *Streamviews* select, transform, or aggregate messages from a
subscribed channel based on criteria you define in *Stream SQL*,
a Satori variant of SQL.

# RealFitness apps
The Satori **RealFitness** demo apps for Apple Watch and iPhone
use the Satori platform to implement a simple workout tracker:
* To see a demo of the apps, follow the steps in the section **Run the
demo**.
* To learn how the apps work, see the section **App overview**.

# Run the demo
You can run the demo apps locally, either on devices or in
Xcode simulators. Satori provides the source files for the apps on
GitHub.

**Note:** Unlike other Satori demo apps, the fitness demo doesn't have
an online version.

The source includes:
* Objective-C code for the iPhone and the Apple Watch apps
* Build files for Xcode
* Configuration files for 3rd-party frameworks
* Satori API libraries

## Prerequisites
To build and run the demo apps, you need:
* Xcode 8.3.3 or later
* The [Carthage](https://github.com/Carthage/Carthage) framework manager
for Cocoa:
    * The section "Installing Carthage" on the repo home page lists
    the installation options.
    * The 3rd-party frameworks you need are already configured in the
    source. Carthage uses the configuration to build and install the
    frameworks.
* An iPhone simulator or iPhone with iOS 10.0 or later.
* An Apple Watch simulator or Apple Watch Series 2 with WatchOS 3.1 or
later.


**Notes:**
* To run the demo on devices, you need an Apple Developer License
linked to Xcode.
* The demo app UI is optimized for iPhone 6, 6s, 7 and 7s.
* The watch app works only on a 42mm Apple Watch
Series 2 or equivalent simulator.

## Create the apps

### Get credentials from Satori
To use the Satori platform, you need a Satori account and project:
1. Get for a Satori account at
[https://developer.satori.com](https://developer.satori.com). If you
already have an account, just sign in.
2. From the dashboard, navigate to the **Projects** page.
3. Click **Add a project**, then enter the name "fitness" and click
**Add**.
4. Satori displays an `appkey` and `endpoint` for your project. These
credentials let the apps connect with Satori. Make a copy of them.
5. Click **Save** to save the project.

### Get the source
Clone the demo source files from GitHub:

    git clone git@github.com:satori-com/fitness.git
    cd fitness

### Build the apps
1. Run `carthage update` to build and install the 3rd party frameworks
used by the apps.
2. In Finder, double-click `RealFitness.xcodeproj` to
open the demo app project in Xcode.
3. In Xcode Project Navigator, edit `RealFitness > Constants.h` and
replace `YOUR_ENDPOINT` and `YOUR_APPKEY` with the values you copied
from your Satori project page.
4. In Xcode, build the `RealFitness` scheme.

## Start the apps

### Start the apps on devices

1. Install the apps on your hardware.
    * For an optimum experience, use an iPhone 6, 6s, 7 or 7s.
    * The Apple Watch must be a 42mm Series 2.
2. On your Apple Watch, click the **Home** button, then click the
**RealFitness** icon to open the app.
3. On your iPhone, open the **RealFitness** app.

### Start the apps in simulators
1. To get the best UI experience, set up Xcode to use an
iPhone 6, 6s, 7 or 7s simulator.
2. Ensure that you pair the iPhone simulator with an Apple Watch Series
2 42mm simulator.
3. In Xcode, run the demo using your simulator scheme. When you first
run the apps, the simulators may take a few seconds to start.

## Use the apps
1. In the watch app, click one of the goals to see your heart rate (the
simulator version displays a simulated rate).
3. The **RealFitness** iPhone app displays the data from the watch
app.
4. Click **Social** at the bottom of the iPhone app. The new screen
displays all active users and their workout data. In the demo,
you're the only active user.
5. Click on your name on the **Social** page to see the **My Activity**
page.

# App overview

## Watch app
* **RealFitness** for the Apple Watch retrieves heart rate and other
workout data from the Apple HealthKit framework.
* In the app, users choose a workout goal. For that goal, the app sets a
target heart rate zone.
* The watch app sends the workout goal and workout data to the iPhone
the watch is linked to.
* The watch app also displays heart rate, workout goal, and performance
to target on its main screen. Users can swipe to the right-hand screen
to see more detailed data.
* Users can stop their workout by swiping to the left-hand screen and
clicking **Stop run**.

## iPhone app
* **RealFitness** for iPhone receives the workout goal and workout data
from the watch app. It displays this information on its main screen,
which also shows an animated runner that moves faster or slower
depending on the user's performance to goal.
* The app publishes messages containing the workout data to a
channel. It subscribes to the same channel, so it can
display workout data from messages send by other app users who
are currently working out (the **active** users).
* Active users can also send reaction messages to each other in a
separate channel.

The Satori fitness demo app uses the following frameworks and APIs:
* [Apple HealthKit Framework](https://developer.apple.com/healthkit/)
* [Apple WatchKit Framework](https://developer.apple.com/documentation/watchkit)
* [iOS Wrapper for Satori C SDK](https://github.com/satori-com/satori-rtm-sdk-c#ios-wrapper)

# iPhone app details

## Channels
* The app publishes workout data to a channel called `Fitness`. It also
subscribes to this channel, so that the app instance for each active
user can retrieve and display results from other active users.
* The app also publishes reaction messages. Each app instance has its
own unique *`userId`* value, which it uses to create a
*`userId`*`-Reactions` channel. To send a reaction
message to another user, the app instance publishes it to the
appropriate <code><i>userId</i>-Reactions</code> channel. Reaction
messages let active users encourage each other with emoticons.

## Streamiews
[**Streamviews**](https://www.satori.com/docs/using-satori/filters)
(formerly called *Filters*) filter and aggregate incoming
messages that an app is subscribed to.

### userId streamview
The app subscribes to the `Fitness` channel using a streamview that
selects messages that have the user's *userId*. This lets the app
filter out its own messages when it displays workout data on the
**Social** screen.

### Aggregation streamview
The app also uses an aggregation streamview to manage the data rate in
the channel. The iPhone app publishes live data to the `Fitness`
channel every few milliseconds, so other app instances can receive a
large number of messages every second.

If the iPhone app tried to update the **Social** screen many times a
second, the UI could lose responsiveness. To keep the
UI fluid, the iPhone app uses a streamview to aggregate messages.

When the app subscribes to the `Fitness` channel, it selects a
streamview "period" of 1 second. Message values are averaged over a
period of 1 second before the iPhone app receives them from the
channel.

To learn more about aggregation, see the section
[**Aggregate Views**](https://www.satori.com/docs/using-satori/filters#aggregate-filter)
in the Satori Docs topic [**Views**](https://www.satori.com/docs/using-satori/filters).

# Next steps
The **RealFitness** apps demonstrate the following tasks:
* Building a WatchOS app based on Apple HealthKit
* Sending data from an Apple Watch to an iPhone
* Publishing, subscribing to, and retrieving live data in an iPhone app
using the Satori platform
* Selecting and aggregating messages using streamviews.

Try extending the apps. Here are some ideas:
* Extend the functionality of the apps to track even more workout
statistics such as step count or cycling distance.
* Build a health tracker by adding other compatible biometric data
collection devices that let health care providers track patient health
remotely.

# Further reading
* [Satori Developer Documentation](https://www.satori.com/docs/introduction/new-to-satori): Documentation for the entire Satori platform
* [Satori C SDK](https://github.com/satori-com/satori-rtm-sdk-c): The Satori C RTM SDK that accesses the Satori platform
