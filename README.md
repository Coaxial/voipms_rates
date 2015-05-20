VoipmsRates
==========================

This [Adhearsion](adhearsion.com) plugin fetches the per minute rate from voip.ms for any phone number. It uses the
public [voip.ms API](https://voip.ms/rates/xml.php).

> Note that this is intended to be used within an Adhearsion app. If you require this gem to use anywhere else than an
> Adhearsion app, it will probably not work out of the box.

# Installation
Add `gem 'voipms_rates'` to your Gemfile and run `bundle install`.

# Configuration
The gem will fetch the standard rate by default. If you have changed the routing settings in your voip.ms account
(voip.ms > Main Menu > Account Settings > Account Routing) and use premium routing for Canadian and/or international
numbers, you can override the defaults by adding the following lines to your app's `config/adhearsion.rb`:

```ruby
##
# voipms_rates settings override
config.voipms_rates.canada_use_premium = true # default value is false
config.voipms_rates.intl_use_premium   = true # default value is false
```

Alternatively, you can set the `AHN_VOIPMS_RATES_CANADA_USE_PREMIUM` and `AHN_VOIPMS_RATES_INTL_USE_PREMIUM`
environment variables to `true`.

# Usage
In your app's controller:

```ruby
include VoipmsRates::ControllerMethods

def run
  @rate = get_rate_for(call.to)
  say "This call will cost #{@rate} USD per minute."
  end
end
```

## `get_rate_for`
Expects one argument, either the [E.164](http://en.wikipedia.org/wiki/E.164) phone number without `+` or the `call.to`
string directly from the controller.

Example of an E.164 phone number:

Consider the following US number: `(555) 123-4567`. The US country code is `+1`, which we add to the beginning of the
phone number. Thus, we get `+1 (555) 123-4567`. We then strip any special chracters and the leading `+` whih results in
`15551234567`. This is the number `get_rate_for` expects.

The method can also handle standard SIP strings. For the sample US phone number above, that would be
`sip:15551234567@127.0.0.1`. This string is stored in `call.to` within the controller for the dialled number.

# License
MIT, see the `LICENSE` file within the repo.
