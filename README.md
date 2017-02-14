Work in progress.

TODO:

- Default start page.
- Better parameterization in the makefile.
- Better readme.
- init scripts:
     - For Pi that auto-start and take down the RTMP streamer.
     - For AWS that auto-start and take down the RTMP server.
     - For Pi that auto-start and take down the local RTMP server.


Installing the server on AWS Linux:

```
sudo yum install -y git
#git clone git@github.com:BrianEnigma/nginx-rtmp.git
git clone https://github.com/BrianEnigma/nginx-rtmp.git
cd nginx-rtmp
sudo make awsprep
make
make installserveraws
sudo /etc/init.d/nginx start
```

