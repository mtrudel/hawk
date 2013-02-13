# Hawk

Hawk is a simple iOS ad-hoc distribution tool. Deployments are lightweight,
backed by S3 storage (sourced from your own AWS account), and notifications of
new builds happen via email. Beyond a couple of S3 buckets, the only moving
parts to hawk are local on your machine. Hawk is a lightweight, low-friction way
to make ad-hoc deploys easy.

## Status

Hawk is alpha quality software at this point, although I'm rapidly working
towards firming up a 1.0 release in the next few weeks (by mid Feb 2013). Some
features that will be coming in the near future include

### Planned for 0.3
* Tighter ACL support on uploaded files

### Planned for 0.4
* UDID validation
* Internal refactor

## Installation

Install hawk on your machine by either running `gem install hawk`, or else by
including it in your application's `Gemfile`. Once it's installed run

    $ hawkify

in your application's top-level directory to create a `Hawkfile` (if one doesn't
already exist). Open up `Hawkfile` in your editor of choice and follow the
comments therein to set it up to your liking.

## Usage

Once your `Hawkfile` is customized, you're ready to go. You can create and
deploy an ad-hoc build of your app by running 

    $ hawk

from any folder inside your application. This will do the following:

1. Build your app for distribution (using the `Release` build configuration)
2. Sign your app for ad-hoc distribution (according to the `Release` code signing identity in your project)
3. Upload your app and some associated metadata to S3, using the credentials you
specify in your `Hawkfile`
4. Draft an email with a pre-populated body (once again taken from your `Hawkfile`)
and open it using your local mail application, ready for you to edit and send at
your leisure

Hawk automatically includes any required provisioning profiles inside the
deployed app, so users don't need to do anything beyond clicking on the link
that hawk sends out. There's no client-side app to install, no servers to run,
no accounts to set up. It just works.

## Contributing

Contributions welcome! Fork this repo and submit a pull request (or just open up a ticket and I'll see what I can do).
