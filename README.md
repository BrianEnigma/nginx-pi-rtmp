# nginx-pi-rtmp

The nginx Pi RTMP project gives you a turnkey solution to getting video from the Raspberry Pi's camera out to your browser or mobile phone. It offers two hosting options for the server: one on the Raspberry Pi itself — meaning you can get to it only from your local area network, unless you do some firewall magic — and the other allowing your Pi to stream to an Amazon Web Services (AWS) Elastic Compute Cloud (EC2) instance, so that the world can access your stream. With the AWS server, everything is turnkey once you've acquired the server, but the initial requisition and firewall settings takes some manual work.

I created this project because I have a bird feeder that I thought would be fun to stream video from, but didn't want to invest in a fancy home security camera system. Routing 5V to a Raspberry Pi and letting it do the camera and WiFi seemed like a cheap way to do this.

This project is copyright 2017 by [Brian Enigma](https://netninja.com/about/). It is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/). The underlying web server is [nginx](https://www.nginx.com/resources/wiki/) running in a sandbox with the [RTMP plugin](https://github.com/arut/nginx-rtmp-module). The built-in player uses JavaScript from [jQuery](http://jquery.com/) and the [hls.js project](https://github.com/dailymotion/hls.js).

## Requirements

The project has two pieces. The first is the streaming client, which takes video from the Pi camera and pushes it to a streaming server. The client has the following prerequisites:

- [Raspberry Pi](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/), preferably the model 3 B
- [Raspberry Pi camera module](https://www.raspberrypi.org/products/camera-module-v2/), preferably the v2
- It has been tested with the January 2017 [Raspbian Jesse-Lite](https://www.raspberrypi.org/downloads/raspbian/) operating system release, but will presumably work with other versions of Raspbian.

The server piece requires one of the following, depending on whether you want to host on the Pi itself or up in the cloud:

- The January 2017 [Raspbian Jesse-Lite](https://www.raspberrypi.org/downloads/raspbian/) operating system (but presumably other versions will work).
- _OR_ An AWS EC2 instance running the Amazon Linux AMI. The [t2.micro](https://aws.amazon.com/ec2/instance-types/) instance type is plenty for this lightweight server, plus is [eligible as a free tier](https://aws.amazon.com/free/faqs/) for new customers.
  - Optionally, you might use [Elastic IP](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html) and/or [Route 53](https://aws.amazon.com/route53/) to give your server a static IP or memorable domain name.

It also assumes some amount of basic Linux proficiency: shelling into a server (including ssh with a key file, for the AWS variation), navigating the filesystem, running commands.

## Theory of Operation

- TODO: client side
- TODO: server side
- TODO: Linux security, sandboxed nginx, /opt/nginx and /tmp/hls (which is often a ramdisk)



## RasPi Streaming Server Setup

You can choose to stream to a server on the Pi — so that it's only reachable on your local network — or to the cloud via AWS. This section covers the location server option.

I won't cover the installation and first-time setup of Raspbian on the Raspberry Pi. You should install it and use `sudo raspi-config` to expand the filesystem, enable ssh, and enable the camera. You should also have networking of some kind — be it WiFi or wired ethernet. The command `ping -c 5 8.8.8.8` should be able to reach the internet without timeouts or a `no route to host` error.

You will also need [a modern version of ffmpeg](https://ffmpeg.org/download.html). Raspbian does not ship with this. You will have to download and extract ffmpeg (I used ffmpeg-3.2.4). You will need to do the `./configure && make && sudo make install` routine here, with the understanding that the `make` step can take an hour on a Raspberry Pi 3.

Shell into your Raspberry Pi and run the following set of commands, one at a time to ensure they work:

```shell
sudo apt-get install -y git
git clone https://github.com/BrianEnigma/nginx-pi-rtmp.git
cd nginx-pi-rtmp
git submodule init
git submodule update
sudo make preppi
make
sudo make installserverpi
sudo /etc/init.d/nginx start
```

What this does is:

1. Install the `git` client.
2. Use `git` to download the project and its prerequisites (the submodules).
3. Prepare the Pi by installing the necessary build tools and getting the destination folder ready.
4. Build and install the server.
5. Start the server.

At this point, you should be able to go to `http://{your Pi's IP address}:8080`, for example on my network it is `http://10.0.1.23:8080`. There you will see player with the message “ERROR: Could not load manifest” because nothing is streaming to it yet.



## AWS Streaming Server Setup

Because the console user interface occasionally changes, I won't be able to walk you step by step into acquiring an AWS EC2 server. First, you'll need to create an AWS account, if you haven't already. Go to the EC2 dashboard and create a t2.micro instance. Be sure to download the ssh key (it's a `*.pem` file) so that you can log in. Note the public DNS name for the instance. It's probably something like `ec2-99-99-99-99.us-west-2.compute.amazonaws.com`. You will need that for ssh and the web browser.

You will next have to use the sidebar navigation to go into the “Network & Security > Security Groups” control panel. Creating the instance created a Security Group for you with a name like `launch-wizard-1`. You will want to select that, then use the “Inbound” tab at the bottom to open up inbound network connections on the ports we need. Port 22 (ssh) should already be configured. You will want to add 8080 (for the web server) from any source and port 1935 (for RTMP traffic) from any source.

Use your ssh key to log in to your server and run the following commands:

```shell
sudo yum install -y git
git clone https://github.com/BrianEnigma/nginx-pi-rtmp.git
cd nginx-pi-rtmp
git submodule init
git submodule update
sudo make prepaws
make
sudo make installserveraws
```

Next, we will need to restrict publishing security. This will be running on the public internet, and we don't want just anyone pushing a video stream to your server. Edit your nginx configuration with this command:

```shell
nano /opt/nginx/conf/nginx.conf
```

Find the section that looks like this:

```
allow publish 71.237.165.0/24;
deny publish all;
allow play all;
```

That `allow publish…` says only that IP address range can push video to the RTMP endpoint. (Spoiler alert: that's one of my IP address ranges, so probably won't work for you.) You'll need to alter that for your Class C IP address, or change it to `allow publish all` if you don't care about security. But you should care about security.

Finally, start the nginx server with:

```shell
sudo /etc/init.d/nginx start
```

At this point, you should be able to go to `http://{your EC2 instance's DNS}:8080`, for example that might be `http://ec2-99-99-99-99.us-west-2.compute.amazonaws.com:8080`. There you will see player with the message “ERROR: Could not load manifest” because nothing is streaming to it yet.



## Streaming Client Setup

Note that this has the same prerequisites as the Raspberry Pi streaming server setup. You should be able to `ssh` into your Pi and ping the internet.

TODO: finish making the client a turnkey operation.







## Troubleshooting

- **Does your camera work?**
  - On the Pi, can you run `raspistill -o /tmp/test.jpg` and get a picture? Can you run `raspivid -t 5000 -o /tmp/test.264` and get video?
- **Is your nginx running?**
  - On the server (Pi or AWS) you should be able to run `ps ax | grep nginx` and see things like `nginx: master process`. If not, double-check that you have the nginx binary installed in `/opt/nginx/sbin/nginx`. Try running that program by hand to see if error messages appear.
- **Can your browser connect to nginx?**
  - Does going to `http://{your server address}:8080` bring you to a page? If not, double check that nginx is running, that you can ping the server (for the Pi — it's blocked on AWS), and that the ports are open on AWS Security Groups (for the cloud variant). Take a look for oddities in `/opt/nginx/logs/access.log`  and `/opt/nginx/logs/error.log`.
- **Can your streaming client connect to nginx?**
  - If your streaming client is getting connection errors, take a look at the same troubleshooting steps seen above in the browser connection question.



## Task List:

- ~~Default start page (with web player),~~ master m3u8.
- Better parameterization in the makefile.
- ~~Better readme.~~
- init scripts:
    - For Pi that auto-start and take down the RTMP streamer.
    - ~~For AWS that auto-start and take down the RTMP server.~~
    - ~~For Pi that auto-start and take down the local RTMP server.~~
    - ~~On server, a default page that includes a js player?~~
- ~~Better AWS install instructions, including:~~
    - ~~Opening the correct ports.~~
    - ~~Startup script.~~


