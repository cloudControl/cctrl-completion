# Install

In order to install the completion add the following line to your shells' startup:

`source /path/to/cctrl-completion.bash`

# Caching

As of now the `cctrlapp` and `cctrluser` command line tools have no underlying caching enabled.
Therefore the completion has a very simple caching right now. The cache will be filled as it is required on the first call.

The cache lives in the shells' environment.

## Cache warmup

If you are using those tools a lot, you might consider to add `_cctrl_cache_warmup` to your shells' startup.
This will create the cache entries immediately.

## Remove Cache

If you have added a new application or deployment, you should unset the two cache items.

`unset CCTRL_APPS`

`unset CCTRL_DEPLOYMENTS`