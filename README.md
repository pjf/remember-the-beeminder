remember-the-beeminder
======================

My own personal tools for integrating RTM and Beeminder.

When running the code, you might find that unless you have RTBM.pm
installed where perl can find it, you'll instead want to use:

    perl -Ilib bin/rtbm-inbox-reporter

You'll also need a ~/.rtbmrc file with your RTM API credentials
that looks like this:

    [RTBM]
    api_key = YOUR API KEY
    api_secret = YOUR API SECRET

In addition, you may also need to jump through an auth step with
WebService::RTMAgent.  In theory you can uncomment the relevant line
in bin/rtbm-inbox-reporter, but I haven't tested that.  Sorry!
(Contributions for a separate auth program would be great.)

The Beeminder API is currently alpha, so this code presumes you've
already got a command-line tool called bmndr in your path which can
be called to submit data points in the following fashion:

    bmndr goal datapoint [comment]

I'm happy to give you mine if the folks at Beeminder HQ tells me that
you're cool.

♥  Paul
