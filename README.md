[![Build Status](https://secure.travis-ci.org/xively/airqualityegg.com.png)](http://travis-ci.org/xively/airqualityegg.com)

# Airqualityegg.com

The Air Quality Egg dashboard is a [Ruby](http://www.ruby-lang.org/), 
[Sinatra](http://www.sinatrarb.com/) app that provides the web UI for the
[Air Quality Egg website](http://airqualityegg.com).

## Development

### Prerequisites

* A working Ruby environment. The app should work in all common flavours
  of ruby (1.8.7, 1.9.2, 1.9.3, Rubinius, jruby)

### Add environment variables to .env file

```bash
# Sample .env file
PRODUCT_ID=xxxxxx
API_KEY=xxxxxxx
```

The values in this file are required to interact with Xively, but some value
for each environment variable is required to boot the app locally, so initially
just create the file with dummy contents. Note that this means your local app 
won't be able to actually interact with Xively, but you will be able to view the 
AQE site running locally.

### Install bundler gem

`gem install bundler`

### Install all gem dependencies

`bundle install`

### Start webserver

`bundle exec foreman start`

Visit http://localhost:5000, and you should see a version of the AQE 
website running locally on your machine.

### Running the tests

`bundle exec rake`

## Contributing

Please see our [Contributing guidelines](https://github.com/xively/airqualityegg.com/blob/master/CONTRIBUTING.md).

## License

Please see [LICENSE](https://github.com/xively/airqualityegg.com/blog/master/LICENSE) for licensing details.

## Support

Please file any issues at our [Github issues page](https://github.com/xively/airqualityegg.com/issues).
For general disussion about the project please go to the [Air Quality Egg group](https://groups.google.com/forum/#!forum/airqualityegg).

