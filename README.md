Work in progress.

TODO:

- Default start page.
- Better parameterization in the makefile.
- Better readme.
- init scripts:
    - For Pi that auto-start and take down the RTMP streamer.
    - ~~For AWS that auto-start and take down the RTMP server.~~
    - For Pi that auto-start and take down the local RTMP server.
    - On AWS, a default page that includes a js player?
- Better AWS install instructions, including:
    - Opening the correct ports.
    - Startup script.



Installing the server on AWS Linux:

```
sudo yum install -y git
git clone https://github.com/BrianEnigma/nginx-rtmp.git
cd nginx-rtmp
sudo make awsprep
make
sudo make installserveraws
sudo /etc/init.d/nginx start
```
