Work in progress.

TODO:

- ~~Default start page (with web player),~~ master m3u8.
- Better parameterization in the makefile.
- Better readme.
- init scripts:
    - For Pi that auto-start and take down the RTMP streamer.
    - ~~For AWS that auto-start and take down the RTMP server.~~
    - ~~For Pi that auto-start and take down the local RTMP server.~~
    - ~~On server, a default page that includes a js player?~~
- Better AWS install instructions, including:
    - Opening the correct ports.
    - ~~Startup script.~~



Installing the server on AWS Linux:

```shell
sudo yum install -y git
git clone https://github.com/BrianEnigma/nginx-rtmp.git
git submodule init
git submodule update
cd nginx-rtmp
sudo make prepaws
make
sudo make installserveraws
sudo /etc/init.d/nginx start
```



Installing the server on the Raspberry Pi:

```bash
sudo apt-get install -y git
git clone https://github.com/BrianEnigma/nginx-rtmp.git
git submodule init
git submodule update
cd nginx-rtmp
sudo make preppi
make
sudo make installserverpi
sudo /etc/init.d/nginx start
```

