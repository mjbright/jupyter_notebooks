
# Lab Outline

## Online

#### This document
<font color="#f22" >
You can find the most up-to-date version of this document online as 
<br/>
- an [HTML file](https://cdn.rawgit.com/mjbright/jupyter_notebooks/master/2016-Feb_Docker_Build_Lab/2016-Feb_Docker_Build_Lab.html) (http://bit.ly/1T0118e) or as
<br/>
- a [PDF file](https://raw.githubusercontent.com/mjbright/jupyter_notebooks/master/2016-Feb_Docker_Build_Lab/2016-Feb_Docker_Build_Lab.pdf) (http://bit.ly/1QF0XaH)  or as
<br/>
- a [Jupyter](http://www.jupyter.org) notebook at [2016-Feb_Docker_Build_Lab](https://github.com/mjbright/jupyter_notebooks/blob/master/2016-Feb_Docker_Build_Lab/).
</font>

This notebook is runnable in a Jupyter installation with the bash_kernel installed.

Although that is not the subject of this lab, if you want to create your own environment in which to run this lab with Docker components already installed (and even Jupyter/bash_kernel), refer to the README.md [here](https://github.com/mjbright/jupyter_notebooks/blob/master/2016-Feb_Docker_Build_Lab/)

<br/><br/><br/>
<center><font size=-1 color="#77f">
    <i class="fa-linkedin fa-2x fa"> [mjbright](https://www.linkedin.com/in/mjbright)</i>,&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <i class="fa-github fa-2x fa"> [mjbright](https://github.com/mjbright)</i>,&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <i class="fa-twitter fa-2x fa">[@mjbright](http://twitter.com/mjbright)</i>,
</font></center>


<a name="TOP"></a>
## Lab-Description
[TOP](#TOP)


We first need to recuperate the source code examples:

<font color="#f22">
### Lab Start
</font>
Start this lab by first performing the below step:


```bash
## Lab Start:

rm -rf ~/src

cd
git clone https://github.com/mjbright/docker-examples src

./src/START_LAB.sh
```

    Cloning into 'src'...
    remote: Counting objects: 156, done.[K
    remote: Compressing objects: 100% (116/116), done.[K
    remote: Total 156 (delta 64), reused 120 (delta 31), pack-reused 0[K
    Receiving objects: 100% (156/156), 15.60 KiB | 0 bytes/s, done.
    Resolving deltas: 100% (64/64), done.
    Checking connectivity... done.


Then procede with the following sections:

- [1. Introduction](#intro)
- [2. Basic Docker Builds](#builds)
- [3. Creating Small Images](#small-images)
  - [Creating a small binary with C](#small-c)
  - [Creating a small binary with Go](#small-go)
  - [Creating a toolset Docker image containing several executables](#small-push)
  
- [4. Pushing our image to Docker Hub](#small-multi)
  
- [5. Dockerfile best practices](#build-best-practices)

- [6. Using the official 'Language Stack' images](#lang-stacks)
  - [Using a Language Stack (Node.js)](#medium-node)
  - [Using a Language Stack (Python)](#medium-python)
  
- [7. Using Compose](#compose)
  - [Building complex systems with Compose](#Compose)
  - [Rails example with Compose](#Rails-Example-with-Compose)
  
- [8. Building Docker](#building-docker)
  - [Building Docker with Docker](#Building-Docker-with-Docker)

[References](#References)

<hr/>
  
### Overall description of the lab steps

**NOTE: All lab steps can be considered optional, attendees may perform them in order, or jump to the section of interest to them (to get to the more complicated steps)**


<a name="1.intro" />
# Introduction
## A refresh on Docker concepts

You may want to skip this section if you have already run the introductory lab.

Look at what docker version you are running.
Note that the 'docker version' command reports the local client version as well as the server (docker engine) version.


```bash
docker version
```

    Client:
     Version:      1.10.0-rc2
     API version:  1.22
     Go version:   go1.5.3
     Git commit:   c1cdc6e
     Built:        Wed Jan 27 22:31:21 2016
     OS/Arch:      linux/amd64
    
    Server:
     Version:      1.10.0-rc2
     API version:  1.22
     Go version:   go1.5.3
     Git commit:   c1cdc6e
     Built:        Wed Jan 27 22:31:21 2016
     OS/Arch:      linux/amd64


### Images are image layers

Remember that when we talk of a container image it is really a collection of image layers.

The docker info command provides information about the docker engine, see below.


```bash
docker info
```

    Containers: 0
     Running: 0
     Paused: 0
     Stopped: 0
    Images: 17
    Server Version: 1.10.0-rc2
    Storage Driver: aufs
     Root Dir: /var/lib/docker/aufs
     Backing Filesystem: extfs
     Dirs: 40
     Dirperm1 Supported: false
    Execution Driver: native-0.2
    Logging Driver: json-file
    Plugins: 
     Volume: local
     Network: bridge null host
    Kernel Version: 3.13.0-55-generic
    Operating System: Ubuntu 14.04.2 LTS
    OSType: linux
    Architecture: x86_64
    CPUs: 1
    Total Memory: 1.955 GiB
    Name: vagrant-ubuntu-trusty-64
    ID: 6LRX:E4PK:3EBE:MHJE:TJHR:NVS6:5POR:YS4C:WIWG:7F5J:Y6FU:4IZE
    Username: dockerlabs
    Registry: https://index.docker.io/v1/
    WARNING: No swap limit support


But if we look at the number of containers and images, the number of images it is not the same as provided above.
Why do you think that is?

First let's list the number of running and number of stopped containers

**NOTE: the value on your system will be different**


```bash
# Show the running containers:
docker ps

# Count the number of running containers:
echo
echo "Total number of running containers:"
docker ps | tail -n +2 | wc -l
```

    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
    
    Total number of running containers:
    0



```bash
# Show all the containers (running or stopped):
docker ps -a

# Count all the containers (running or stopped):
echo
echo "Total number of containers (running or stopped):"
docker ps -a | tail -n +2 | wc -l # Number of stopped and running containers ('tail -n +2' excludes the header line)
```

    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
    
    Total number of containers (running or stopped):
    0


We can see that the number of containers reported by docker info correctly reports the number of total containers, running or not

But listing images gives a different value from the 'docker info' value


```bash
# Show the images:
docker images

# Count the images:
echo
echo "Total number of images:"
docker images | tail -n +2 | wc -l
```

    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    <none>              <none>              7f6ea29da43b        12 minutes ago      689.1 MB
    <none>              <none>              cf3bfbdc8b8f        12 minutes ago      689.1 MB
    lab/basic           latest              586770cdbd0a        12 minutes ago      689.1 MB
    python              latest              93049cc049a6        9 days ago          689.1 MB
    python              2.7                 31093b2dabe2        9 days ago          676.1 MB
    node                latest              baa18fdeb577        9 days ago          643.1 MB
    golang              latest              f827671e2a60        9 days ago          725.1 MB
    swarm               1.1.0-rc2           81883ac55ffe        13 days ago         18.06 MB
    alpine              latest              14f89d0e6257        2 weeks ago         4.794 MB
    
    Total number of images:
    9


That is because there are many intermediate image layers which are not normally listed.
But we can list those layers using the '-a' option and now we see a number close to the value from 'docker info'.

(We will see later how the 'docker history' command allows us to see how the layers were created).


```bash
# Show all the image layers:
docker images -a

# Count all the image layers:
echo
echo "Total number of image layers:"

docker images -a | tail -n +2 | wc -l  # The number of image layers+1 (inc. header line)
```

    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    <none>              <none>              e09e3f64b3c4        12 minutes ago      689.1 MB
    <none>              <none>              7f6ea29da43b        12 minutes ago      689.1 MB
    <none>              <none>              d1e0972af2d6        12 minutes ago      689.1 MB
    <none>              <none>              38625d4d3cf0        12 minutes ago      689.1 MB
    <none>              <none>              5a27b12d8ff4        12 minutes ago      689.1 MB
    <none>              <none>              d02362fa5ff3        12 minutes ago      689.1 MB
    <none>              <none>              cf3bfbdc8b8f        12 minutes ago      689.1 MB
    <none>              <none>              4d5347559ce7        12 minutes ago      689.1 MB
    <none>              <none>              579cc809ae9b        13 minutes ago      689.1 MB
    lab/basic           latest              586770cdbd0a        13 minutes ago      689.1 MB
    <none>              <none>              cc80fdd4e448        13 minutes ago      689.1 MB
    python              latest              93049cc049a6        9 days ago          689.1 MB
    python              2.7                 31093b2dabe2        9 days ago          676.1 MB
    node                latest              baa18fdeb577        9 days ago          643.1 MB
    golang              latest              f827671e2a60        9 days ago          725.1 MB
    swarm               1.1.0-rc2           81883ac55ffe        13 days ago         18.06 MB
    alpine              latest              14f89d0e6257        2 weeks ago         4.794 MB
    
    Total number of image layers:
    17


Images can include 1 static binary file or more and can even include a whole distribution.
Launching a container launches a single process within that container - which may in turn span other child processes.

Let us look at an extremely small image to have an idea just how small an executable image can be.
Docker provide an official 'hello-world' image which simply echoes some output to the console.

Let's run that image to see and then investigate the image.
First let's search for the image; we see that the first image is 'hello-world' which is an official build


```bash
docker search hello-world
```

    NAME                                     DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
    hello-world                              Hello World! (an example of minimal Docker...   47        [OK]       
    tutum/hello-world                        Image to test docker deployments. Has Apac...   19                   [OK]
    marcells/aspnet-hello-world              ASP.NET vNext - Hello World                     2                    [OK]
    carinamarina/hello-world-web             A Python web app, running on port 5000, wh...   1                    [OK]
    bonomat/nodejs-hello-world               a simple nodejs hello world container           1                    [OK]
    vegasbrianc/docker-hello-world                                                           1                    [OK]
    carinamarina/hello-world-app             This is a sample Python web application, r...   1                    [OK]
    mikelh/hello-world                       simplified hello world as dummy start for ...   0                    [OK]
    poojathote/hello-world                   this is 3rd POC                                 0                    [OK]
    asakaguchi/docker-nodejs-hello-world     Hello World for Docker                          0                    [OK]
    ileontyev81/docker-hello-world           hello world test build                          0                    [OK]
    alexwelch/hello-world                                                                    0                    [OK]
    vasia/docker-hello-world                 rhrthrth                                        0                    [OK]
    asakaguchi/magellan-nodejs-hello-world   Hello World for MAGELLAN                        0                    [OK]
    samxzxy/docker-hello-world               Automated build test docker-hello-world         0                    [OK]
    cpro/http-hello-world                    Hello world                                     0                    [OK]
    rcarun/hello-world                                                                       0                    [OK]
    kevto/play2-docker-hello-world           Hello World application in Play2 to test D...   0                    [OK]
    nirmata/hello-world                                                                      0                    [OK]
    n8io/hello-world                         A simple hello world node.js app to test d...   0                    [OK]
    wodge/docker-hello-world                 Hello World test for auto update to Docker...   0                    [OK]
    chalitac/hello-world                     Just Hello World                                0                    [OK]
    wowgroup/hello-world                     Minimal web app for testing purposes            0                    [OK]
    bencampbell/hello-world                  First automated build.                          0                    [OK]
    crccheck/hello-world                     Hello World web server in under 2.5 MB          0                    [OK]


Let's now run that image


```bash
docker run hello-world

# Note how we see the pulling of the image if not already available locally:
```

    Unable to find image 'hello-world:latest' locally
    latest: Pulling from library/hello-world
    [0B
    [0B
    [1BDigest: sha256:8be990ef2aeb16dbcb9271ddfe2610fa6658d13f6dfb8bc72074cc1ca36966a7
    Status: Downloaded newer image for hello-world:latest
    
    Hello from Docker.
    This message shows that your installation appears to be working correctly.
    
    To generate this message, Docker took the following steps:
     1. The Docker client contacted the Docker daemon.
     2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
     3. The Docker daemon created a new container from that image which runs the
        executable that produces the output you are currently reading.
     4. The Docker daemon streamed that output to the Docker client, which sent it
        to your terminal.
    
    To try something more ambitious, you can run an Ubuntu container with:
     $ docker run -it ubuntu bash
    
    Share images, automate workflows, and more with a free Docker Hub account:
     https://hub.docker.com
    
    For more examples and ideas, visit:
     https://docs.docker.com/userguide/
    


If it took a while to run, this was due to the time needed to download the image before running it - see above.

Try the command a second time to see how it runs instantaneously as there is no need to download the image which already exists locally on the 'docker engine'.


```bash
docker run hello-world

# The second time there is no need to repull the image:
```

    
    Hello from Docker.
    This message shows that your installation appears to be working correctly.
    
    To generate this message, Docker took the following steps:
     1. The Docker client contacted the Docker daemon.
     2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
     3. The Docker daemon created a new container from that image which runs the
        executable that produces the output you are currently reading.
     4. The Docker daemon streamed that output to the Docker client, which sent it
        to your terminal.
    
    To try something more ambitious, you can run an Ubuntu container with:
     $ docker run -it ubuntu bash
    
    Share images, automate workflows, and more with a free Docker Hub account:
     https://hub.docker.com
    
    For more examples and ideas, visit:
     https://docs.docker.com/userguide/
    


Let us inspect the image.  We see that the file is only 960 bytes large, it must be machine code to print out the text.  So we see that an image can be really very small


```bash
docker images hello-world
```

    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    hello-world         latest              690ed74de00f        3 months ago        960 B


We can also inspect the image with the history command to see how it was constructed.

Note that history shows the image layers in reverse order, latest first.

From the below command we can see that the image was created from only 2 image layers.

The image was built simply by copying in a binary executable and then specifying the default command to invoke when the image is run.


```bash
docker history hello-world
```

    IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
    690ed74de00f        3 months ago        /bin/sh -c #(nop) CMD ["/hello"]                0 B                 
    <missing>           3 months ago        /bin/sh -c #(nop) COPY file:1ad52e3eaf4327c8f   960 B               



```bash
echo
echo "Total size (in bytes) of text in 'hello-world' image:"
docker run hello-world | wc -c
```

    
    Total size (in bytes) of text in 'hello-world' image:
    801


So we see that 801 bytes of that executable is the actual text printed !
So the real program size is roughly 160 bytes (of assembler no doubt)

<a name="builds" />
## Basic Docker Builds
[TOP](#TOP)

#### Dockerfile

Images are built from Dockerfiles which contain a series of commands used to build up a docker image.
Note that each command in the Dockerfile results in a new image layer being created, no matter how trivial the command - even ENV "commands" create a new image layer.

In the following lab we will see how images can be built systematically from a Dockerfile using the 'docker build' command.

#### DockerHub

When we pull an image we pull it from a Docker Registry.  The [DockerHub](https://hub.docker.com/) is a free to use Docker registry allowing to store your own image files (which are publicly available unless you pay for your account) and to pull other image files of other users or officially provided images.

You can create images either by
- building them from a Dockerfile (thus in a **repeatable** manner)
- building them manually by modifying a running container and *'commit'*ing it's state

The DockerHub contains images which may be
- **Automated builds** (built from a git repository)
  - Such builds are usually built from an open-source git repo and so are called **Trusted builds** because the source code is available.
    *Note:* The github repo may contain binary files though
- **Official builds** are builds which are builds provided by partners or by Docker themselves

Other images may exist in the hub but their origin is unknown and so represent a security risk.

It is possible to search the DockerHub, or another Docker Registry, using the 'docker search' command with appropriate options.  Other companies offer their own Docker Registry which may be freely accessible e.g. RedHat, internal to a company e.g. HPE IT, or available as part of a paid for service e.g. IBM or Amazon Web Services ECS.



```bash
mkdir -p ~/test
cd    ~/test
```

    

In the ~/test folder create a file called Dockerfile.basic with the contents shown below (the o/p of the cat command).

For this you may use vi if you are familiar, otherwise the 'nano' text editor is recommended.

Use ctrl-W to write out the file and ctrl-X to quit the editor.


```bash
cat Dockerfile.basic
```

    #
    # Dockerfile to demonstrate the simplest build
    #
    FROM python
    
    MAINTAINER "Docker Build Lab" <dockerlabs@mjbright.net>
    
    # NOTE: all RUN commands are executed at build time,
    #       look at the output of the "docker build" below and you will see the Python version.
    RUN python --version
    
    CMD bash
    



```bash
ls -altr Dockerfile.basic
```

    -rw-rw-r-- 1 vagrant vagrant 298 Feb  4 21:56 Dockerfile.basic


We can now build a new image using this dockerfile using the below command where
- we explicitly select the *Dockerfile.basic* which we just created with

    **-f Dockerfile.basic**
    
- we specify the current directory as the context for the build (any ADD/COPY or Dockerfile files will be sourced from here) with

    **.**


- we specify the specific tag to use for the generated image as "*lab/basic*" with

    **-t lab/basic**



```bash
docker build -f Dockerfile.basic -t lab/basic . 
```

    
    Step 1 : FROM python
     ---> 93049cc049a6
    Step 2 : MAINTAINER "Docker Build Lab" <dockerlabs@mjbright.net>
     ---> Using cache
     ---> cc80fdd4e448
    Step 3 : RUN python --version
     ---> Using cache
     ---> 579cc809ae9b
    Step 4 : CMD bash
     ---> Using cache
     ---> 586770cdbd0a
    Successfully built 586770cdbd0a


Note that during the build, the RUN commands are actually run.

They are used to build up this new image.

In this case we echo the 'Python' version string during the build process.

You can see the available options to the build command by issuing
 'docker build --help'


```bash
docker build --help
```

    
    Usage:	docker build [OPTIONS] PATH | URL | -
    
    Build an image from a Dockerfile
    
      --build-arg=[]                  Set build-time variables
      --cpu-shares                    CPU shares (relative weight)
      --cgroup-parent                 Optional parent cgroup for the container
      --cpu-period                    Limit the CPU CFS (Completely Fair Scheduler) period
      --cpu-quota                     Limit the CPU CFS (Completely Fair Scheduler) quota
      --cpuset-cpus                   CPUs in which to allow execution (0-3, 0,1)
      --cpuset-mems                   MEMs in which to allow execution (0-3, 0,1)
      --disable-content-trust=true    Skip image verification
      -f, --file                      Name of the Dockerfile (Default is 'PATH/Dockerfile')
      --force-rm                      Always remove intermediate containers
      --help                          Print usage
      --isolation                     Container isolation level
      -m, --memory                    Memory limit
      --memory-swap                   Swap limit equal to memory plus swap: '-1' to enable unlimited swap
      --no-cache                      Do not use cache when building the image
      --pull                          Always attempt to pull a newer version of the image
      -q, --quiet                     Suppress the build output and print image ID on success
      --rm=true                       Remove intermediate containers after a successful build
      --shm-size                      Size of /dev/shm, default value is 64MB
      -t, --tag=[]                    Name and optionally a tag in the 'name:tag' format
      --ulimit=[]                     Ulimit options


We can see all the images available using the
 'docker images' command
 
but if there are many, how do we see just our newly-created image?

You can see the available options to the images command by issuing
 'docker images --help'


```bash
docker images --help
```

    
    Usage:	docker images [OPTIONS] [REPOSITORY[:TAG]]
    
    List images
    
      -a, --all          Show all images (default hides intermediate images)
      --digests          Show digests
      -f, --filter=[]    Filter output based on conditions provided
      --format           Pretty-print images using a Go template
      --help             Print usage
      --no-trunc         Don't truncate output
      -q, --quiet        Only show numeric IDs


So you can see your newly built 'lab/basic' with the following command:


```bash
docker images lab/basic
```

    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    lab/basic           latest              586770cdbd0a        17 minutes ago      689.1 MB


Note that if you rerun the build command, the build should run faster, you will notice how build steps recognize that this step has already been performed and so will use the image layer already available in the local cache.

Now let us see what happens if we modify our Dockerfile, by inserting a line, such as defining an environment variable.

We will use the same Dockerfile, but this time we will insert an "ENV" line



```bash
cd ~/test/
```

    

Now edit the Dockerfile.basic to have the contents as shown below (the o/p of the cat command).


```bash
cat Dockerfile.basic
```

    #
    # Dockerfile to demonstrate the simplest build
    #
    FROM python
    
    MAINTAINER "Docker Build Lab" <dockerlabs@mjbright.net>
    
    # NOTE: all RUN commands are executed at build time,
    #       look at the output of the "docker build" below and you will see the Python version.
    RUN python --version
    
    # The addition of the following line will invalidate the cache, all following lines will
    # be built, the cache will not be used:
    ENV NEWVAR=somevalue
    
    CMD bash
    


This time when we build the image we will see that the addition of a line between the "RUN" line and the "CMD" line forces rebuild of subsequent image layers.

**We see 'Using cache' for Step 2 and 3 only**


```bash
docker build -f Dockerfile.basic -t lab/basic . 
```

    
    Step 1 : FROM python
     ---> 93049cc049a6
    Step 2 : MAINTAINER "Docker Build Lab" <dockerlabs@mjbright.net>
     ---> Using cache
     ---> cc80fdd4e448
    Step 3 : RUN python --version
     ---> Using cache
     ---> 579cc809ae9b
    Step 4 : ENV NEWVAR somevalue
     ---> Running in 4757f402c5fb
     ---> 554472e06c33
    Removing intermediate container 4757f402c5fb
    Step 5 : CMD bash
     ---> Running in 7192072748cf
     ---> 20558c927680
    Removing intermediate container 7192072748cf
    Successfully built 20558c927680


Similarly we can force to not use the cache with the --no-cache option.

This could be useful if we suspect the caching is not working properly due to some external change.


```bash
docker build --no-cache -f Dockerfile.basic -t lab/basic . 
```

    
    Step 1 : FROM python
     ---> 93049cc049a6
    Step 2 : MAINTAINER "Docker Build Lab" <dockerlabs@mjbright.net>
     ---> Running in 5b0210d59236
     ---> e2395c2aa7a5
    Removing intermediate container 5b0210d59236
    Step 3 : RUN python --version
     ---> Running in a943c426a9ee
    Python 3.5.1
     ---> a179256b8bf0
    Removing intermediate container a943c426a9ee
    Step 4 : ENV NEWVAR somevalue
     ---> Running in 9c899c91f55b
     ---> 12834699ace7
    Removing intermediate container 9c899c91f55b
    Step 5 : CMD bash
     ---> Running in 43cd245b9527
     ---> b1c72c79ea90
    Removing intermediate container 43cd245b9527
    Successfully built b1c72c79ea90



```bash
docker images lab/basic
```

    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    lab/basic           latest              b1c72c79ea90        1 seconds ago       689.1 MB


<a name="small-images" />
## Creating small images
[TOP](#TOP)

<a name="small-c" />
## Creating a small C Docker image
[TOP](#TOP)

In this example we show how we can create a Docker image from a statically-linked binary.

<font size=+1 color="#77f">
<b>The goal of this step is to show that we do not need an Operating System image for a Docker container.</b>
</font>

All we need is a self-contained binary - i.e. statically linked binary.

Of course a dynamically linked binary could also be used, but in this case it's more complicated as you would have to manually add all it's dependent libraries.  Let's let gcc to do that work for us!

This section comprises 2 things
- A Dockerfile to build our image from a static binary
  Note that it starts with "FROM scratch".
  Scratch is a special 'empty' image
- helloFromDocker.c
  

So first let's build our static binary


```bash
cd ~/src/createTinyC/

# For RHEL/Fedora/Centos only:
# First we must install *glibc-static*
#yum install -y glibc-static

gcc -static helloWorld.c -o helloWorld

ls -alh helloWorld
```

    -rwxrwxr-x 1 vagrant vagrant 857K Feb  4 22:02 helloWorld


So we see that this created a binary file of approximately 857kby.

Now let's build our Docker image containing this binary.

You will need to recreate the Dockerfile as follows:


```bash
cat Dockerfile
```

    
    FROM scratch
    MAINTAINER "Docker Build Lab" <dockerlabs@mjbright.net>
    
    ADD ./helloWorld /helloWorld
    CMD ["/helloWorld"]
    



```bash
docker build -t lab/c_prog .
```

    
    Step 1 : FROM scratch
     ---> 
    Step 2 : MAINTAINER "Docker Build Lab" <dockerlabs@mjbright.net>
     ---> Running in 1d3908c955e9
     ---> 5b37a53abbef
    Removing intermediate container 1d3908c955e9
    Step 3 : ADD ./helloWorld /helloWorld
     ---> f13c22c24ca5
    Removing intermediate container 4d8a200f2f5f
    Step 4 : CMD /helloWorld
     ---> Running in 5e5c69595417
     ---> 45069c143064
    Removing intermediate container 5e5c69595417
    Successfully built 45069c143064


If we now look at the generated Docker image (below) we see an image of about 877kby.

So whilst this is larger than the 1kby hello-world image (no doubt written in assembler) it is still a very small Docker image which is only 20kbytes larger than the original binary file.


```bash
docker images lab/c_prog
```

    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    lab/c_prog          latest              45069c143064        5 seconds ago       877.2 kB


And now let's run that image


```bash
docker run lab/c_prog
```

    Hello World!!



```bash
docker history lab/c_prog
```

    IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
    45069c143064        8 seconds ago       /bin/sh -c #(nop) CMD ["/helloWorld"]           0 B                 
    f13c22c24ca5        8 seconds ago       /bin/sh -c #(nop) ADD file:474e67cc2feb0f0110   877.2 kB            
    5b37a53abbef        8 seconds ago       /bin/sh -c #(nop) MAINTAINER "Docker Build La   0 B                 


<a name="small-go" />
## Creating a small Go Docker image
[TOP](#TOP)

That's fine, but isn't Go taking over the world as a systems language?
Docker, Kubernetes, LXD, Rocket, ... many new tools are being written in Go.

Let's see how we can do the same exercise but building a Go statically-linked binary.

<font size=+1 color="#77f">
<b>The goal of this step is as the previous step (building an image from a single statically-linked binary) but using Go, but also to demonstrate how we can use a Docker image containing a Go compiler, rather than explicitly installing a compiler.</b>
</font>

**NOTE:** We will do this **without** 'installing a Go compiler'



  


```bash
cd ~/src/createTinyGo
cat Dockerfile
```

    
    FROM scratch
    MAINTAINER "Docker Build Lab" <dockerlabs@mjbright.net>
    
    ADD ./hello /hello
    CMD ["/hello"]
    


**NOW we invoke the golang container** to build our go source code.

The following docker run
- mounts the current directory ($PWD) as /go within the container
- launches a container of the **golang** image which contains the go compiler
- invokes the command "go build -v hello" on the container to build the sources for the "hello.go" code.

The hello.go code is located under src/hello/hello.go.

This is a Go convention.

**NOTE:** The important thing to note here is that the compiler is within the image.  We did not need to install a native Go compiler, we used an image which contains the compiler and by mounting the current directory the container can read the source code and write the executable outside the container.  This is a nice pattern of providing a tool within a container.



```bash
docker run -it -v $PWD:/go golang go build hello

ls -l hello
```

    -rwxr-xr-x 1 root root 2367272 Feb  4 22:03 hello


Now we can build our image including this static binary.


```bash
docker build -t lab/go-hello .
```

    
    Step 1 : FROM scratch
     ---> 
    Step 2 : MAINTAINER "Docker Build Lab" <dockerlabs@mjbright.net>
     ---> Using cache
     ---> 5b37a53abbef
    Step 3 : ADD ./hello /hello
     ---> 368532705c93
    Removing intermediate container 8303b13a07f5
    Step 4 : CMD /hello
     ---> Running in 33e78ca46636
     ---> 75404e153500
    Removing intermediate container 33e78ca46636
    Successfully built 75404e153500



```bash
docker images lab/*
```

    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    lab/go-hello        latest              75404e153500        2 seconds ago       2.367 MB
    lab/c_prog          latest              45069c143064        24 seconds ago      877.2 kB
    lab/basic           latest              b1c72c79ea90        40 seconds ago      689.1 MB


<a name="small-multi"/>
## Creating a toolset Docker image containing several executables
[TOP](#TOP)

Now let's see how we can combine these static binaries into one image.

Let's build a new image derived from the Docker provided 'hello-world' image

<font size=+1 color="#77f">
<b>The goal of this step is to show how we can combine several executables in an image, opening up the possibility of creating a container of tools.</b>
</font>

We will do this without directly 'installing a Go compiler' but by using the official *'golang'* image which includes the Go compiler.


```bash
cd ~/src/toolset

cp ../createTinyC/helloWorld   helloWorld
cp ../createTinyGo/hello       helloWorldGo

ls -altr
```

    total 3192
    -rw-rw-r--  1 vagrant vagrant      68 Feb  4 21:55 helloWorld.c
    -rw-rw-r--  1 vagrant vagrant     181 Feb  4 21:55 Dockerfile
    -rwxrwxr-x  1 vagrant vagrant     333 Feb  4 21:55 createTinyDockerImage.sh
    drwxrwxr-x 10 vagrant vagrant    4096 Feb  4 21:55 ..
    -rwxrwxr-x  1 vagrant vagrant  877152 Feb  4 22:04 helloWorld
    -rwxr-xr-x  1 vagrant vagrant 2367272 Feb  4 22:04 helloWorldGo
    drwxrwxr-x  2 vagrant vagrant    4096 Feb  4 22:04 .


Create the Dockerfile with the following contents


```bash
cat Dockerfile
```

    
    FROM hello-world
    MAINTAINER "Docker Build Lab" <dockerlabs@mjbright.net>
    
    ADD ./helloWorld /helloWorld
    CMD ["/helloWorld"]
    
    ADD ./helloWorldGo /helloWorldGo
    CMD ["/helloWorldGo"]
    



```bash
docker build -t lab/toolset ./
```

    
    Step 1 : FROM hello-world
     ---> 690ed74de00f
    Step 2 : MAINTAINER "Docker Build Lab" <dockerlabs@mjbright.net>
     ---> Running in af48eaf8d716
     ---> d65e580bff00
    Removing intermediate container af48eaf8d716
    Step 3 : ADD ./helloWorld /helloWorld
     ---> c15402facbac
    Removing intermediate container 3ad406b7af86
    Step 4 : CMD /helloWorld
     ---> Running in 2af85037391e
     ---> 822cfe5f6bb9
    Removing intermediate container 2af85037391e
    Step 5 : ADD ./helloWorldGo /helloWorldGo
     ---> 0e4cf415e1be
    Removing intermediate container 8dc53041a21e
    Step 6 : CMD /helloWorldGo
     ---> Running in 6d1bbf2975d0
     ---> 06585695f835
    Removing intermediate container 6d1bbf2975d0
    Successfully built 06585695f835


If we look at the history of this image we can see the different executables and CMDs which have been added including the original hello-world image.


```bash
docker history lab/toolset
```

    IMAGE               CREATED              CREATED BY                                      SIZE                COMMENT
    06585695f835        About a minute ago   /bin/sh -c #(nop) CMD ["/helloWorldGo"]         0 B                 
    0e4cf415e1be        About a minute ago   /bin/sh -c #(nop) ADD file:e8275a9025432fdf2e   2.367 MB            
    822cfe5f6bb9        About a minute ago   /bin/sh -c #(nop) CMD ["/helloWorld"]           0 B                 
    c15402facbac        About a minute ago   /bin/sh -c #(nop) ADD file:474e67cc2feb0f0110   877.2 kB            
    d65e580bff00        About a minute ago   /bin/sh -c #(nop) MAINTAINER "Docker Build La   0 B                 
    690ed74de00f        3 months ago         /bin/sh -c #(nop) CMD ["/hello"]                0 B                 
    <missing>           3 months ago         /bin/sh -c #(nop) COPY file:1ad52e3eaf4327c8f   960 B               


Now we are free to specify which command is to be run.

If we don't specify the command, the last (first in the history list) will be run (so /helloWorldGo in this case)


```bash
docker run lab/toolset
```

    Hello world from Go !!


Or we can explicitly choose the executable to be run.


```bash
docker run lab/toolset /hello
```

    
    Hello from Docker.
    This message shows that your installation appears to be working correctly.
    
    To generate this message, Docker took the following steps:
     1. The Docker client contacted the Docker daemon.
     2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
     3. The Docker daemon created a new container from that image which runs the
        executable that produces the output you are currently reading.
     4. The Docker daemon streamed that output to the Docker client, which sent it
        to your terminal.
    
    To try something more ambitious, you can run an Ubuntu container with:
     $ docker run -it ubuntu bash
    
    Share images, automate workflows, and more with a free Docker Hub account:
     https://hub.docker.com
    
    For more examples and ideas, visit:
     https://docs.docker.com/userguide/
    



```bash
docker run lab/toolset /helloWorld
```

    Hello World!!



```bash
docker run lab/toolset /helloWorldGo
```

    Hello world from Go !!


We have seen how we can combine several executables in an image, and we can imagine creating a toolset container in this way (with some more useful executable tools!)

<a name="small-push"/>
## Pushing our image to Docker Hub
[TOP](#TOP)

**Note:** If you have your own account on Docker Hub you may wish to use that for this exercise.

**Otherwise** we will all be using the same account **'dockerlabs'** so you will need to specify a tag which
distinguishes your images from your neighbours.


<font size=+1 color="#77f">
<b>The goal of this step is to demonstrate how we may push an image which we have built to the Docker Hub.</b>
</font>

First we will retag our local image to be unique.
If you are on <font size=+1 color="#d88">podN</font>, then tag with <font size=+1 color="#d88">userN</font>,

e.g. if you are <font size=+1 color="#d88">pod3</font>,

<font size=+1 color="#d88"><br/>&nbsp;&nbsp;&nbsp;&nbsp;
docker tag lab/toolset dockerlabs/toolset:user3
</font>

Notice that we then have 2 toolset images with different tags.

They are otherwise identical (but they could be different) and have the same "IMAGE ID".


```bash
docker tag lab/toolset:latest dockerlabs/toolset:userN
docker images */toolset
```

    REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
    dockerlabs/toolset   userN               06585695f835        2 minutes ago       3.245 MB
    lab/toolset          latest              06585695f835        2 minutes ago       3.245 MB


First we must login to the Docker Hub.

Ask you instructor for the password to the dockerlabs account.


```bash
docker login -u dockerlabs -p $PASSWORD -e dockerlabs@mjbright.net
```

    WARNING: login credentials saved in /home/vagrant/.docker/config.json
    Login Succeeded


Now we may push our image to the public Docker Hub


```bash
docker push dockerlabs/toolset:userN
```

    The push refers to a repository [docker.io/dockerlabs/toolset]
    
    [0B
    [0B
    [0B
    [4BuserN: digest: sha256:b906343d1505faafdb32566ce0d6dcd8d1e57d23041af750640573baeb7c28d4 size: 4623


**NOTE:** The docker search command is not very useful.

and the below command doesn't show us the tags ... and so we don't know if the below image is tagged user1, user2, ...


```bash
docker search dockerlabs/
```

    NAME                 DESCRIPTION   STARS     OFFICIAL   AUTOMATED
    dockerlabs/toolset                 0                    


### Logging on to DockerHub to see your tagged image there

So for this step, log onto DockerHub
    https://hub.docker.com/


```bash
# Ignore this line: it is just to display the image below

curl -s 'http://image.slidesharecdn.com/dockerdemystifiedforsbjug-150918181554-lva1-app6892/95/docker-demystified-for-sb-jug-34-638.jpg' | display
```

    


![jpeg](output_92_1.jpeg)


As dockerlabs (dockerlabs AT mjbright.net) with the appropriate password (ask your instructor)

Once logged you should see the dockerlabs/toolset listed, otherwise you can search for it.

Click on the [dockerlabs/toolset](https://hub.docker.com/r/dockerlabs/toolset/) link, then on the [Tags](https://hub.docker.com/r/dockerlabs/toolset/tags/) link and you should now see your tagged image there.

#### Remove any running *'dockerlabs/toolset'* containers

We do this step to make sure we can easily delete your local dockerlabs/toolset:userN image.

These steps could be done by hand through use of 'docker ps' and 'docker ps -a' and picking containers ids corresponding to 'dockerlabs/toolset' containers to use with 'docker stop' and 'docker rm' commands.

The below expressions do this automatically for us.


```bash
IMAGE_NAME=dockerlabs/toolset

echo; echo "Currently running or stopped '$IMAGE_NAME' containers"
docker ps -a --filter=ancestor=$IMAGE_NAME

echo; echo "Stopping any running '$IMAGE_NAME' containers (so we can remove dockerlabs/ image)"
docker stop $(docker ps --filter=ancestor=$IMAGE_NAME) 2>/dev/null

echo; echo "Removing any stopped '$IMAGE_NAME' containers (so we can remove dockerlabs/ image)"
docker rm $(docker ps -a --filter=ancestor=$IMAGE_NAME) 2>/dev/null

echo; echo "There should be no more '$IMAGE_NAME' containers present:"
docker ps -a --filter=ancestor=$IMAGE_NAME
```

    
    Currently running or stopped 'dockerlabs/toolset' containers
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
    
    Stopping any running 'dockerlabs/toolset' containers (so we can remove dockerlabs/ image)
    
    Removing any stopped 'dockerlabs/toolset' containers (so we can remove dockerlabs/ image)
    
    There should be no more 'dockerlabs/toolset' containers present:
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES



```bash
docker images dockerlabs/*
```

    REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
    dockerlabs/toolset   userN               06585695f835        11 minutes ago      3.245 MB


Note that the following rmi command 'Untags' the image.

This is because it is the same - has the same image id - as our original 'lab/toolset' image.

Removing the dockerlabs/toolset image does not remove the identical 'lab/toolset' image but removes the 'dockerlabs/toolset' tag.


```bash
docker rmi dockerlabs/toolset:userN
```

    Untagged: dockerlabs/toolset:userN



```bash
docker images dockerlabs/*
```

    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE


As we have removed ('untagged') the dockerlabs/toolset image, the following run command will download it from the Docker Hub


```bash
docker run dockerlabs/toolset:userN
```

    Unable to find image 'dockerlabs/toolset:userN' locally
    userN: Pulling from dockerlabs/toolset
    [0B
    [0B
    [0B
    [0B
    [0BDigest: sha256:b906343d1505faafdb32566ce0d6dcd8d1e57d23041af750640573baeb7c28d4
    Status: Downloaded newer image for dockerlabs/toolset:userN
    Hello world from Go !!



```bash
docker images dockerlabs/*
```

    REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
    dockerlabs/toolset   userN               618d91642aab        13 minutes ago      3.245 MB



```bash
docker run dockerlabs/toolset:userN /helloWorld
```

    Hello World!!



```bash
docker run dockerlabs/toolset:userN /hello
```

    
    Hello from Docker.
    This message shows that your installation appears to be working correctly.
    
    To generate this message, Docker took the following steps:
     1. The Docker client contacted the Docker daemon.
     2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
     3. The Docker daemon created a new container from that image which runs the
        executable that produces the output you are currently reading.
     4. The Docker daemon streamed that output to the Docker client, which sent it
        to your terminal.
    
    To try something more ambitious, you can run an Ubuntu container with:
     $ docker run -it ubuntu bash
    
    Share images, automate workflows, and more with a free Docker Hub account:
     https://hub.docker.com
    
    For more examples and ideas, visit:
     https://docs.docker.com/userguide/
    


<a name="build-best-practices"/>
## Dockerfile best practices
[TOP](#TOP)

<font size=+1 color="#77f">
<b>The goal of this step is to demonstrate certain Dockerfile optimizations.</b>
</font>

- group related commands together using '&&' to reduce image layers
- if temporary files are to be removed



```bash
cd ~/src/build-best-practices
cat Dockerfile
```

    
    FROM ubuntu
    
    MAINTAINER "Docker Labs" <dockerlabs@mjbright.net>
    
    #
    # Instead of perofmring the followinf commands individually which
    # involves creating a separate image layer for each RUN command:
    #   RUN apt-get update
    #   RUN apt-get -y -q upgrade
    #   RUN rm -rf /var/lib/apt/lists/*
    
    # Here we combine the update, upgrade and cleanup steps into one command
    # - This produces less image layers (better for disk space and performance)
    # - This keeps image smaller by removing temporary files in the same layer
    #     If we performed update/upgrade and then rm as a separate step there would
    #     be an intermediate layer including those files, making the overall image larger.
    #
    
    RUN apt-get update && apt-get -y -q upgrade && rm -rf /var/lib/apt/lists/*
    


TO be completed ... !!

<a name="lang-stacks" />
## Using the official 'Language Stack' images
[TOP](#TOP)

<a name="medium-node" />
## Creating a Node.js application from the Node.js 'LanguageStack' Docker image
[TOP](#TOP)

Docker provide a set of *'Language Stacks'* which are medium sized images representing the necessary dependencies for a particular language.

<font size=+1 color="#77f">
<b>The goal of this step is to demonstrate the use of Docker-provided *Language Stacks*.</b>
</font>

On the [Docker Hub](https://hub.docker.com/) we can find language stacks available for a variety of languages/environments, each with different release versions (Python 2.x and Python 3.x for example):
- [Node.js (Javascript)](https://hub.docker.com/_/node/)
- [Python](https://hub.docker.com/_/python/)
- [Ruby](https://hub.docker.com/_/ruby/)

You can browse the complete list of *'Official Images*' on the Docker Hub [here](https://hub.docker.com/explore/)

Now let's look at an example of Node.js.
To run a Node.js application this time we will need




```bash
docker pull node
```

    Using default tag: latest
    latest: Pulling from library/node
    [0B
    [0B
    [0B
    [0B
    [0B
    [0B
    [5B
    [6BDigest: sha256:1bdda7cdd0a8f9c44ac6f51c77de9f42ed3f62efdf557dba6bcca675084de1bd
    Status: Image is up to date for node:latest



```bash
docker images node
```

    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    node                latest              baa18fdeb577        9 days ago          643.1 MB



```bash
docker history node
```

    IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
    baa18fdeb577        9 days ago          /bin/sh -c #(nop) CMD ["node"]                  0 B                 
    <missing>           9 days ago          /bin/sh -c curl -SLO "https://nodejs.org/dist   36.39 MB            
    <missing>           9 days ago          /bin/sh -c #(nop) ENV NODE_VERSION=5.5.0        0 B                 
    <missing>           9 days ago          /bin/sh -c #(nop) ENV NPM_CONFIG_LOGLEVEL=inf   0 B                 
    <missing>           9 days ago          /bin/sh -c set -ex   && for key in     9554F0   51.75 kB            
    <missing>           9 days ago          /bin/sh -c apt-get update && apt-get install    314.7 MB            
    <missing>           9 days ago          /bin/sh -c apt-get update && apt-get install    122.6 MB            
    <missing>           9 days ago          /bin/sh -c apt-get update && apt-get install    44.3 MB             
    <missing>           9 days ago          /bin/sh -c #(nop) CMD ["/bin/bash"]             0 B                 
    <missing>           9 days ago          /bin/sh -c #(nop) ADD file:e5a3d20748c5d3dd5f   125.1 MB            



```bash
cd ~/src/nodeJS/
ls -altr
```

    total 24
    drwxrwxr-x  2 vagrant vagrant 4096 Feb  4 21:55 src
    -rw-rw-r--  1 vagrant vagrant  116 Feb  4 21:55 README.md
    -rw-rw-r--  1 vagrant vagrant  315 Feb  4 21:55 Dockerfile
    -rwxrwxr-x  1 vagrant vagrant   78 Feb  4 21:55 build_run.sh
    drwxrwxr-x 10 vagrant vagrant 4096 Feb  4 21:55 ..
    drwxrwxr-x  3 vagrant vagrant 4096 Feb  4 21:55 .


Once again edit the Dockerfile to have the contents shown below:


```bash
cat Dockerfile
```

    
    FROM node
    
    # make the src folder available in the docker image
    ADD src/ /src
    
    
    WORKDIR /src
    
    # install the dependencies from the package.json file
    RUN npm install
    
    # make port 80 available outside of the image
    EXPOSE 80
    
    # start node with the index.js file of our hello-world application
    CMD ["node", "index.js"]
    


Now let's build  the image


```bash
docker build -t node-hello .
```

    
    Step 1 : FROM node
     ---> baa18fdeb577
    Step 2 : ADD src/ /src
     ---> 8c6618885ac8
    Removing intermediate container f7c4e91886fd
    Step 3 : WORKDIR /src
     ---> Running in 4c52826a30db
     ---> e873823852d1
    Removing intermediate container 4c52826a30db
    Step 4 : RUN npm install
     ---> Running in 7f7cc9bf2d2a
    [91mnpm[0m[91m [0m[91minfo it worked if it ends with ok
    npm info using npm@3.3.12
    npm info using node@v5.5.0
    [0m[91mnpm info attempt registry request try #1 at 10:20:07 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/express
    [0m[91mnpm http 200 https://registry.npmjs.org/express
    [0m[91mnpm info retry fetch attempt 1 at 10:20:13 PM
    npm info attempt registry request try #1 at 10:20:13 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/express/-/express-4.12.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/express/-/express-4.12.0.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:20:13 PM
    npm http request GET https://registry.npmjs.org/accepts
    [0m[91mnpm info attempt registry request try #1 at 10:20:13 PM
    npm http request GET https://registry.npmjs.org/content-disposition
    [0m[91mnpm info attempt registry request try #1 at 10:20:13 PM
    npm http request GET https://registry.npmjs.org/content-type
    [0m[91mnpm info attempt registry request try #1 at 10:20:13 PM
    npm http request GET https://registry.npmjs.org/cookie-signature
    npm info attempt registry request try #1 at 10:20:13 PM
    npm http request GET https://registry.npmjs.org/debug
    [0m[91mnpm info [0m[91mattempt[0m[91m registry request try #1 at 10:20:13 PM
    npm http[0m[91m request GET https://registry.npmjs.org/depd
    [0m[91mnpm info attempt registry request try #1 at 10:20:13 PM
    npm http request GET https://registry.npmjs.org/escape-html
    [0m[91mnpm info attempt[0m[91m registry request try #1 at 10:20:13 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/etag
    [0m[91mnpm [0m[91minfo attempt registry request try #1 at 10:20:13 PM
    npm http request GET https://registry.npmjs.org/finalhandler
    [0m[91mnpm info attempt registry request try #1 at 10:20:13 PM
    npm [0m[91mhttp request GET https://registry.npmjs.org/fresh
    [0m[91mnpm info attempt registry request try #1 at 10:20:13 PM
    npm http request GET https://registry.npmjs.org/methods
    [0m[91mnpm info attempt registry request try #1 at 10:20:13 PM
    npm [0m[91mhttp request GET https://registry.npmjs.org/on-finished
    [0m[91mnpm info attempt registry request try #1 at 10:20:13 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/parseurl
    [0m[91mnpm info attempt registry request try #1 at 10:20:13 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/path-to-regexp
    [0m[91mnpm info attempt registry request try #1 at 10:20:13 PM
    [0m[91mnpm [0m[91mhttp request GET https://registry.npmjs.org/proxy-addr
    [0m[91mnpm info attempt[0m[91m registry request try #1 at 10:20:13 PM
    npm http request GET https://registry.npmjs.org/qs
    npm info attempt registry request try #1 at 10:20:13 PM
    npm http[0m[91m request GET https://registry.npmjs.org/range-parser
    npm[0m[91m info attempt registry request try #1 at 10:20:13 PM
    npm http request GET https://registry.npmjs.org/send
    [0m[91mnpm info attempt registry request try #1 at 10:20:13 PM
    npm http request GET https://registry.npmjs.org/serve-static
    [0m[91mnpm info attempt registry request try #1 at 10:20:13 PM
    npm http [0m[91mrequest GET https://registry.npmjs.org/type-is
    npm info attempt registry request try #1 at 10:20:13 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/vary
    npm info attempt registry request try #1 at 10:20:13 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/cookie
    [0m[91mnpm info [0m[91mattempt registry request try #1 at 10:20:13 PM
    npm http request GET https://registry.npmjs.org/merge-descriptors
    npm[0m[91m info attempt registry request try #1 at 10:20:13 PM
    npm http request GET https://registry.npmjs.org/utils-merge
    [0m[91mnpm http 200 https://registry.npmjs.org/fresh
    [0m[91mnpm http 200 https://registry.npmjs.org/on-finished
    [0m[91mnpm [0m[91minfo retry fetch attempt 1 at 10:20:14 PM
    [0m[91mnpm info attempt registry request try #1 at 10:20:14 PM
    npm [0m[91mhttp fetch GET https://registry.npmjs.org/fresh/-/fresh-0.2.4.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:20:14 PM
    npm[0m[91m info attempt registry request try #1 at 10:20:14 PM
    [0m[91mnpm[0m[91m http[0m[91m fetch GET https://registry.npmjs.org/on-finished/-/on-finished-2.2.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/fresh/-/fresh-0.2.4.tgz
    [0m[91mnpm http fetch[0m[91m 200 https://registry.npmjs.org/on-finished/-/on-finished-2.2.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/serve-static
    [0m[91mnpm info retry fetch attempt 1 at 10:20:15 PM
    npm info attempt registry request try #1 at 10:20:15 PM
    npm http fetch GET https://registry.npmjs.org/serve-static/-/serve-static-1.9.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/cookie-signature
    [0m[91mnpm info retry fetch attempt 1 at 10:20:15 PM
    npm info attempt registry request try #1 at 10:20:15 PM
    npm http fetch GET https://registry.npmjs.org/cookie-signature/-/cookie-signature-1.0.6.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/escape-html
    [0m[91mnpm [0m[91minfo retry fetch attempt 1 at 10:20:15 PM
    [0m[91mnpm info attempt registry request try #1 at 10:20:15 PM
    npm http fetch GET https://registry.npmjs.org/escape-html/-/escape-html-1.0.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/serve-static/-/serve-static-1.9.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/depd
    [0m[91mnpm info retry fetch attempt 1 at 10:20:16 PM
    npm info attempt registry request try #1 at 10:20:16 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/depd/-/depd-1.0.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/depd/-/depd-1.0.1.tgz
    [0m[91mnpm[0m[91m [0m[91mhttp 200 https://registry.npmjs.org/utils-merge
    [0m[91mnpm http 200 https://registry.npmjs.org/vary
    [0m[91mnpm http 200 https://registry.npmjs.org/range-parser
    [0m[91mnpm[0m[91m info retry fetch attempt 1 at 10:20:17 PM
    npm info attempt registry request try #1 at 10:20:17 PM
    [0m[91mnpm[0m[91m http [0m[91mfetch GET https://registry.npmjs.org/utils-merge/-/utils-merge-1.0.0.tgz
    [0m[91mnpm[0m[91m [0m[91minfo retry fetch attempt 1 at 10:20:17 PM
    [0m[91mnpm info attempt registry request try #1 at 10:20:17 PM
    npm http fetch GET https://registry.npmjs.org/vary/-/vary-1.0.1.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:20:17 PM
    [0m[91mnpm info attempt registry request try #1 at 10:20:17 PM
    npm [0m[91mhttp fetch GET https://registry.npmjs.org/range-parser/-/range-parser-1.0.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/content-type
    [0m[91mnpm[0m[91m info[0m[91m retry fetch attempt 1 at 10:20:17 PM
    npm [0m[91minfo attempt registry request try #1 at 10:20:17 PM
    npm[0m[91m http fetch GET https://registry.npmjs.org/content-type/-/content-type-1.0.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/utils-merge/-/utils-merge-1.0.0.tgz
    [0m[91mnpm http 200[0m[91m https://registry.npmjs.org/merge-descriptors
    [0m[91mnpm info retry fetch attempt 1 at 10:20:18 PM
    [0m[91mnpm[0m[91m info [0m[91mattempt registry request try #1 at 10:20:18 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/merge-descriptors/-/merge-descriptors-0.0.2.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/cookie
    [0m[91mnpm info retry fetch attempt 1 at 10:20:18 PM
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:20:18 PM
    npm http fetch GET https://registry.npmjs.org/cookie/-/cookie-0.1.2.tgz
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/merge-descriptors/-/merge-descriptors-0.0.2.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/cookie/-/cookie-0.1.2.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/vary/-/vary-1.0.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/accepts
    [0m[91mnpm info retry fetch attempt 1 at 10:20:18 PM
    npm info attempt registry request try #1 at 10:20:18 PM
    npm http fetch GET https://registry.npmjs.org/accepts/-/accepts-1.2.13.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/send
    [0m[91mnpm info retry fetch attempt 1 at 10:20:18 PM
    npm info attempt registry request try #1 at 10:20:18 PM
    npm http fetch GET https://registry.npmjs.org/send/-/send-0.12.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/cookie-signature/-/cookie-signature-1.0.6.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/escape-html/-/escape-html-1.0.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/accepts/-/accepts-1.2.13.tgz
    [0m[91mnpm[0m[91m http[0m[91m 200 https://registry.npmjs.org/debug
    [0m[91mnpm http 200 https://registry.npmjs.org/type-is
    [0m[91mnpm[0m[91m info retry fetch attempt 1 at 10:20:19 PM
    npm info attempt registry request try #1 at 10:20:19 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/debug/-/debug-2.1.3.tgz
    [0m[91mnpm[0m[91m info retry fetch attempt 1 at 10:20:19 PM
    npm info attempt registry request try #1 at 10:20:19 PM
    npm http fetch GET https://registry.npmjs.org/type-is/-/type-is-1.6.11.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/send/-/send-0.12.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/debug/-/debug-2.1.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/type-is/-/type-is-1.6.11.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/range-parser/-/range-parser-1.0.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/parseurl
    [0m[91mnpm info retry fetch attempt 1 at 10:20:20 PM
    [0m[91mnpm info attempt registry request try #1 at 10:20:20 PM
    npm http [0m[91mfetch GET https://registry.npmjs.org/parseurl/-/parseurl-1.3.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/content-type/-/content-type-1.0.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/path-to-regexp
    [0m[91mnpm http 200 https://registry.npmjs.org/methods
    [0m[91mnpm info retry fetch attempt 1 at 10:20:20 PM
    npm info attempt registry request try #1 at 10:20:20 PM
    npm http fetch GET https://registry.npmjs.org/path-to-regexp/-/path-to-regexp-0.1.3.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:20:20 PM
    npm info attempt registry request try #1 at 10:20:20 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/methods/-/methods-1.1.2.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/finalhandler
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/parseurl/-/parseurl-1.3.1.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:20:20 PM
    npm info attempt registry request try #1 at 10:20:20 PM
    npm http fetch GET https://registry.npmjs.org/finalhandler/-/finalhandler-0.3.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/etag
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/path-to-regexp/-/path-to-regexp-0.1.3.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:20:21 PM
    npm info[0m[91m attempt registry request try #1 at 10:20:21 PM
    npm http fetch GET https://registry.npmjs.org/etag/-/etag-1.5.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/methods/-/methods-1.1.2.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/finalhandler/-/finalhandler-0.3.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/content-disposition
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/etag/-/etag-1.5.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/qs
    [0m[91mnpm info retry fetch attempt 1 at 10:20:21 PM
    npm info attempt registry request try #1 at 10:20:21 PM
    npm[0m[91m http fetch GET https://registry.npmjs.org/content-disposition/-/content-disposition-0.5.0.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/proxy-addr
    [0m[91mnpm info retry fetch attempt 1 at 10:20:21 PM
    npm info attempt registry request try #1 at 10:20:21 PM
    npm http [0m[91mfetch GET https://registry.npmjs.org/qs/-/qs-2.3.3.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:20:21 PM
    [0m[91mnpm info attempt registry request try #1 at 10:20:21 PM
    npm http fetch GET https://registry.npmjs.org/proxy-addr/-/proxy-addr-1.0.10.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/content-disposition/-/content-disposition-0.5.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/qs/-/qs-2.3.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/proxy-addr/-/proxy-addr-1.0.10.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:20:21 PM
    npm http request GET https://registry.npmjs.org/mime-types
    [0m[91mnpm info attempt registry request try #1 at 10:20:21 PM
    npm http[0m[91m request GET https://registry.npmjs.org/negotiator
    [0m[91mnpm http 200 https://registry.npmjs.org/mime-types
    [0m[91mnpm info retry fetch attempt 1 at 10:20:22 PM
    npm info attempt registry request try #1 at 10:20:22 PM
    npm http fetch GET https://registry.npmjs.org/mime-types/-/mime-types-2.1.9.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/mime-types/-/mime-types-2.1.9.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/negotiator
    [0m[91mnpm info retry fetch attempt 1 at 10:20:22 PM
    npm info attempt registry request try #1 at 10:20:22 PM
    npm[0m[91m http fetch GET https://registry.npmjs.org/negotiator/-/negotiator-0.5.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/negotiator/-/negotiator-0.5.3.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:20:22 PM
    npm http request GET https://registry.npmjs.org/mime-db
    [0m[91mnpm[0m[91m http [0m[91m200[0m[91m https://registry.npmjs.org/mime-db
    [0m[91mnpm info retry fetch attempt 1 at 10:20:23 PM
    [0m[91mnpm info attempt registry request try #1 at 10:20:23 PM
    npm http fetch GET https://registry.npmjs.org/mime-db/-/mime-db-1.21.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/mime-db/-/mime-db-1.21.0.tgz
    [0m[91mnpm[0m[91m info attempt[0m[91m registry request try #1 at 10:20:23 PM
    npm http request[0m[91m GET https://registry.npmjs.org/ms
    [0m[91mnpm http 200 https://registry.npmjs.org/ms
    [0m[91mnpm info retry fetch attempt 1 at 10:20:23 PM
    npm[0m[91m info attempt registry request try #1 at 10:20:23 PM
    npm http fetch GET https://registry.npmjs.org/ms/-/ms-0.7.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/ms/-/ms-0.7.0.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:20:24 PM
    npm http request GET https://registry.npmjs.org/crc
    [0m[91mnpm http 200 https://registry.npmjs.org/crc
    [0m[91mnpm[0m[91m info retry fetch attempt 1 at 10:20:24 PM
    [0m[91mnpm info attempt[0m[91m registry request try #1 at 10:20:24 PM
    npm[0m[91m http fetch GET https://registry.npmjs.org/crc/-/crc-3.2.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/crc/-/crc-3.2.1.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:20:24 PM
    npm http request GET https://registry.npmjs.org/ee-first
    [0m[91mnpm http 200 https://registry.npmjs.org/ee-first
    [0m[91mnpm info retry fetch attempt 1 at 10:20:24 PM
    npm info attempt registry request try #1 at 10:20:24 PM
    npm[0m[91m http fetch[0m[91m GET https://registry.npmjs.org/ee-first/-/ee-first-1.1.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/ee-first/-/ee-first-1.1.0.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:20:24 PM
    npm http request GET https://registry.npmjs.org/forwarded
    [0m[91mnpm info attempt registry request try #1 at 10:20:24 PM
    npm http request GET https://registry.npmjs.org/ipaddr.js
    [0m[91mnpm http 200 https://registry.npmjs.org/forwarded
    [0m[91mnpm info retry fetch attempt 1 at 10:20:25 PM
    npm info attempt registry request try #1 at 10:20:25 PM
    npm http fetch GET https://registry.npmjs.org/forwarded/-/forwarded-0.1.0.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/ipaddr.js
    [0m[91mnpm info retry fetch attempt 1 at 10:20:25 PM
    npm info attempt registry request try #1 at 10:20:25 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/ipaddr.js/-/ipaddr.js-1.0.5.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/forwarded/-/forwarded-0.1.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/ipaddr.js/-/ipaddr.js-1.0.5.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:20:25 PM
    npm http request GET https://registry.npmjs.org/destroy
    [0m[91mnpm info [0m[91mattempt registry request try #1 at 10:20:25 PM
    npm http request GET https://registry.npmjs.org/mime
    [0m[91mnpm http 200 https://registry.npmjs.org/destroy
    [0m[91mnpm info retry fetch attempt 1 at 10:20:25 PM
    npm info attempt registry request try #1 at 10:20:25 PM
    npm http fetch GET https://registry.npmjs.org/destroy/-/destroy-1.0.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/destroy/-/destroy-1.0.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/mime
    [0m[91mnpm info retry fetch attempt 1 at 10:20:26 PM
    [0m[91mnpm info attempt registry request try #1 at 10:20:26 PM
    npm http fetch GET https://registry.npmjs.org/mime/-/mime-1.3.4.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/mime/-/mime-1.3.4.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:20:26 PM
    [0m[91mnpm info attempt registry request try #1 at 10:20:26 PM
    npm http fetch GET https://registry.npmjs.org/send/-/send-0.12.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/send/-/send-0.12.3.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:20:26 PM
    npm info attempt registry request try #1 at 10:20:26 PM
    [0m[91mnpm [0m[91mhttp fetch GET https://registry.npmjs.org/debug/-/debug-2.2.0.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:20:26 PM
    [0m[91mnpm info attempt registry request try #1 at 10:20:26 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/etag/-/etag-1.6.0.tgz
    [0m[91mnpm info retry[0m[91m fetch attempt 1 at 10:20:26 PM
    [0m[91mnpm info attempt registry request try #1 at 10:20:26 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/ms/-/ms-0.7.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/debug/-/debug-2.2.0.tgz
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/etag/-/etag-1.6.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/ms/-/ms-0.7.1.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:20:27 PM
    npm[0m[91m http request GET https://registry.npmjs.org/media-typer
    [0m[91mnpm http 200 https://registry.npmjs.org/media-typer
    [0m[91mnpm info retry fetch attempt 1 at 10:20:27 PM
    [0m[91mnpm [0m[91minfo attempt registry request try #1 at 10:20:27 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/media-typer/-/media-typer-0.3.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/media-typer/-/media-typer-0.3.0.tgz
    [0m[91mnpm info lifecycle content-disposition@0.5.0~preinstall: content-disposition@0.5.0
    [0m[91mnpm info lifecycle content-type@1.0.1~preinstall: content-type@1.0.1
    [0m[91mnpm info lifecycle cookie@0.1.2~preinstall: cookie@0.1.2
    npm info lifecycle cookie-signature@1.0.6~preinstall: cookie-signature@1.0.6
    [0m[91mnpm info lifecycle crc@3.2.1~preinstall: crc@3.2.1
    [0m[91mnpm [0m[91minfo lifecycle depd@1.0.1~preinstall: depd@1.0.1
    [0m[91mnpm info lifecycle destroy@1.0.3~preinstall: destroy@1.0.3
    [0m[91mnpm info lifecycle ee-first@1.1.0~preinstall: ee-first@1.1.0
    npm info lifecycle escape-html@1.0.1~preinstall: escape-html@1.0.1
    [0m[91mnpm info lifecycle etag@1.5.1~preinstall: etag@1.5.1
    [0m[91mnpm info lifecycle forwarded@0.1.0~preinstall: forwarded@0.1.0
    [0m[91mnpm info lifecycle fresh@0.2.4~preinstall: fresh@0.2.4
    [0m[91mnpm info lifecycle[0m[91m ipaddr.js@1.0.5~preinstall: ipaddr.js@1.0.5
    [0m[91mnpm info lifecycle media-typer@0.3.0~preinstall: media-typer@0.3.0
    [0m[91mnpm info lifecycle merge-descriptors@0.0.2~preinstall: merge-descriptors@0.0.2
    [0m[91mnpm info lifecycle methods@1.1.2~preinstall: methods@1.1.2
    [0m[91mnpm info lifecycle mime@1.3.4~preinstall: mime@1.3.4
    npm info lifecycle mime-db@1.21.0~preinstall: mime-db@1.21.0
    npm info [0m[91mlifecycle mime-types@2.1.9~preinstall: mime-types@2.1.9
    npm info lifecycle ms@0.7.0~preinstall: ms@0.7.0
    [0m[91mnpm info [0m[91mlifecycle debug@2.1.3~preinstall: debug@2.1.3
    npm info lifecycle[0m[91m negotiator@0.5.3~preinstall: negotiator@0.5.3
    [0m[91mnpm info lifecycle accepts@1.2.13~preinstall: accepts@1.2.13
    [0m[91mnpm info lifecycle on-finished@2.2.1~preinstall: on-finished@2.2.1
    [0m[91mnpm info lifecycle finalhandler@0.3.3~preinstall: finalhandler@0.3.3
    [0m[91mnpm info lifecycle parseurl@1.3.1~preinstall: parseurl@1.3.1
    [0m[91mnpm info lifecycle path-to-regexp@0.1.3~preinstall: path-to-regexp@0.1.3
    [0m[91mnpm info lifecycle proxy-addr@1.0.10~preinstall: proxy-addr@1.0.10
    npm info[0m[91m lifecycle qs@2.3.3~preinstall: qs@2.3.3
    npm info lifecycle range-parser@1.0.3~preinstall: range-parser@1.0.3
    npm info lifecycle send@0.12.1~preinstall: send@0.12.1
    [0m[91mnpm info lifecycle etag@1.6.0~preinstall: etag@1.6.0
    [0m[91mnpm info lifecycle ms@0.7.1~preinstall: ms@0.7.1
    [0m[91mnpm info lifecycle debug@2.2.0~preinstall: debug@2.2.0
    [0m[91mnpm info lifecycle send@0.12.3~preinstall: send@0.12.3
    npm info lifecycle type-is@1.6.11~preinstall: type-is@1.6.11
    [0m[91mnpm info lifecycle utils-merge@1.0.0~preinstall: utils-merge@1.0.0
    npm info lifecycle serve-static@1.9.3~preinstall: serve-static@1.9.3
    npm info lifecycle vary@1.0.1~preinstall: vary@1.0.1
    [0m[91mnpm info lifecycle express@4.12.0~preinstall: express@4.12.0
    [0m[91mnpm info linkStuff content-disposition@0.5.0
    [0m[91mnpm info linkStuff content-type@1.0.1
    [0m[91mnpm info linkStuff cookie@0.1.2
    [0m[91mnpm[0m[91m info linkStuff cookie-signature@1.0.6
    [0m[91mnpm info linkStuff crc@3.2.1
    [0m[91mnpm info linkStuff depd@1.0.1
    [0m[91mnpm info linkStuff destroy@1.0.3
    [0m[91mnpm info[0m[91m linkStuff ee-first@1.1.0
    [0m[91mnpm info linkStuff escape-html@1.0.1
    [0m[91mnpm info linkStuff etag@1.5.1
    [0m[91mnpm info linkStuff forwarded@0.1.0
    [0m[91mnpm info linkStuff[0m[91m fresh@0.2.4
    [0m[91mnpm[0m[91m info linkStuff ipaddr.js@1.0.5
    [0m[91mnpm[0m[91m info linkStuff media-typer@0.3.0
    [0m[91mnpm info linkStuff[0m[91m merge-descriptors@0.0.2
    [0m[91mnpm info linkStuff methods@1.1.2
    [0m[91mnpm info linkStuff mime@1.3.4
    [0m[91mnpm info linkStuff mime-db@1.21.0
    [0m[91mnpm[0m[91m info linkStuff mime-types@2.1.9
    [0m[91mnpm info linkStuff ms@0.7.0
    [0m[91mnpm info linkStuff debug@2.1.3
    [0m[91mnpm info linkStuff negotiator@0.5.3
    [0m[91mnpm[0m[91m info linkStuff accepts@1.2.13
    [0m[91mnpm info linkStuff on-finished@2.2.1
    [0m[91mnpm[0m[91m info linkStuff finalhandler@0.3.3
    [0m[91mnpm info[0m[91m linkStuff parseurl@1.3.1
    [0m[91mnpm info linkStuff path-to-regexp@0.1.3
    [0m[91mnpm[0m[91m info linkStuff proxy-addr@1.0.10
    [0m[91mnpm info linkStuff qs@2.3.3
    [0m[91mnpm info linkStuff range-parser@1.0.3
    [0m[91mnpm info linkStuff send@0.12.1
    [0m[91mnpm info linkStuff etag@1.6.0
    [0m[91mnpm info linkStuff ms@0.7.1
    [0m[91mnpm info linkStuff debug@2.2.0
    [0m[91mnpm info linkStuff send@0.12.3
    [0m[91mnpm[0m[91m info linkStuff type-is@1.6.11
    [0m[91mnpm info linkStuff utils-merge@1.0.0
    [0m[91mnpm info linkStuff serve-static@1.9.3
    [0m[91mnpm info linkStuff vary@1.0.1
    [0m[91mnpm info linkStuff express@4.12.0
    [0m[91mnpm info lifecycle content-disposition@0.5.0~install: content-disposition@0.5.0
    [0m[91mnpm info lifecycle content-type@1.0.1~install: content-type@1.0.1
    [0m[91mnpm info lifecycle cookie@0.1.2~install: cookie@0.1.2
    [0m[91mnpm info lifecycle cookie-signature@1.0.6~install: cookie-signature@1.0.6
    [0m[91mnpm info lifecycle crc@3.2.1~install: crc@3.2.1
    [0m[91mnpm info lifecycle depd@1.0.1~install: depd@1.0.1
    [0m[91mnpm info lifecycle destroy@1.0.3~install: destroy@1.0.3
    [0m[91mnpm info lifecycle ee-first@1.1.0~install: ee-first@1.1.0
    [0m[91mnpm info lifecycle escape-html@1.0.1~install: escape-html@1.0.1
    [0m[91mnpm info lifecycle etag@1.5.1~install: etag@1.5.1
    [0m[91mnpm info lifecycle forwarded@0.1.0~install: forwarded@0.1.0
    [0m[91mnpm info lifecycle fresh@0.2.4~install: fresh@0.2.4
    [0m[91mnpm info lifecycle ipaddr.js@1.0.5~install: ipaddr.js@1.0.5
    [0m[91mnpm info lifecycle media-typer@0.3.0~install: media-typer@0.3.0
    [0m[91mnpm info lifecycle merge-descriptors@0.0.2~install: merge-descriptors@0.0.2
    npm info lifecycle methods@1.1.2~install: methods@1.1.2
    [0m[91mnpm info lifecycle mime@1.3.4~install: mime@1.3.4
    [0m[91mnpm info lifecycle mime-db@1.21.0~install: mime-db@1.21.0
    [0m[91mnpm[0m[91m info lifecycle mime-types@2.1.9~install: mime-types@2.1.9
    [0m[91mnpm info lifecycle ms@0.7.0~install: ms@0.7.0
    [0m[91mnpm info lifecycle debug@2.1.3~install: debug@2.1.3
    [0m[91mnpm info lifecycle negotiator@0.5.3~install: negotiator@0.5.3
    [0m[91mnpm info lifecycle accepts@1.2.13~install: accepts@1.2.13
    [0m[91mnpm info lifecycle on-finished@2.2.1~install: on-finished@2.2.1
    [0m[91mnpm info lifecycle finalhandler@0.3.3~install: finalhandler@0.3.3
    [0m[91mnpm info lifecycle parseurl@1.3.1~install: parseurl@1.3.1
    [0m[91mnpm info lifecycle path-to-regexp@0.1.3~install: path-to-regexp@0.1.3
    [0m[91mnpm[0m[91m info lifecycle proxy-addr@1.0.10~install: proxy-addr@1.0.10
    [0m[91mnpm info lifecycle qs@2.3.3~install: qs@2.3.3
    [0m[91mnpm info lifecycle range-parser@1.0.3~install: range-parser@1.0.3
    [0m[91mnpm info lifecycle send@0.12.1~install: send@0.12.1
    [0m[91mnpm info lifecycle etag@1.6.0~install: etag@1.6.0
    [0m[91mnpm info lifecycle ms@0.7.1~install: ms@0.7.1
    [0m[91mnpm info lifecycle debug@2.2.0~install: debug@2.2.0
    [0m[91mnpm info lifecycle send@0.12.3~install: send@0.12.3
    [0m[91mnpm info lifecycle type-is@1.6.11~install: type-is@1.6.11
    [0m[91mnpm info lifecycle utils-merge@1.0.0~install: utils-merge@1.0.0
    [0m[91mnpm info lifecycle serve-static@1.9.3~install: serve-static@1.9.3
    [0m[91mnpm info lifecycle vary@1.0.1~install: vary@1.0.1
    [0m[91mnpm info lifecycle express@4.12.0~install: express@4.12.0
    [0m[91mnpm info lifecycle content-disposition@0.5.0~postinstall: content-disposition@0.5.0
    [0m[91mnpm info lifecycle content-type@1.0.1~postinstall: content-type@1.0.1
    [0m[91mnpm info lifecycle cookie@0.1.2~postinstall: cookie@0.1.2
    [0m[91mnpm info lifecycle cookie-signature@1.0.6~postinstall: cookie-signature@1.0.6
    [0m[91mnpm info lifecycle crc@3.2.1~postinstall: crc@3.2.1
    [0m[91mnpm info lifecycle depd@1.0.1~postinstall: depd@1.0.1
    [0m[91mnpm info lifecycle destroy@1.0.3~postinstall: destroy@1.0.3
    [0m[91mnpm info lifecycle ee-first@1.1.0~postinstall: ee-first@1.1.0
    [0m[91mnpm info lifecycle escape-html@1.0.1~postinstall: escape-html@1.0.1
    [0m[91mnpm info lifecycle etag@1.5.1~postinstall: etag@1.5.1
    [0m[91mnpm info lifecycle forwarded@0.1.0~postinstall: forwarded@0.1.0
    [0m[91mnpm info lifecycle fresh@0.2.4~postinstall: fresh@0.2.4
    [0m[91mnpm info lifecycle ipaddr.js@1.0.5~postinstall: ipaddr.js@1.0.5
    [0m[91mnpm info lifecycle media-typer@0.3.0~postinstall: media-typer@0.3.0
    npm info lifecycle merge-descriptors@0.0.2~postinstall: merge-descriptors@0.0.2
    [0m[91mnpm info lifecycle methods@1.1.2~postinstall: methods@1.1.2
    [0m[91mnpm info lifecycle mime@1.3.4~postinstall: mime@1.3.4
    [0m[91mnpm info lifecycle mime-db@1.21.0~postinstall: mime-db@1.21.0
    [0m[91mnpm info lifecycle mime-types@2.1.9~postinstall: mime-types@2.1.9
    [0m[91mnpm info lifecycle ms@0.7.0~postinstall: ms@0.7.0
    [0m[91mnpm [0m[91minfo lifecycle debug@2.1.3~postinstall: debug@2.1.3
    [0m[91mnpm info lifecycle negotiator@0.5.3~postinstall: negotiator@0.5.3
    [0m[91mnpm info lifecycle accepts@1.2.13~postinstall: accepts@1.2.13
    [0m[91mnpm info lifecycle on-finished@2.2.1~postinstall: on-finished@2.2.1
    [0m[91mnpm info lifecycle finalhandler@0.3.3~postinstall: finalhandler@0.3.3
    [0m[91mnpm info lifecycle parseurl@1.3.1~postinstall: parseurl@1.3.1
    [0m[91mnpm info lifecycle path-to-regexp@0.1.3~postinstall: path-to-regexp@0.1.3
    [0m[91mnpm info lifecycle proxy-addr@1.0.10~postinstall: proxy-addr@1.0.10
    [0m[91mnpm info[0m[91m lifecycle qs@2.3.3~postinstall: qs@2.3.3
    [0m[91mnpm info lifecycle range-parser@1.0.3~postinstall: range-parser@1.0.3
    [0m[91mnpm info lifecycle send@0.12.1~postinstall: send@0.12.1
    [0m[91mnpm info lifecycle etag@1.6.0~postinstall: etag@1.6.0
    [0m[91mnpm[0m[91m [0m[91minfo lifecycle ms@0.7.1~postinstall: ms@0.7.1
    [0m[91mnpm info lifecycle debug@2.2.0~postinstall: debug@2.2.0
    [0m[91mnpm info lifecycle send@0.12.3~postinstall: send@0.12.3
    [0m[91mnpm info lifecycle type-is@1.6.11~postinstall: type-is@1.6.11
    [0m[91mnpm info[0m[91m lifecycle utils-merge@1.0.0~postinstall: utils-merge@1.0.0
    [0m[91mnpm info lifecycle serve-static@1.9.3~postinstall: serve-static@1.9.3
    [0m[91mnpm info lifecycle vary@1.0.1~postinstall: vary@1.0.1
    [0m[91mnpm info [0m[91mlifecycle[0m[91m express@4.12.0~postinstall: express@4.12.0
    [0m[91mnpm info lifecycle node-hello-world@0.0.1~preinstall: node-hello-world@0.0.1
    [0m[91mnpm info linkStuff node-hello-world@0.0.1
    [0m[91mnpm info lifecycle node-hello-world@0.0.1~install: node-hello-world@0.0.1
    [0m[91mnpm info lifecycle node-hello-world@0.0.1~postinstall: node-hello-world@0.0.1
    [0m[91mnpm info lifecycle node-hello-world@0.0.1~prepublish: node-hello-world@0.0.1
    [0mnode-hello-world@0.0.1 /src
    `-- express@4.12.0 
      +-- accepts@1.2.13 
      | +-- mime-types@2.1.9 
      | | `-- mime-db@1.21.0 
      | `-- negotiator@0.5.3 
      +-- content-disposition@0.5.0 
      +-- content-type@1.0.1 
      +-- cookie@0.1.2 
      +-- cookie-signature@1.0.6 
      +-- debug@2.1.3 
      | `-- ms@0.7.0 
      +-- depd@1.0.1 
      +-- escape-html@1.0.1 
      +-- etag@1.5.1 
      | `-- crc@3.2.1 
      +-- finalhandler@0.3.3 
      +-- fresh@0.2.4 
      +-- merge-descriptors@0.0.2 
      +-- methods@1.1.2 
      +-- on-finished@2.2.1 
      | `-- ee-first@1.1.0 
      +-- parseurl@1.3.1 
      +-- path-to-regexp@0.1.3 
      +-- proxy-addr@1.0.10 
      | +-- forwarded@0.1.0 
      | `-- ipaddr.js@1.0.5 
      +-- qs@2.3.3 
      +-- range-parser@1.0.3 
      +-- send@0.12.1 
      | +-- destroy@1.0.3 
      | `-- mime@1.3.4 
      +-- serve-static@1.9.3 
      | `-- send@0.12.3 
      |   +-- debug@2.2.0 
      |   +-- etag@1.6.0 
      |   `-- ms@0.7.1 
      +-- type-is@1.6.11 
      | `-- media-typer@0.3.0 
      +-- utils-merge@1.0.0 
      `-- vary@1.0.1 
    
    [91mnpm info ok 
    [0m ---> 4f3e15898058
    Removing intermediate container 7f7cc9bf2d2a
    Step 5 : EXPOSE 80
     ---> Running in 961ca0529fa2
     ---> 4421612b1c04
    Removing intermediate container 961ca0529fa2
    Step 6 : CMD node index.js
     ---> Running in 5a6775d4b43c
     ---> d7a1df9bc261
    Removing intermediate container 5a6775d4b43c
    Successfully built d7a1df9bc261


and run the image in the background, exposing port 80


```bash
docker run -p 80:80 --name web -d node-hello
```

    7809662ff35d886dd33b8b21d9556e13606e85ec547f37266b2c6302208efa0f


Now let's use curl to access this container (default port for curl is 80)


```bash
curl http://localhost
```

    <html><body>Hello from Node.js container 7809662ff35d</body></html>

<a name="medium-python"/>
## Creating a Python application from the Python 'LanguageStack' Docker image
[TOP](#TOP)

<font size=+1 color="#77f">
<b>The goal of this step is to demonstrate the use of the Python *Language Stack*.</b>
</font>

Now let's look at a Python example.
To run a Node.js application this time we will need


Let's pull and examine the official 'Docker Language Stack' image of Python

Note how the earliest image layers (at the bottom of the list) have the same image ids
as the earliest image layers of the Node;js image.

So we can see that they were both created from the same base.


```bash
docker pull python
```

    Using default tag: latest
    latest: Pulling from library/python
    [0B
    [0B
    [0B
    [0B
    [0B
    [0B
    [5B
    [0B
    [7BDigest: sha256:4651b83dd903ce78b1c455794f63d4108d9469a6c7fe97cd07d08a77b7e72435
    Status: Image is up to date for python:latest



```bash
docker images python
```

    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    python              latest              93049cc049a6        9 days ago          689.1 MB
    python              2.7                 31093b2dabe2        9 days ago          676.1 MB



```bash
docker history python
```

    IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
    93049cc049a6        9 days ago          /bin/sh -c #(nop) CMD ["python3"]               0 B                 
    <missing>           9 days ago          /bin/sh -c cd /usr/local/bin  && ln -s easy_i   48 B                
    <missing>           9 days ago          /bin/sh -c set -ex  && gpg --keyserver ha.poo   81.53 MB            
    <missing>           9 days ago          /bin/sh -c #(nop) ENV PYTHON_PIP_VERSION=7.1.   0 B                 
    <missing>           9 days ago          /bin/sh -c #(nop) ENV PYTHON_VERSION=3.5.1      0 B                 
    <missing>           9 days ago          /bin/sh -c #(nop) ENV GPG_KEY=97FC712E4C024BB   0 B                 
    <missing>           9 days ago          /bin/sh -c #(nop) ENV LANG=C.UTF-8              0 B                 
    <missing>           9 days ago          /bin/sh -c apt-get purge -y python.*            978.7 kB            
    <missing>           9 days ago          /bin/sh -c apt-get update && apt-get install    314.7 MB            
    <missing>           9 days ago          /bin/sh -c apt-get update && apt-get install    122.6 MB            
    <missing>           9 days ago          /bin/sh -c apt-get update && apt-get install    44.3 MB             
    <missing>           9 days ago          /bin/sh -c #(nop) CMD ["/bin/bash"]             0 B                 
    <missing>           9 days ago          /bin/sh -c #(nop) ADD file:e5a3d20748c5d3dd5f   125.1 MB            



```bash
docker run python python --version
```

    Python 3.5.1



```bash
cd ~/src/python_flask
cat Dockerfile
```

    FROM python:2.7
    
    MAINTAINER "Docker Build Lab" <dockerlabs@mjbright.net>
    
    WORKDIR /src
    
    ADD requirements.txt /src/
    
    RUN pip install -r requirements.txt
    
    ADD . /src
    
    CMD python flask_redis_app.py
    



```bash
docker build -t lab/python_flask .

```

    
    Step 1 : FROM python:2.7
     ---> 31093b2dabe2
    Step 2 : MAINTAINER "Docker Build Lab" <dockerlabs@mjbright.net>
     ---> Running in 5694bf90e230
     ---> b49d2d1c41e4
    Removing intermediate container 5694bf90e230
    Step 3 : WORKDIR /src
     ---> Running in 056b78f2c2ed
     ---> 87dbd1f3c183
    Removing intermediate container 056b78f2c2ed
    Step 4 : ADD requirements.txt /src/
     ---> 999c559fd889
    Removing intermediate container ca91a1150061
    Step 5 : RUN pip install -r requirements.txt
     ---> Running in dd908f954dc2
    Collecting flask (from -r requirements.txt (line 1))
      Downloading Flask-0.10.1.tar.gz (544kB)
    Collecting redis (from -r requirements.txt (line 2))
      Downloading redis-2.10.5-py2.py3-none-any.whl (60kB)
    Collecting Werkzeug>=0.7 (from flask->-r requirements.txt (line 1))
      Downloading Werkzeug-0.11.3-py2.py3-none-any.whl (305kB)
    Collecting Jinja2>=2.4 (from flask->-r requirements.txt (line 1))
      Downloading Jinja2-2.8-py2.py3-none-any.whl (263kB)
    Collecting itsdangerous>=0.21 (from flask->-r requirements.txt (line 1))
      Downloading itsdangerous-0.24.tar.gz (46kB)
    Collecting MarkupSafe (from Jinja2>=2.4->flask->-r requirements.txt (line 1))
      Downloading MarkupSafe-0.23.tar.gz
    Building wheels for collected packages: flask, itsdangerous, MarkupSafe
      Running setup.py bdist_wheel for flask
      Stored in directory: /root/.cache/pip/wheels/d2/db/61/cb9b80526b8f3ba89248ec0a29d6da1bb6013681c930fca987
      Running setup.py bdist_wheel for itsdangerous
      Stored in directory: /root/.cache/pip/wheels/97/c0/b8/b37c320ff57e15f993ba0ac98013eee778920b4a7b3ebae3cf
      Running setup.py bdist_wheel for MarkupSafe
      Stored in directory: /root/.cache/pip/wheels/94/a7/79/f79a998b64c1281cb99fa9bbd33cfc9b8b5775f438218d17a7
    Successfully built flask itsdangerous MarkupSafe
    Installing collected packages: Werkzeug, MarkupSafe, Jinja2, itsdangerous, flask, redis
    Successfully installed Jinja2-2.8 MarkupSafe-0.23 Werkzeug-0.11.3 flask-0.10.1 itsdangerous-0.24 redis-2.10.5
    [91mYou are using pip version 7.1.2, however version 8.0.2 is available.
    You should consider upgrading via the 'pip install --upgrade pip' command.
    [0m ---> a324a5623f13
    Removing intermediate container dd908f954dc2
    Step 6 : ADD . /src
     ---> 4e81515ecfe3
    Removing intermediate container 5f39587c3c69
    Step 7 : CMD python flask_redis_app.py
     ---> Running in 8f572157df8e
     ---> 4370d920749f
    Removing intermediate container 8f572157df8e
    Successfully built 4370d920749f



```bash
docker images lab/*
```

    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    lab/python_flask    latest              4370d920749f        11 seconds ago      682.9 MB
    lab/toolset         latest              06585695f835        17 minutes ago      3.245 MB
    lab/go-hello        latest              75404e153500        19 minutes ago      2.367 MB
    lab/c_prog          latest              45069c143064        19 minutes ago      877.2 kB
    lab/basic           latest              b1c72c79ea90        19 minutes ago      689.1 MB


Now let's run this container in the background

This example is incomplete ... to be done ...


```bash
docker run -d lab/python_flask
```


```bash
curl http://localhost:5000
```

  <a name="Compose" />
#   Using Compose
<a href="#TOP">TOP</a>
  
#   Building complex systems with Compose
<a href="#TOP">TOP</a>


```bash
cd ~/src/compose
```

    

Create a docker-compose.yml specification file with the following contents


```bash
cat docker-compose.yml
```

    
    version: 2
    services:
      weba:
        build: ../nodeJS
        expose:
          - 80
    
      webb:
        build: ../createTinyGo
        command: /webserver
        # dockerfile: Dockerfile.webserver
        expose:
          - 80
    
      webc:
        image: python
        command: python3 -m http.server --bind 0.0.0.0 80
        expose:
          - 80
    
      haproxy:
        image: haproxy
        volumes:
         - ./haproxy:/usr/local/etc/haproxy/
        links:
         - weba
         - webb
         - webc
        ports:
         - "80:80"
         - "70:70"
        expose:
         - "80"
         - "70"
    
    


Let's look at the docker-compose options


```bash
docker-compose
```

    Define and run multi-container applications with Docker.
    
    Usage:
      docker-compose [-f=<arg>...] [options] [COMMAND] [ARGS...]
      docker-compose -h|--help
    
    Options:
      -f, --file FILE           Specify an alternate compose file (default: docker-compose.yml)
      -p, --project-name NAME   Specify an alternate project name (default: directory name)
      --verbose                 Show more output
      -v, --version             Print version and exit
    
    Commands:
      build              Build or rebuild services
      config             Validate and view the compose file
      create             Create services
      down               Stop and remove containers, networks, images, and volumes
      events             Receive real time events from containers
      help               Get help on a command
      kill               Kill containers
      logs               View output from containers
      pause              Pause services
      port               Print the public port for a port binding
      ps                 List containers
      pull               Pulls service images
      restart            Restart services
      rm                 Remove stopped containers
      run                Run a one-off command
      scale              Set number of containers for a service
      start              Start services
      stop               Stop services
      unpause            Unpause services
      up                 Create and start containers
      version            Show the Docker-Compose version information



```bash
docker-compose stop
```

    


```bash
docker-compose rm -f
```

    No stopped containers


This part of the lab requires some debugging also


```bash
docker-compose up -d
```

    Building webb
    Step 1 : FROM scratch
     ---> 
    Step 2 : MAINTAINER "Docker Build Lab" <dockerlabs@mjbright.net>
     ---> Using cache
     ---> 5b37a53abbef
    Step 3 : ADD ./hello /hello
     ---> 02bd6ef35abb
    Removing intermediate container 758c46e42f42
    Step 4 : CMD /hello
     ---> Running in 748c79ec42f9
     ---> e2256babf71f
    Removing intermediate container 748c79ec42f9
    Successfully built e2256babf71f
    Creating compose_webb_1
    [31mERROR[0m: Container command not found or does not exist.


```bash
docker-compose logs
Attaching to compose_haproxy_1, compose_weba_1, compose_webc_1, compose_webb_1
haproxy_1 | [ALERT] 032/221525 (1) : Could not open configuration file /usr/local/etc/haproxy/haproxy.cfg : No such file or directory
haproxy_1 | [ALERT] 032/221646 (1) : Could not open configuration file /usr/local/etc/haproxy/haproxy.cfg : No such file or directory
weba_1    | Running on http://localhost
webc_1    | Running on http://localhost
webb_1    | Running on http://localhost
```


```bash
docker-compose ps
```

         Name         Command      State     Ports 
    ----------------------------------------------
    compose_webb_1   /webserver   Exit 127         



```bash
docker-compose scale weba=5
```

    
    
    
    
    
    Building weba
    Building weba
    Building weba
    Building weba
    Building weba
    Step 1 : FROM node
     ---> baa18fdeb577
    Step 2 : ADD src/ /src
    Step 1 : FROM node
     ---> baa18fdeb577
    Step 2 : ADD src/ /src
    Step 1 : FROM node
     ---> baa18fdeb577
    Step 2 : ADD src/ /src
    Step 1 : FROM node
     ---> baa18fdeb577
    Step 2 : ADD src/ /src
    Step 1 : FROM node
     ---> baa18fdeb577
    Step 2 : ADD src/ /src
     ---> 49cae68c8d2e
    Removing intermediate container 8144cefdc62a
    Step 3 : WORKDIR /src
     ---> Running in 0433b1679737
     ---> 6db194a991f3
    Removing intermediate container 3dd11194ebe3
    Step 3 : WORKDIR /src
     ---> Running in def8a2fe6f82
     ---> bf0d13ff471b
     ---> 9a2280a366ba
    Removing intermediate container d25cf6099530
    Step 3 : WORKDIR /src
    Removing intermediate container 409fb81028fc
    Step 3 : WORKDIR /src
     ---> 53ce2821e752
     ---> 31ea8e7f953a
     ---> Running in b35bd00b892b
     ---> Running in 79d5d37b3af2
    Removing intermediate container 0433b1679737
     ---> 19c534961e55
    Step 4 : RUN npm install
    Removing intermediate container 540c85ba858d
    Step 3 : WORKDIR /src
     ---> Running in fba4ae11b2e7
     ---> Running in 0da567dbed2d
    Removing intermediate container def8a2fe6f82
    Step 4 : RUN npm install
     ---> Running in a13d7268fb35
     ---> 867575febaf1
    Error removing intermediate container b35bd00b892b: rmdriverfs: Driver aufs failed to remove root filesystem b35bd00b892b2a48782d3b756f6112255c047e30b1af1a307922c4dee491b534: rename /var/lib/docker/aufs/mnt/c74071547b571d593a33da25a3fdccc56a7770aaa7729d97dc2cd826bf775628 /var/lib/docker/aufs/mnt/c74071547b571d593a33da25a3fdccc56a7770aaa7729d97dc2cd826bf775628-removing: device or resource busy
    Step 4 : RUN npm install
     ---> 7778225311e4
     ---> bc748e195561
     ---> Running in ec2d489e60e3
    Error removing intermediate container 0da567dbed2d: rmdriverfs: Driver aufs failed to remove root filesystem 0da567dbed2d782c614c2ac8e51f1a317c8a4bd6ff22a71491a9a4b0ac0f0162: rename /var/lib/docker/aufs/mnt/3e8fd3b147c4e984e0986c2f009673ee5288582d8ba9be012fb4a3b48faa0ba7 /var/lib/docker/aufs/mnt/3e8fd3b147c4e984e0986c2f009673ee5288582d8ba9be012fb4a3b48faa0ba7-removing: device or resource busy
    Step 4 : RUN npm install
    Error removing intermediate container 79d5d37b3af2: rmdriverfs: Driver aufs failed to remove root filesystem 79d5d37b3af28b713ab799e3fecce6764b24a5a35e062519fde2101422275472: rename /var/lib/docker/aufs/mnt/e77116d9bfa3333fadbfe27117d9462631f86402a956cdd9f951fa5404077154 /var/lib/docker/aufs/mnt/e77116d9bfa3333fadbfe27117d9462631f86402a956cdd9f951fa5404077154-removing: device or resource busy
    Step 4 : RUN npm install
     ---> Running in aaeea3da6c95
     ---> Running in 6ac9d2134bd0
    [91mnpm[0m[91m [0m[91minfo[0m[91m [0m[91mit worked if it ends with ok
    [0m[91mnpm info using npm@3.3.12
    npm[0m[91m info[0m[91m [0m[91musing node@v5.5.0
    [0m[91mnpm[0m[91m info[0m[91m [0m[91mit worked if it ends with[0m[91m ok
    [0m[91mnpm[0m[91m info using npm@3.3.12
    npm[0m[91m info using node@v5.5.0
    [0m[91mnpm[0m[91mnpm[0m[91m [0m[91m [0m[91minfo[0m[91minfo[0m[91m it worked if it ends with ok
    [0m[91m it worked if it ends with ok
    [0m[91mnpm[0m[91mnpm info using npm@3.3.12
    [0m[91m info[0m[91mnpm[0m[91m using npm@3.3.12
    npm info using node@v5.5.0
    [0m[91m info using node@v5.5.0
    [0m[91mnpm[0m[91m [0m[91minfo it worked if it ends with ok
    npm info using npm@3.3.12
    npm info using node@v5.5.0
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:27:19 PM
    [0m[91mnpm[0m[91m http request GET https://registry.npmjs.org/express
    [0m[91mnpm[0m[91m info [0m[91mattempt registry request try #1 at 10:27:19 PM
    [0m[91mnpm[0m[91m [0m[91mhttp[0m[91m request GET https://registry.npmjs.org/express
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:27:19 PM
    [0m[91mnpm[0m[91mnpm[0m[91m info attempt[0m[91m registry request try #1 at 10:27:19 PM
    [0m[91mnpm[0m[91m http request GET https://registry.npmjs.org/express
    [0m[91m http request GET https://registry.npmjs.org/express
    [0m[91mnpm[0m[91m info [0m[91mattempt registry request try #1 at 10:27:20 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/express
    [0m[91mnpm http 200 https://registry.npmjs.org/express
    [0m[91mnpm info retry fetch attempt 1 at 10:27:27 PM
    npm info attempt registry request try #1 at 10:27:27 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/express/-/express-4.12.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/express/-/express-4.12.0.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:27:28 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/accepts
    [0m[91mnpm info attempt registry request try #1 at 10:27:28 PM
    npm http request GET https://registry.npmjs.org/content-disposition
    [0m[91mnpm info attempt registry request try #1 at 10:27:28 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/content-type
    [0m[91mnpm info attempt registry request try #1 at 10:27:28 PM
    npm[0m[91m http request GET https://registry.npmjs.org/cookie-signature
    npm info [0m[91mattempt registry request try #1 at 10:27:28 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/debug
    [0m[91mnpm info [0m[91mattempt[0m[91m registry request try #1 at 10:27:28 PM
    [0m[91mnpm http request[0m[91m GET https://registry.npmjs.org/depd
    [0m[91mnpm info attempt registry request try #1 at 10:27:28 PM
    npm http request GET https://registry.npmjs.org/escape-html
    [0m[91mnpm info attempt registry request try #1 at 10:27:28 PM
    npm http request GET https://registry.npmjs.org/etag
    [0m[91mnpm info attempt registry request try #1 at 10:27:28 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/finalhandler
    [0m[91mnpm info attempt[0m[91m registry request try #1 at 10:27:28 PM
    npm [0m[91mhttp request GET https://registry.npmjs.org/fresh
    [0m[91mnpm info attempt registry request try #1 at 10:27:28 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/methods
    [0m[91mnpm info attempt registry request try #1 at 10:27:28 PM
    npm http request GET https://registry.npmjs.org/on-finished
    [0m[91mnpm info attempt registry request try #1 at 10:27:28 PM
    [0m[91mnpm http[0m[91m request GET https://registry.npmjs.org/parseurl
    npm info attempt registry request try #1 at 10:27:28 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/path-to-regexp
    [0m[91mnpm info attempt registry request try #1 at 10:27:28 PM
    npm http request GET https://registry.npmjs.org/proxy-addr
    [0m[91mnpm[0m[91m info attempt[0m[91m registry request try #1 at 10:27:28 PM
    npm http [0m[91mrequest GET https://registry.npmjs.org/qs
    npm info [0m[91mattempt registry request try #1 at 10:27:28 PM
    npm http request GET https://registry.npmjs.org/range-parser
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:27:28 PM
    npm http request GET https://registry.npmjs.org/send
    [0m[91mnpm info attempt registry request try #1 at 10:27:28 PM
    npm http request GET https://registry.npmjs.org/serve-static
    [0m[91mnpm info attempt registry request try #1 at 10:27:28 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/type-is
    npm info attempt registry request try #1 at 10:27:28 PM
    npm http request GET https://registry.npmjs.org/vary
    [0m[91mnpm info attempt registry request try #1 at 10:27:28 PM
    npm http request GET https://registry.npmjs.org/cookie
    [0m[91mnpm info attempt registry request try #1 at 10:27:28 PM
    npm http request GET https://registry.npmjs.org/merge-descriptors
    [0m[91mnpm info attempt registry request try #1 at 10:27:28 PM
    npm http request[0m[91m GET https://registry.npmjs.org/utils-merge
    [0m[91mnpm http 200 https://registry.npmjs.org/utils-merge
    [0m[91mnpm[0m[91m [0m[91minfo retry fetch attempt 1 at 10:27:29 PM
    [0m[91mnpm [0m[91minfo attempt registry request try #1 at 10:27:29 PM
    npm[0m[91m http fetch GET https://registry.npmjs.org/utils-merge/-/utils-merge-1.0.0.tgz
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/utils-merge/-/utils-merge-1.0.0.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/content-type
    [0m[91mnpm info retry fetch attempt 1 at 10:27:29 PM
    npm info[0m[91m attempt registry request try #1 at 10:27:29 PM
    npm[0m[91m http fetch GET https://registry.npmjs.org/content-type/-/content-type-1.0.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/methods
    [0m[91mnpm[0m[91m info retry fetch attempt 1 at 10:27:32 PM
    npm info attempt registry request try #1 at 10:27:32 PM
    npm http [0m[91mfetch GET https://registry.npmjs.org/methods/-/methods-1.1.2.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/content-disposition
    [0m[91mnpm info retry fetch attempt 1 at 10:27:32 PM
    npm info[0m[91m attempt[0m[91m registry request try #1 at 10:27:32 PM
    npm http[0m[91m fetch[0m[91m GET https://registry.npmjs.org/content-disposition/-/content-disposition-0.5.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/methods/-/methods-1.1.2.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/escape-html
    [0m[91mnpm info retry fetch attempt 1 at 10:27:32 PM
    npm info attempt registry request try #1 at 10:27:32 PM
    npm http fetch GET https://registry.npmjs.org/escape-html/-/escape-html-1.0.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/cookie
    [0m[91mnpm[0m[91m info retry fetch attempt 1 at 10:27:32 PM
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:27:32 PM
    [0m[91mnpm[0m[91m http fetch GET https://registry.npmjs.org/cookie/-/cookie-0.1.2.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/content-type/-/content-type-1.0.1.tgz
    [0m[91mnpm http fetch[0m[91m 200 https://registry.npmjs.org/escape-html/-/escape-html-1.0.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/cookie/-/cookie-0.1.2.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/on-finished
    [0m[91mnpm info retry fetch attempt 1 at 10:27:33 PM
    npm info attempt registry request try #1 at 10:27:33 PM
    npm http fetch GET https://registry.npmjs.org/on-finished/-/on-finished-2.2.1.tgz
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/express
    [0m[91mnpm[0m[91mnpm http 200 https://registry.npmjs.org/send
    [0m[91m http 200 https://registry.npmjs.org/express
    [0m[91mnpm[0m[91m info retry fetch attempt 1 at 10:27:34 PM
    [0m[91mnpm info attempt registry request try #1 at 10:27:34 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/send/-/send-0.12.1.tgz
    [0m[91mnpm[0m[91m info retry fetch attempt 1 at 10:27:35 PM
    npm[0m[91mnpm http 200 https://registry.npmjs.org/fresh
    [0m[91m info attempt registry request try #1 at 10:27:35 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/express/-/express-4.12.0.tgz
    [0m[91mnpm[0m[91m info retry fetch attempt 1 at 10:27:35 PM
    npm info attempt registry request try #1 at 10:27:35 PM
    npm http fetch GET https://registry.npmjs.org/fresh/-/fresh-0.2.4.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/parseurl
    [0m[91mnpm info retry fetch attempt 1 at 10:27:35 PM
    [0m[91mnpm info attempt[0m[91m registry request try #1 at 10:27:35 PM
    npm http fetch GET https://registry.npmjs.org/parseurl/-/parseurl-1.3.1.tgz
    [0m[91mnpm[0m[91m http [0m[91m200[0m[91m https://registry.npmjs.org/cookie-signature
    [0m[91mnpm[0m[91m [0m[91mhttp [0m[91mfetch 200 https://registry.npmjs.org/express/-/express-4.12.0.tgz
    [0m[91mnpm[0m[91m [0m[91mhttp fetch 200 https://registry.npmjs.org/send/-/send-0.12.1.tgz
    [0m[91mnpm[0m[91m [0m[91mhttp fetch 200 https://registry.npmjs.org/fresh/-/fresh-0.2.4.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:27:35 PM
    npm info attempt registry request try #1 at 10:27:35 PM
    npm http fetch[0m[91m GET https://registry.npmjs.org/cookie-signature/-/cookie-signature-1.0.6.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/parseurl/-/parseurl-1.3.1.tgz
    [0m[91mnpm[0m[91m info retry fetch attempt 1 at 10:27:36 PM
    npm[0m[91mnpm http fetch 200 https://registry.npmjs.org/content-disposition/-/content-disposition-0.5.0.tgz
    [0m[91m info attempt registry request try #1 at 10:27:36 PM
    [0m[91mnpm[0m[91m http fetch GET https://registry.npmjs.org/express/-/express-4.12.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/cookie-signature/-/cookie-signature-1.0.6.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/express/-/express-4.12.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/on-finished/-/on-finished-2.2.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/qs
    [0m[91mnpm info retry fetch attempt 1 at 10:27:37 PM
    npm[0m[91m info attempt registry request try #1 at 10:27:37 PM
    npm http fetch GET https://registry.npmjs.org/qs/-/qs-2.3.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/finalhandler
    [0m[91mnpm info retry fetch attempt 1 at 10:27:37 PM
    npm [0m[91minfo attempt registry request try #1 at 10:27:37 PM
    npm http fetch GET https://registry.npmjs.org/finalhandler/-/finalhandler-0.3.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/qs/-/qs-2.3.3.tgz
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/finalhandler/-/finalhandler-0.3.3.tgz
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:27:37 PM
    [0m[91mnpm[0m[91m http[0m[91m request[0m[91m GET https://registry.npmjs.org/accepts
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:27:37 PM
    npm[0m[91m http request GET https://registry.npmjs.org/content-disposition
    [0m[91mnpm info[0m[91m attempt registry request try #1 at 10:27:37 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/content-type
    [0m[91mnpm[0m[91m info [0m[91mattempt registry request try #1 at 10:27:37 PM
    npm http[0m[91m request GET https://registry.npmjs.org/cookie-signature
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:27:37 PM
    [0m[91mnpm[0m[91m http request GET https://registry.npmjs.org/debug
    [0m[91mnpm info [0m[91mattempt[0m[91m registry request try #1 at 10:27:37 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/depd
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:27:37 PM
    [0m[91mnpm[0m[91m http request GET https://registry.npmjs.org/escape-html
    [0m[91mnpm info [0m[91mattempt registry request try #1 at 10:27:37 PM
    npm http request GET https://registry.npmjs.org/etag
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:27:37 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/finalhandler
    [0m[91mnpm info attempt registry request try #1 at 10:27:37 PM
    [0m[91mnpm [0m[91mhttp request GET https://registry.npmjs.org/fresh
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:27:37 PM
    npm http request GET https://registry.npmjs.org/methods
    [0m[91mnpm info attempt registry request try #1 at 10:27:37 PM
    npm http request GET https://registry.npmjs.org/on-finished
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:27:37 PM
    npm[0m[91m http[0m[91m request GET https://registry.npmjs.org/parseurl
    [0m[91mnpm info attempt registry request try #1 at 10:27:37 PM
    npm http request GET https://registry.npmjs.org/path-to-regexp
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:27:37 PM
    npm http request GET https://registry.npmjs.org/proxy-addr
    [0m[91mnpm[0m[91m info attempt[0m[91m registry request try #1 at 10:27:37 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/qs
    npm info attempt registry request try #1 at 10:27:37 PM
    npm http request GET https://registry.npmjs.org/range-parser
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:27:37 PM
    npm http request GET https://registry.npmjs.org/send
    npm info [0m[91mattempt registry request try #1 at 10:27:37 PM
    npm http request GET https://registry.npmjs.org/serve-static
    [0m[91mnpm [0m[91minfo attempt registry request try #1 at 10:27:37 PM
    npm[0m[91m http request GET https://registry.npmjs.org/type-is
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:27:37 PM
    npm http request[0m[91m GET https://registry.npmjs.org/vary
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:27:37 PM
    npm http request GET https://registry.npmjs.org/cookie
    [0m[91mnpm info attempt registry request try #1 at 10:27:37 PM
    npm http request GET https://registry.npmjs.org/merge-descriptors
    npm info[0m[91m attempt registry request try #1 at 10:27:37 PM
    npm http request GET https://registry.npmjs.org/utils-merge
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:27:38 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/accepts
    [0m[91mnpm [0m[91minfo attempt registry request try #1 at 10:27:38 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/content-disposition
    [0m[91mnpm info attempt registry request try #1 at 10:27:38 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/content-type
    [0m[91mnpm info attempt registry request try #1 at 10:27:38 PM
    npm http request GET https://registry.npmjs.org/cookie-signature
    [0m[91mnpm info attempt registry request try #1 at 10:27:38 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/debug
    [0m[91mnpm info [0m[91mattempt[0m[91m registry request try #1 at 10:27:38 PM
    npm http[0m[91m request GET https://registry.npmjs.org/depd
    [0m[91mnpm info attempt registry request try #1 at 10:27:38 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/escape-html
    npm [0m[91minfo attempt registry request try #1 at 10:27:38 PM
    npm http request GET https://registry.npmjs.org/etag
    [0m[91mnpm info attempt registry request try #1 at 10:27:38 PM
    npm http request GET https://registry.npmjs.org/finalhandler
    [0m[91mnpm info attempt registry request try #1 at 10:27:38 PM
    [0m[91mnpm[0m[91m [0m[91mhttp request GET https://registry.npmjs.org/fresh
    [0m[91mnpm info attempt registry request try #1 at 10:27:38 PM
    npm http request GET https://registry.npmjs.org/methods
    npm info attempt registry request try #1 at 10:27:38 PM
    npm http request GET https://registry.npmjs.org/on-finished
    npm info attempt registry request try #1 at 10:27:38 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/parseurl
    npm info attempt registry request try #1 at 10:27:38 PM
    npm http request GET https://registry.npmjs.org/path-to-regexp
    [0m[91mnpm info[0m[91m attempt registry request try #1 at 10:27:38 PM
    npm http request GET https://registry.npmjs.org/proxy-addr
    [0m[91mnpm info attempt[0m[91m registry request try #1 at 10:27:38 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/qs
    npm info attempt registry request try #1 at 10:27:38 PM
    npm http [0m[91mrequest GET https://registry.npmjs.org/range-parser
    [0m[91mnpm info attempt registry request try #1 at 10:27:38 PM
    npm http request GET https://registry.npmjs.org/send
    [0m[91mnpm info[0m[91m attempt registry request try #1 at 10:27:38 PM
    npm http request GET https://registry.npmjs.org/serve-static
    [0m[91mnpm info attempt registry request try #1 at 10:27:38 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/type-is
    [0m[91mnpm info attempt registry request try #1 at 10:27:38 PM
    npm http request GET https://registry.npmjs.org/vary
    [0m[91mnpm info attempt registry request try #1 at 10:27:38 PM
    npm http request GET https://registry.npmjs.org/cookie
    [0m[91mnpm http 200 https://registry.npmjs.org/merge-descriptors
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:27:38 PM
    npm http request GET https://registry.npmjs.org/merge-descriptors
    [0m[91mnpm[0m[91m [0m[91minfo attempt registry request try #1 at 10:27:38 PM
    [0m[91mnpm[0m[91m [0m[91mhttp request GET https://registry.npmjs.org/utils-merge
    [0m[91mnpm info retry fetch attempt 1 at 10:27:38 PM
    npm info attempt registry request try #1 at 10:27:38 PM
    npm http fetch GET https://registry.npmjs.org/merge-descriptors/-/merge-descriptors-0.0.2.tgz
    [0m[91mnpm http[0m[91m 200 https://registry.npmjs.org/content-type
    [0m[91mnpm info[0m[91m retry fetch attempt 1 at 10:27:38 PM
    [0m[91mnpm[0m[91m [0m[91minfo[0m[91m attempt registry request try #1 at 10:27:38 PM
    npm[0m[91m http fetch[0m[91m GET https://registry.npmjs.org/content-type/-/content-type-1.0.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/etag
    [0m[91mnpm info retry fetch attempt 1 at 10:27:38 PM
    npm info attempt registry request try #1 at 10:27:38 PM
    npm http fetch GET https://registry.npmjs.org/etag/-/etag-1.5.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/etag/-/etag-1.5.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/range-parser
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/vary
    [0m[91mnpm http[0m[91m [0m[91m200 https://registry.npmjs.org/proxy-addr
    [0m[91mnpm http 200 https://registry.npmjs.org/type-is
    [0m[91mnpm info retry fetch attempt 1 at 10:27:41 PM
    [0m[91mnpm info attempt registry request try #1 at 10:27:41 PM
    npm http fetch GET https://registry.npmjs.org/range-parser/-/range-parser-1.0.3.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:27:41 PM
    npm info[0m[91m attempt registry request try #1 at 10:27:41 PM
    npm[0m[91m http fetch GET https://registry.npmjs.org/vary/-/vary-1.0.1.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:27:41 PM
    npm info attempt registry request try #1 at 10:27:41 PM
    npm http fetch GET https://registry.npmjs.org/proxy-addr/-/proxy-addr-1.0.10.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:27:41 PM
    npm info attempt[0m[91m registry request try #1 at 10:27:41 PM
    npm http fetch GET https://registry.npmjs.org/type-is/-/type-is-1.6.11.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/range-parser/-/range-parser-1.0.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/vary/-/vary-1.0.1.tgz
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/type-is/-/type-is-1.6.11.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/proxy-addr/-/proxy-addr-1.0.10.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/merge-descriptors/-/merge-descriptors-0.0.2.tgz
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/parseurl
    [0m[91mnpm http 200 https://registry.npmjs.org/vary
    [0m[91mnpm [0m[91mhttp 200 https://registry.npmjs.org/on-finished
    [0m[91mnpm info retry fetch attempt 1 at 10:27:42 PM
    npm info attempt registry request try #1 at 10:27:42 PM
    npm http fetch GET https://registry.npmjs.org/parseurl/-/parseurl-1.3.1.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:27:42 PM
    npm info[0m[91m attempt registry request try #1 at 10:27:42 PM
    npm http fetch GET https://registry.npmjs.org/vary/-/vary-1.0.1.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:27:42 PM
    npm info attempt registry request try #1 at 10:27:42 PM
    npm http fetch GET https://registry.npmjs.org/on-finished/-/on-finished-2.2.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/methods
    [0m[91mnpm [0m[91minfo[0m[91m retry fetch attempt 1 at 10:27:42 PM
    [0m[91mnpm info attempt registry request try #1 at 10:27:42 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/methods/-/methods-1.1.2.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/etag
    [0m[91mnpm info retry fetch attempt 1 at 10:27:42 PM
    [0m[91mnpm info attempt registry request try #1 at 10:27:42 PM
    npm http [0m[91mfetch GET https://registry.npmjs.org/etag/-/etag-1.5.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/accepts
    [0m[91mnpm info retry fetch attempt 1 at 10:27:43 PM
    npm info attempt registry request try #1 at 10:27:43 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/accepts/-/accepts-1.2.13.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/parseurl/-/parseurl-1.3.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/debug
    [0m[91mnpm info retry fetch attempt 1 at 10:27:43 PM
    npm info attempt registry request try #1 at 10:27:43 PM
    npm http fetch GET https://registry.npmjs.org/debug/-/debug-2.1.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/accepts/-/accepts-1.2.13.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/debug/-/debug-2.1.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/path-to-regexp
    [0m[91mnpm info retry fetch attempt 1 at 10:27:43 PM
    npm info attempt registry request try #1 at 10:27:43 PM
    npm http fetch GET https://registry.npmjs.org/path-to-regexp/-/path-to-regexp-0.1.3.tgz
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/path-to-regexp/-/path-to-regexp-0.1.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/merge-descriptors
    [0m[91mnpm info retry fetch attempt 1 at 10:27:45 PM
    npm info attempt registry request try #1 at 10:27:45 PM
    npm http fetch GET https://registry.npmjs.org/merge-descriptors/-/merge-descriptors-0.0.2.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/range-parser
    [0m[91mnpm info retry fetch attempt 1 at 10:27:45 PM
    npm info attempt registry request try #1 at 10:27:45 PM
    npm http fetch GET https://registry.npmjs.org/range-parser/-/range-parser-1.0.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/methods/-/methods-1.1.2.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/on-finished/-/on-finished-2.2.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/vary/-/vary-1.0.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/escape-html
    [0m[91mnpm info retry fetch attempt 1 at 10:27:46 PM
    npm info attempt registry request try #1 at 10:27:46 PM
    npm http[0m[91m fetch GET https://registry.npmjs.org/escape-html/-/escape-html-1.0.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/escape-html/-/escape-html-1.0.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/cookie
    [0m[91mnpm info retry fetch attempt 1 at 10:27:46 PM
    npm info attempt registry request try #1 at 10:27:46 PM
    npm http fetch GET https://registry.npmjs.org/cookie/-/cookie-0.1.2.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/cookie/-/cookie-0.1.2.tgz
    [0m[91mnpm http 200[0m[91m https://registry.npmjs.org/send
    [0m[91mnpm info retry fetch attempt 1 at 10:27:47 PM
    [0m[91mnpm info[0m[91m attempt registry request try #1 at 10:27:47 PM
    npm http[0m[91m [0m[91mfetch GET https://registry.npmjs.org/send/-/send-0.12.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/send/-/send-0.12.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/range-parser/-/range-parser-1.0.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/merge-descriptors/-/merge-descriptors-0.0.2.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/finalhandler
    [0m[91mnpm info retry fetch attempt 1 at 10:27:48 PM
    npm[0m[91m info attempt registry request try #1 at 10:27:48 PM
    npm http fetch GET https://registry.npmjs.org/finalhandler/-/finalhandler-0.3.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/finalhandler/-/finalhandler-0.3.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/cookie-signature
    [0m[91mnpm info retry fetch attempt 1 at 10:27:49 PM
    npm info attempt registry request try #1 at 10:27:49 PM
    npm http fetch GET https://registry.npmjs.org/cookie-signature/-/cookie-signature-1.0.6.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/cookie-signature/-/cookie-signature-1.0.6.tgz
    [0m[91mnpm [0m[91mhttp 200 https://registry.npmjs.org/serve-static
    [0m[91mnpm info retry fetch attempt 1 at 10:27:49 PM
    npm info attempt registry request try #1 at 10:27:49 PM
    npm http fetch GET https://registry.npmjs.org/serve-static/-/serve-static-1.9.3.tgz
    [0m[91mnpm http fetch[0m[91m 200 https://registry.npmjs.org/serve-static/-/serve-static-1.9.3.tgz
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/content-type
    [0m[91mnpm[0m[91m info retry fetch attempt 1 at 10:27:49 PM
    [0m[91mnpm info attempt registry request try #1 at 10:27:49 PM
    npm http fetch GET https://registry.npmjs.org/content-type/-/content-type-1.0.1.tgz
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/path-to-regexp
    [0m[91mnpm info retry fetch attempt 1 at 10:27:50 PM
    npm info attempt registry request try #1 at 10:27:50 PM
    npm http fetch GET https://registry.npmjs.org/path-to-regexp/-/path-to-regexp-0.1.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/path-to-regexp/-/path-to-regexp-0.1.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/proxy-addr
    [0m[91mnpm info retry fetch attempt 1 at 10:27:51 PM
    npm info attempt registry request try #1 at 10:27:51 PM
    npm http fetch GET https://registry.npmjs.org/proxy-addr/-/proxy-addr-1.0.10.tgz
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/proxy-addr/-/proxy-addr-1.0.10.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/type-is
    [0m[91mnpm info retry fetch attempt 1 at 10:27:51 PM
    npm info attempt registry request try #1 at 10:27:51 PM
    npm http fetch GET https://registry.npmjs.org/type-is/-/type-is-1.6.11.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/type-is/-/type-is-1.6.11.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/content-type/-/content-type-1.0.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/serve-static
    [0m[91mnpm info retry fetch attempt 1 at 10:27:56 PM
    npm info attempt registry request try #1 at 10:27:56 PM
    npm http fetch GET https://registry.npmjs.org/serve-static/-/serve-static-1.9.3.tgz
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/express
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/serve-static/-/serve-static-1.9.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/depd
    [0m[91mnpm info retry fetch attempt 1 at 10:27:56 PM
    npm[0m[91m info attempt registry request try #1 at 10:27:56 PM
    npm http[0m[91m fetch GET https://registry.npmjs.org/depd/-/depd-1.0.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/qs
    [0m[91mnpm[0m[91m [0m[91minfo retry fetch attempt 1 at 10:27:56 PM
    npm info attempt registry request try #1 at 10:27:56 PM
    npm http fetch GET https://registry.npmjs.org/qs/-/qs-2.3.3.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:27:56 PM
    [0m[91mnpm info attempt registry request try #1 at 10:27:56 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/express/-/express-4.12.0.tgz
    [0m[91mnpm[0m[91m http fetch[0m[91m 200 https://registry.npmjs.org/qs/-/qs-2.3.3.tgz
    [0m[91mnpm http[0m[91m fetch 200 https://registry.npmjs.org/express/-/express-4.12.0.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:27:58 PM
    npm http request GET https://registry.npmjs.org/accepts
    [0m[91mnpm info attempt registry request try #1 at 10:27:58 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/content-disposition
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:27:58 PM
    npm http request GET https://registry.npmjs.org/content-type
    [0m[91mnpm info attempt registry request try #1 at 10:27:58 PM
    [0m[91mnpm[0m[91m http request GET https://registry.npmjs.org/cookie-signature
    [0m[91mnpm info attempt registry request try #1 at 10:27:58 PM
    npm[0m[91m http request GET https://registry.npmjs.org/debug
    [0m[91mnpm info [0m[91mattempt[0m[91m registry request try #1 at 10:27:58 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/depd
    [0m[91mnpm info attempt registry request try #1 at 10:27:58 PM
    npm [0m[91mhttp request GET https://registry.npmjs.org/escape-html
    npm[0m[91m info attempt registry request try #1 at 10:27:58 PM
    npm http request GET https://registry.npmjs.org/etag
    [0m[91mnpm info attempt registry request try #1 at 10:27:58 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/finalhandler
    npm [0m[91mnpm http 200 https://registry.npmjs.org/express
    [0m[91minfo[0m[91m attempt registry request try #1 at 10:27:58 PM
    [0m[91mnpm [0m[91mhttp[0m[91m request GET https://registry.npmjs.org/fresh
    npm[0m[91m info attempt registry request try #1 at 10:27:58 PM
    [0m[91mnpm[0m[91m http request GET https://registry.npmjs.org/methods
    npm info attempt registry request try #1 at 10:27:58 PM
    npm[0m[91m http request GET https://registry.npmjs.org/on-finished
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:27:58 PM
    [0m[91mnpm[0m[91m [0m[91mhttp[0m[91m request GET https://registry.npmjs.org/parseurl
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:27:58 PM
    npm http request GET https://registry.npmjs.org/path-to-regexp
    npm[0m[91m info attempt registry request try #1 at 10:27:58 PM
    npm http request GET https://registry.npmjs.org/proxy-addr
    [0m[91mnpm info attempt[0m[91m registry request try #1 at 10:27:58 PM
    npm http request GET https://registry.npmjs.org/qs
    npm info attempt registry request try #1 at 10:27:58 PM
    npm http request GET https://registry.npmjs.org/range-parser
    npm info attempt registry request try #1 at 10:27:58 PM
    npm http request GET https://registry.npmjs.org/send
    npm info attempt registry request try #1 at 10:27:58 PM
    npm http request GET https://registry.npmjs.org/serve-static
    npm info attempt registry request try #1 at 10:27:58 PM
    npm http request GET https://registry.npmjs.org/type-is
    npm info attempt registry request try #1 at 10:27:58 PM
    npm http request GET https://registry.npmjs.org/vary
    npm info attempt registry request try #1 at 10:27:58 PM
    npm http request GET https://registry.npmjs.org/cookie
    npm info attempt registry request try #1 at 10:27:58 PM
    npm http request GET https://registry.npmjs.org/merge-descriptors
    npm info attempt registry request try #1 at 10:27:58 PM
    npm http request GET https://registry.npmjs.org/utils-merge
    [0m[91mnpm info retry fetch attempt 1 at 10:27:58 PM
    [0m[91mnpm info attempt registry request try #1 at 10:27:58 PM
    npm[0m[91m http fetch GET https://registry.npmjs.org/express/-/express-4.12.0.tgz
    [0m[91mnpm[0m[91m [0m[91mhttp 200[0m[91m https://registry.npmjs.org/fresh
    [0m[91mnpm http 200 https://registry.npmjs.org/on-finished
    npm http 200 https://registry.npmjs.org/etag
    [0m[91mnpm info retry fetch attempt 1 at 10:27:59 PM
    [0m[91mnpm info attempt registry request try #1 at 10:27:59 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/fresh/-/fresh-0.2.4.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:27:59 PM
    npm[0m[91m info[0m[91m attempt registry request try #1 at 10:27:59 PM
    npm http fetch[0m[91m GET https://registry.npmjs.org/on-finished/-/on-finished-2.2.1.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:27:59 PM
    npm info attempt registry request try #1 at 10:27:59 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/etag/-/etag-1.5.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/on-finished/-/on-finished-2.2.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/etag/-/etag-1.5.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/fresh/-/fresh-0.2.4.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/depd/-/depd-1.0.1.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:27:59 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/mime-types
    [0m[91mnpm info attempt registry request try #1 at 10:27:59 PM
    [0m[91mnpm[0m[91m http request GET https://registry.npmjs.org/negotiator
    [0m[91mnpm http[0m[91m fetch 200 https://registry.npmjs.org/content-type/-/content-type-1.0.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/mime-types
    [0m[91mnpm info retry fetch attempt 1 at 10:28:00 PM
    npm info attempt registry request try #1 at 10:28:00 PM
    npm http[0m[91m fetch[0m[91m GET https://registry.npmjs.org/mime-types/-/mime-types-2.1.9.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/utils-merge
    [0m[91mnpm [0m[91mhttp[0m[91m 200 https://registry.npmjs.org/cookie-signature
    [0m[91mnpm[0m[91m info retry fetch attempt 1 at 10:28:00 PM
    npm info attempt[0m[91m registry request try #1 at 10:28:00 PM
    npm[0m[91m [0m[91mhttp fetch GET https://registry.npmjs.org/utils-merge/-/utils-merge-1.0.0.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:28:00 PM
    npm [0m[91minfo attempt[0m[91m registry request try #1 at 10:28:00 PM
    [0m[91mnpm http fetch[0m[91m GET https://registry.npmjs.org/cookie-signature/-/cookie-signature-1.0.6.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/methods
    [0m[91mnpm info retry fetch attempt 1 at 10:28:00 PM
    npm[0m[91m info attempt registry request try #1 at 10:28:00 PM
    npm[0m[91m http fetch GET https://registry.npmjs.org/methods/-/methods-1.1.2.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/utils-merge/-/utils-merge-1.0.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/mime-types/-/mime-types-2.1.9.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/methods/-/methods-1.1.2.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/etag/-/etag-1.5.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/negotiator
    [0m[91mnpm info retry fetch attempt 1 at 10:28:01 PM
    npm info attempt registry request try #1 at 10:28:01 PM
    npm [0m[91mhttp[0m[91m fetch GET https://registry.npmjs.org/negotiator/-/negotiator-0.5.3.tgz
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/negotiator/-/negotiator-0.5.3.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:28:01 PM
    npm http request GET https://registry.npmjs.org/mime-db
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/express/-/express-4.12.0.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/mime-db
    [0m[91mnpm[0m[91m info retry fetch attempt 1 at 10:28:02 PM
    npm info attempt registry request try #1 at 10:28:02 PM
    npm http fetch GET https://registry.npmjs.org/mime-db/-/mime-db-1.21.0.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:28:02 PM
    npm http request GET https://registry.npmjs.org/accepts
    [0m[91mnpm info attempt registry request try #1 at 10:28:02 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/content-disposition
    [0m[91mnpm info attempt registry request try #1 at 10:28:02 PM
    npm http request GET https://registry.npmjs.org/content-type
    [0m[91mnpm info[0m[91m attempt registry request try #1 at 10:28:02 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/cookie-signature
    [0m[91mnpm info attempt registry request try #1 at 10:28:02 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/debug
    [0m[91mnpm[0m[91m info [0m[91mattempt[0m[91m registry request try #1 at 10:28:02 PM
    [0m[91mnpm http[0m[91m request[0m[91m GET https://registry.npmjs.org/depd
    [0m[91mnpm info[0m[91m attempt registry request try #1 at 10:28:02 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/escape-html
    [0m[91mnpm [0m[91minfo attempt registry request try #1 at 10:28:02 PM
    npm http request GET https://registry.npmjs.org/etag
    [0m[91mnpm info attempt registry request try #1 at 10:28:02 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/finalhandler
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:28:02 PM
    [0m[91mnpm [0m[91mhttp request GET https://registry.npmjs.org/fresh
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:28:02 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/methods
    [0m[91mnpm [0m[91minfo attempt registry request try #1 at 10:28:02 PM
    npm http [0m[91mrequest GET https://registry.npmjs.org/on-finished
    [0m[91mnpm[0m[91m info [0m[91mattempt registry request try #1 at 10:28:02 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/parseurl
    [0m[91mnpm[0m[91m http[0m[91m fetch 200 https://registry.npmjs.org/mime-db/-/mime-db-1.21.0.tgz
    [0m[91mnpm[0m[91m info[0m[91m [0m[91mattempt registry request try #1 at 10:28:02 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/path-to-regexp
    [0m[91mnpm info attempt registry request try #1 at 10:28:02 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/proxy-addr
    [0m[91mnpm info attempt[0m[91m registry request try #1 at 10:28:02 PM
    [0m[91mnpm[0m[91m http request GET https://registry.npmjs.org/qs
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:28:02 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/range-parser
    [0m[91mnpm info attempt registry request try #1 at 10:28:02 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/send
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:28:02 PM
    [0m[91mnpm[0m[91m http request GET https://registry.npmjs.org/serve-static
    [0m[91mnpm[0m[91m [0m[91minfo attempt registry request try #1 at 10:28:02 PM
    [0m[91mnpm[0m[91m [0m[91mhttp [0m[91mrequest GET https://registry.npmjs.org/type-is
    [0m[91mnpm[0m[91m [0m[91minfo attempt registry request try #1 at 10:28:02 PM
    [0m[91mnpm[0m[91m http [0m[91mrequest GET https://registry.npmjs.org/vary
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:28:02 PM
    [0m[91mnpm[0m[91m http request GET https://registry.npmjs.org/cookie
    [0m[91mnpm info attempt registry request try #1 at 10:28:02 PM
    [0m[91mnpm[0m[91m [0m[91mhttp request GET https://registry.npmjs.org/merge-descriptors
    [0m[91mnpm info [0m[91mattempt[0m[91m registry request try #1 at 10:28:02 PM
    [0m[91mnpm http request[0m[91m GET https://registry.npmjs.org/utils-merge
    [0m[91mnpm[0m[91m [0m[91minfo attempt registry request try #1 at 10:28:02 PM
    [0m[91mnpm[0m[91m [0m[91mhttp [0m[91mrequest[0m[91m GET https://registry.npmjs.org/ms
    [0m[91mnpm http 200 https://registry.npmjs.org/ms
    [0m[91mnpm info retry fetch attempt 1 at 10:28:02 PM
    npm info attempt registry request try #1 at 10:28:02 PM
    [0m[91mnpm[0m[91m http fetch GET https://registry.npmjs.org/ms/-/ms-0.7.0.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/path-to-regexp
    [0m[91mnpm info retry fetch attempt 1 at 10:28:04 PM
    npm [0m[91minfo attempt registry request try #1 at 10:28:04 PM
    npm http fetch GET https://registry.npmjs.org/path-to-regexp/-/path-to-regexp-0.1.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/escape-html
    [0m[91mnpm info retry fetch attempt 1 at 10:28:04 PM
    npm info attempt registry request try #1 at 10:28:04 PM
    npm http fetch GET https://registry.npmjs.org/escape-html/-/escape-html-1.0.1.tgz
    [0m[91mnpm[0m[91m http [0m[91m200 https://registry.npmjs.org/utils-merge
    [0m[91mnpm http 200 https://registry.npmjs.org/cookie-signature
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/vary
    [0m[91mnpm info[0m[91m retry fetch attempt 1 at 10:28:06 PM
    npm info attempt registry request try #1 at 10:28:06 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/utils-merge/-/utils-merge-1.0.0.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:28:06 PM
    npm info attempt registry request try #1 at 10:28:06 PM
    npm http fetch GET https://registry.npmjs.org/cookie-signature/-/cookie-signature-1.0.6.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/cookie
    [0m[91mnpm http fetch[0m[91m 200 https://registry.npmjs.org/ms/-/ms-0.7.0.tgz
    [0m[91mnpm[0m[91m http 200[0m[91m https://registry.npmjs.org/merge-descriptors
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:28:06 PM
    npm http request GET https://registry.npmjs.org/crc
    [0m[91mnpm [0m[91minfo retry fetch attempt 1 at 10:28:06 PM
    npm info attempt registry request try #1 at 10:28:06 PM
    npm http fetch GET https://registry.npmjs.org/vary/-/vary-1.0.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/serve-static
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/cookie-signature/-/cookie-signature-1.0.6.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:28:06 PM
    npm info attempt registry request try #1 at 10:28:06 PM
    npm[0m[91m http fetch GET https://registry.npmjs.org/cookie/-/cookie-0.1.2.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:28:06 PM
    npm info attempt registry request try #1 at 10:28:06 PM
    npm http fetch GET https://registry.npmjs.org/merge-descriptors/-/merge-descriptors-0.0.2.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:28:06 PM
    [0m[91mnpm info attempt registry request try #1 at 10:28:06 PM
    npm http fetch GET https://registry.npmjs.org/serve-static/-/serve-static-1.9.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/merge-descriptors/-/merge-descriptors-0.0.2.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/depd
    [0m[91mnpm info retry fetch attempt 1 at 10:28:06 PM
    npm info attempt registry request try #1 at 10:28:06 PM
    npm http fetch GET https://registry.npmjs.org/depd/-/depd-1.0.1.tgz
    [0m[91mnpm http 200[0m[91m https://registry.npmjs.org/accepts
    [0m[91mnpm info retry fetch attempt 1 at 10:28:06 PM
    npm info attempt registry request try #1 at 10:28:06 PM
    npm [0m[91mhttp fetch GET https://registry.npmjs.org/accepts/-/accepts-1.2.13.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/debug
    [0m[91mnpm info retry fetch attempt 1 at 10:28:06 PM
    npm info attempt registry request try #1 at 10:28:06 PM
    npm[0m[91m http fetch GET https://registry.npmjs.org/debug/-/debug-2.1.3.tgz
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/depd/-/depd-1.0.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/accepts/-/accepts-1.2.13.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/debug/-/debug-2.1.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/fresh
    [0m[91mnpm http 200 https://registry.npmjs.org/type-is
    [0m[91mnpm info retry fetch attempt 1 at 10:28:08 PM
    npm info attempt registry request try #1 at 10:28:08 PM
    npm http[0m[91m fetch GET https://registry.npmjs.org/fresh/-/fresh-0.2.4.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:28:08 PM
    [0m[91mnpm info attempt registry request try #1 at 10:28:08 PM
    npm http fetch GET https://registry.npmjs.org/type-is/-/type-is-1.6.11.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/fresh/-/fresh-0.2.4.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/type-is/-/type-is-1.6.11.tgz
    [0m[91mnpm[0m[91m http [0m[91m200[0m[91m https://registry.npmjs.org/accepts
    [0m[91mnpm http 200 https://registry.npmjs.org/path-to-regexp
    [0m[91mnpm [0m[91mhttp 200 https://registry.npmjs.org/methods
    [0m[91mnpm info retry fetch attempt 1 at 10:28:08 PM
    [0m[91mnpm info attempt registry request try #1 at 10:28:08 PM
    npm http fetch GET https://registry.npmjs.org/accepts/-/accepts-1.2.13.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:28:08 PM
    npm[0m[91m info[0m[91m attempt registry request try #1 at 10:28:08 PM
    npm [0m[91mhttp fetch GET https://registry.npmjs.org/path-to-regexp/-/path-to-regexp-0.1.3.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:28:08 PM
    npm [0m[91minfo attempt registry request try #1 at 10:28:08 PM
    npm http fetch GET https://registry.npmjs.org/methods/-/methods-1.1.2.tgz
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/on-finished
    [0m[91mnpm info retry fetch attempt 1 at 10:28:08 PM
    npm info attempt registry request try #1 at 10:28:08 PM
    npm http fetch GET https://registry.npmjs.org/on-finished/-/on-finished-2.2.1.tgz
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/path-to-regexp/-/path-to-regexp-0.1.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/accepts/-/accepts-1.2.13.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/path-to-regexp/-/path-to-regexp-0.1.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/methods/-/methods-1.1.2.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/finalhandler
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/escape-html/-/escape-html-1.0.1.tgz
    [0m[91mnpm[0m[91m [0m[91mhttp fetch 200 https://registry.npmjs.org/on-finished/-/on-finished-2.2.1.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:28:09 PM
    npm info attempt registry request try #1 at 10:28:09 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/finalhandler/-/finalhandler-0.3.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/finalhandler/-/finalhandler-0.3.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/content-type
    [0m[91mnpm [0m[91minfo retry fetch attempt 1 at 10:28:09 PM
    npm info attempt registry request try #1 at 10:28:09 PM
    npm http fetch GET https://registry.npmjs.org/content-type/-/content-type-1.0.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/cookie/-/cookie-0.1.2.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/vary
    [0m[91mnpm info retry fetch attempt 1 at 10:28:09 PM
    npm info attempt registry request try #1 at 10:28:09 PM
    npm http fetch GET https://registry.npmjs.org/vary/-/vary-1.0.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/crc
    [0m[91mnpm info retry fetch attempt 1 at 10:28:09 PM
    npm info attempt[0m[91m registry request try #1 at 10:28:09 PM
    npm[0m[91m http fetch GET https://registry.npmjs.org/crc/-/crc-3.2.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/vary/-/vary-1.0.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/serve-static/-/serve-static-1.9.3.tgz
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/crc/-/crc-3.2.1.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:28:10 PM
    [0m[91mnpm[0m[91m http request GET https://registry.npmjs.org/ee-first
    [0m[91mnpm http 200 https://registry.npmjs.org/ee-first
    [0m[91mnpm info retry fetch attempt 1 at 10:28:10 PM
    npm info attempt registry request try #1 at 10:28:10 PM
    [0m[91mnpm http[0m[91m fetch GET https://registry.npmjs.org/ee-first/-/ee-first-1.1.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/ee-first/-/ee-first-1.1.0.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:28:10 PM
    npm http request GET https://registry.npmjs.org/forwarded
    npm info attempt registry request try #1 at 10:28:10 PM
    npm http request GET https://registry.npmjs.org/ipaddr.js
    [0m[91mnpm http 200 https://registry.npmjs.org/forwarded
    [0m[91mnpm info retry fetch attempt 1 at 10:28:11 PM
    npm info attempt registry request try #1 at 10:28:11 PM
    npm http fetch GET https://registry.npmjs.org/forwarded/-/forwarded-0.1.0.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/ipaddr.js
    [0m[91mnpm info retry fetch attempt 1 at 10:28:11 PM
    npm info[0m[91m [0m[91mattempt registry request try #1 at 10:28:11 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/ipaddr.js/-/ipaddr.js-1.0.5.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/forwarded/-/forwarded-0.1.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/ipaddr.js/-/ipaddr.js-1.0.5.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:28:11 PM
    npm http[0m[91m request GET https://registry.npmjs.org/destroy
    [0m[91mnpm info attempt registry request try #1 at 10:28:11 PM
    npm http [0m[91mrequest GET https://registry.npmjs.org/mime
    [0m[91mnpm http 200[0m[91m https://registry.npmjs.org/destroy
    [0m[91mnpm info retry fetch attempt 1 at 10:28:11 PM
    npm info attempt registry request try #1 at 10:28:11 PM
    npm http fetch GET https://registry.npmjs.org/destroy/-/destroy-1.0.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/mime
    [0m[91mnpm info retry fetch attempt 1 at 10:28:11 PM
    [0m[91mnpm info attempt registry request try #1 at 10:28:11 PM
    npm http fetch GET https://registry.npmjs.org/mime/-/mime-1.3.4.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/destroy/-/destroy-1.0.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/mime/-/mime-1.3.4.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/utils-merge/-/utils-merge-1.0.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/cookie-signature/-/cookie-signature-1.0.6.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/vary/-/vary-1.0.1.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:28:12 PM
    npm[0m[91m http request GET https://registry.npmjs.org/send
    [0m[91mnpm http 304 https://registry.npmjs.org/send
    [0m[91mnpm info retry fetch attempt 1 at 10:28:12 PM
    npm info attempt registry request try #1 at 10:28:12 PM
    npm http fetch GET https://registry.npmjs.org/send/-/send-0.12.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/content-type/-/content-type-1.0.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/send/-/send-0.12.3.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:28:12 PM
    npm http request GET https://registry.npmjs.org/debug
    [0m[91mnpm info attempt registry request try #1 at 10:28:12 PM
    npm http request GET https://registry.npmjs.org/etag
    npm info attempt registry request try #1 at 10:28:12 PM
    npm http request GET https://registry.npmjs.org/ms
    [0m[91mnpm http 304 https://registry.npmjs.org/ms
    [0m[91mnpm info retry fetch attempt 1 at 10:28:13 PM
    npm info attempt registry request try #1 at 10:28:13 PM
    npm http fetch GET https://registry.npmjs.org/ms/-/ms-0.7.1.tgz
    [0m[91mnpm http 304 https://registry.npmjs.org/debug
    [0m[91mnpm info retry fetch attempt 1 at 10:28:13 PM
    [0m[91mnpm info attempt registry request try #1 at 10:28:13 PM
    npm http fetch GET https://registry.npmjs.org/debug/-/debug-2.2.0.tgz
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/ms/-/ms-0.7.1.tgz
    [0m[91mnpm[0m[91m [0m[91mhttp fetch 200 https://registry.npmjs.org/debug/-/debug-2.2.0.tgz
    [0m[91mnpm http 304 https://registry.npmjs.org/etag
    [0m[91mnpm info retry fetch attempt 1 at 10:28:13 PM
    npm info[0m[91m attempt registry request try #1 at 10:28:13 PM
    npm http fetch GET https://registry.npmjs.org/etag/-/etag-1.6.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/etag/-/etag-1.6.0.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:28:14 PM
    npm http request GET https://registry.npmjs.org/media-typer
    [0m[91mnpm http 200 https://registry.npmjs.org/media-typer
    [0m[91mnpm info retry fetch attempt 1 at 10:28:14 PM
    npm info attempt registry request try #1 at 10:28:14 PM
    npm http[0m[91m fetch GET https://registry.npmjs.org/media-typer/-/media-typer-0.3.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/media-typer/-/media-typer-0.3.0.tgz
    [0m[91mnpm info lifecycle content-disposition@0.5.0~preinstall: content-disposition@0.5.0
    npm info lifecycle content-type@1.0.1~preinstall: content-type@1.0.1
    npm info lifecycle cookie@0.1.2~preinstall: cookie@0.1.2
    [0m[91mnpm info[0m[91m lifecycle cookie-signature@1.0.6~preinstall: cookie-signature@1.0.6
    npm info lifecycle crc@3.2.1~preinstall: crc@3.2.1
    [0m[91mnpm info lifecycle depd@1.0.1~preinstall: depd@1.0.1
    npm info lifecycle destroy@1.0.3~preinstall: destroy@1.0.3
    [0m[91mnpm info lifecycle ee-first@1.1.0~preinstall: ee-first@1.1.0
    npm info lifecycle escape-html@1.0.1~preinstall: escape-html@1.0.1
    npm info lifecycle etag@1.5.1~preinstall: etag@1.5.1
    [0m[91mnpm info lifecycle forwarded@0.1.0~preinstall: forwarded@0.1.0
    npm info lifecycle fresh@0.2.4~preinstall: fresh@0.2.4
    [0m[91mnpm info lifecycle ipaddr.js@1.0.5~preinstall: ipaddr.js@1.0.5
    npm info lifecycle media-typer@0.3.0~preinstall: media-typer@0.3.0
    npm info lifecycle merge-descriptors@0.0.2~preinstall: merge-descriptors@0.0.2
    [0m[91mnpm info lifecycle methods@1.1.2~preinstall: methods@1.1.2
    npm info lifecycle mime@1.3.4~preinstall: mime@1.3.4
    npm info lifecycle mime-db@1.21.0~preinstall: mime-db@1.21.0
    npm info lifecycle mime-types@2.1.9~preinstall: mime-types@2.1.9
    [0m[91mnpm info lifecycle ms@0.7.0~preinstall: ms@0.7.0
    npm info lifecycle debug@2.1.3~preinstall: debug@2.1.3
    npm info lifecycle[0m[91m negotiator@0.5.3~preinstall: negotiator@0.5.3
    [0m[91mnpm info lifecycle accepts@1.2.13~preinstall: accepts@1.2.13
    npm info lifecycle on-finished@2.2.1~preinstall: on-finished@2.2.1
    npm info lifecycle finalhandler@0.3.3~preinstall: finalhandler@0.3.3
    npm info lifecycle parseurl@1.3.1~preinstall: parseurl@1.3.1
    npm info lifecycle path-to-regexp@0.1.3~preinstall: path-to-regexp@0.1.3
    [0m[91mnpm info lifecycle proxy-addr@1.0.10~preinstall: proxy-addr@1.0.10
    npm info lifecycle qs@2.3.3~preinstall: qs@2.3.3
    npm info lifecycle range-parser@1.0.3~preinstall: range-parser@1.0.3
    npm[0m[91m info lifecycle send@0.12.1~preinstall: send@0.12.1
    npm info lifecycle etag@1.6.0~preinstall: etag@1.6.0
    npm info lifecycle ms@0.7.1~preinstall: ms@0.7.1
    npm[0m[91m info lifecycle debug@2.2.0~preinstall: debug@2.2.0
    npm info lifecycle send@0.12.3~preinstall: send@0.12.3
    npm info lifecycle type-is@1.6.11~preinstall: type-is@1.6.11
    [0m[91mnpm info lifecycle utils-merge@1.0.0~preinstall: utils-merge@1.0.0
    npm info lifecycle serve-static@1.9.3~preinstall: serve-static@1.9.3
    [0m[91mnpm info lifecycle vary@1.0.1~preinstall: vary@1.0.1
    npm info lifecycle express@4.12.0~preinstall: express@4.12.0
    [0m[91mnpm[0m[91m info linkStuff content-disposition@0.5.0
    [0m[91mnpm info linkStuff content-type@1.0.1
    [0m[91mnpm info linkStuff cookie@0.1.2
    npm info linkStuff cookie-signature@1.0.6
    [0m[91mnpm info linkStuff crc@3.2.1
    [0m[91mnpm info linkStuff depd@1.0.1
    npm[0m[91m info linkStuff destroy@1.0.3
    [0m[91mnpm[0m[91m info linkStuff ee-first@1.1.0
    [0m[91mnpm info linkStuff escape-html@1.0.1
    [0m[91mnpm info linkStuff etag@1.5.1
    [0m[91mnpm info linkStuff forwarded@0.1.0
    [0m[91mnpm info linkStuff fresh@0.2.4
    [0m[91mnpm info linkStuff ipaddr.js@1.0.5
    [0m[91mnpm info linkStuff media-typer@0.3.0
    [0m[91mnpm info linkStuff merge-descriptors@0.0.2
    [0m[91mnpm info linkStuff methods@1.1.2
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/send
    [0m[91mnpm info linkStuff mime@1.3.4
    [0m[91mnpm info linkStuff mime-db@1.21.0
    [0m[91mnpm[0m[91m info linkStuff mime-types@2.1.9
    [0m[91mnpm[0m[91m info linkStuff ms@0.7.0
    [0m[91mnpm[0m[91mnpm info retry fetch attempt 1 at 10:28:16 PM
    [0m[91mnpm info attempt registry request try #1 at 10:28:16 PM
    [0m[91m info linkStuff debug@2.1.3
    [0m[91mnpm http fetch GET https://registry.npmjs.org/send/-/send-0.12.1.tgz
    [0m[91mnpm info linkStuff negotiator@0.5.3
    [0m[91mnpm info linkStuff accepts@1.2.13
    [0m[91mnpm info[0m[91m [0m[91mlinkStuff on-finished@2.2.1
    [0m[91mnpm info linkStuff finalhandler@0.3.3
    npm info[0m[91m linkStuff parseurl@1.3.1
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/finalhandler
    [0m[91mnpm[0m[91m info linkStuff path-to-regexp@0.1.3
    [0m[91mnpm[0m[91m info linkStuff proxy-addr@1.0.10
    [0m[91mnpm info linkStuff qs@2.3.3
    [0m[91mnpm[0m[91m info linkStuff range-parser@1.0.3
    [0m[91mnpm[0m[91m info linkStuff send@0.12.1
    [0m[91mnpm info linkStuff etag@1.6.0
    [0m[91mnpm[0m[91mnpm[0m[91m info linkStuff ms@0.7.1
    [0m[91m [0m[91minfo retry fetch attempt 1 at 10:28:16 PM
    [0m[91mnpm [0m[91mnpm[0m[91minfo attempt registry request try #1 at 10:28:16 PM
    npm http fetch GET https://registry.npmjs.org/finalhandler/-/finalhandler-0.3.3.tgz
    [0m[91m info linkStuff debug@2.2.0
    [0m[91mnpm[0m[91mnpm[0m[91m info linkStuff send@0.12.3
    [0m[91m http 200 https://registry.npmjs.org/type-is
    [0m[91mnpm info linkStuff type-is@1.6.11
    [0m[91mnpm[0m[91m info linkStuff utils-merge@1.0.0
    [0m[91mnpm[0m[91m info linkStuff serve-static@1.9.3
    [0m[91mnpm[0m[91m info linkStuff vary@1.0.1
    [0m[91mnpm[0m[91m info linkStuff express@4.12.0
    [0m[91mnpm[0m[91m [0m[91minfo retry fetch attempt 1 at 10:28:16 PM
    npm[0m[91m info[0m[91mnpm[0m[91m [0m[91minfo lifecycle content-disposition@0.5.0~install: content-disposition@0.5.0
    [0m[91m attempt registry request try #1 at 10:28:16 PM
    npm http [0m[91mfetch GET https://registry.npmjs.org/type-is/-/type-is-1.6.11.tgz
    [0m[91mnpm[0m[91m info lifecycle content-type@1.0.1~install: content-type@1.0.1
    [0m[91mnpm[0m[91m info lifecycle cookie@0.1.2~install: cookie@0.1.2
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/send/-/send-0.12.1.tgz
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/depd
    [0m[91mnpm[0m[91mnpm[0m[91m [0m[91minfo[0m[91m lifecycle cookie-signature@1.0.6~install: cookie-signature@1.0.6
    [0m[91m [0m[91mhttp[0m[91m 200 https://registry.npmjs.org/methods
    [0m[91mnpm info lifecycle crc@3.2.1~install: crc@3.2.1
    [0m[91mnpm info lifecycle depd@1.0.1~install: depd@1.0.1
    [0m[91mnpm info lifecycle destroy@1.0.3~install: destroy@1.0.3
    [0m[91mnpm[0m[91mnpm[0m[91m info lifecycle ee-first@1.1.0~install: ee-first@1.1.0
    [0m[91m http 200 https://registry.npmjs.org/escape-html
    [0m[91mnpm info lifecycle escape-html@1.0.1~install: escape-html@1.0.1
    [0m[91mnpm[0m[91m http[0m[91m 200 https://registry.npmjs.org/content-disposition
    [0m[91mnpm[0m[91m info lifecycle etag@1.5.1~install: etag@1.5.1
    [0m[91mnpm info lifecycle forwarded@0.1.0~install: forwarded@0.1.0
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/range-parser
    [0m[91mnpm[0m[91m info lifecycle fresh@0.2.4~install: fresh@0.2.4
    [0m[91mnpm[0m[91m info lifecycle ipaddr.js@1.0.5~install: ipaddr.js@1.0.5
    [0m[91mnpm[0m[91m info lifecycle media-typer@0.3.0~install: media-typer@0.3.0
    [0m[91mnpm info lifecycle merge-descriptors@0.0.2~install: merge-descriptors@0.0.2
    [0m[91mnpm info lifecycle methods@1.1.2~install: methods@1.1.2
    [0m[91mnpm info lifecycle mime@1.3.4~install: mime@1.3.4
    [0m[91mnpm[0m[91m [0m[91minfo lifecycle mime-db@1.21.0~install: mime-db@1.21.0
    [0m[91mnpm[0m[91m [0m[91minfo[0m[91m lifecycle mime-types@2.1.9~install: mime-types@2.1.9
    [0m[91mnpm[0m[91m info lifecycle ms@0.7.0~install: ms@0.7.0
    [0m[91mnpm info lifecycle debug@2.1.3~install: debug@2.1.3
    [0m[91mnpm info lifecycle negotiator@0.5.3~install: negotiator@0.5.3
    [0m[91mnpm info lifecycle accepts@1.2.13~install: accepts@1.2.13
    [0m[91mnpm[0m[91m [0m[91minfo lifecycle on-finished@2.2.1~install: on-finished@2.2.1
    [0m[91mnpm info lifecycle finalhandler@0.3.3~install: finalhandler@0.3.3
    [0m[91mnpm[0m[91m info lifecycle parseurl@1.3.1~install: parseurl@1.3.1
    [0m[91mnpm[0m[91m [0m[91minfo lifecycle path-to-regexp@0.1.3~install: path-to-regexp@0.1.3
    [0m[91mnpm info lifecycle proxy-addr@1.0.10~install: proxy-addr@1.0.10
    [0m[91mnpm info lifecycle qs@2.3.3~install: qs@2.3.3
    [0m[91mnpm info lifecycle range-parser@1.0.3~install: range-parser@1.0.3
    [0m[91mnpm info lifecycle send@0.12.1~install: send@0.12.1
    [0m[91mnpm[0m[91m info lifecycle etag@1.6.0~install: etag@1.6.0
    [0m[91mnpm info lifecycle ms@0.7.1~install: ms@0.7.1
    [0m[91mnpm info lifecycle debug@2.2.0~install: debug@2.2.0
    [0m[91mnpm info lifecycle send@0.12.3~install: send@0.12.3
    [0m[91mnpm info lifecycle type-is@1.6.11~install: type-is@1.6.11
    [0m[91mnpm info lifecycle utils-merge@1.0.0~install: utils-merge@1.0.0
    [0m[91mnpm info lifecycle serve-static@1.9.3~install: serve-static@1.9.3
    [0m[91mnpm[0m[91m info lifecycle vary@1.0.1~install: vary@1.0.1
    [0m[91mnpm [0m[91minfo lifecycle express@4.12.0~install: express@4.12.0
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/content-type
    [0m[91mnpm info retry fetch attempt 1 at 10:28:16 PM
    npm info attempt registry request try #1 at 10:28:16 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/depd/-/depd-1.0.1.tgz
    [0m[91mnpm[0m[91m info retry fetch attempt 1 at 10:28:16 PM
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:28:16 PM
    npm[0m[91m [0m[91mhttp fetch GET https://registry.npmjs.org/methods/-/methods-1.1.2.tgz
    npm info retry fetch attempt 1 at 10:28:16 PM
    npm[0m[91m info attempt registry request try #1 at 10:28:16 PM
    npm http fetch GET https://registry.npmjs.org/escape-html/-/escape-html-1.0.1.tgz
    npm[0m[91m info retry fetch attempt 1 at 10:28:16 PM
    npm info attempt registry request try #1 at 10:28:16 PM
    npm http fetch GET https://registry.npmjs.org/content-disposition/-/content-disposition-0.5.0.tgz
    npm info retry fetch attempt 1 at 10:28:16 PM
    npm info attempt registry request try #1 at 10:28:16 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/range-parser/-/range-parser-1.0.3.tgz
    [0m[91mnpm[0m[91m info[0m[91m lifecycle content-disposition@0.5.0~postinstall: content-disposition@0.5.0
    [0m[91mnpm[0m[91m info lifecycle content-type@1.0.1~postinstall: content-type@1.0.1
    [0m[91mnpm[0m[91m info lifecycle cookie@0.1.2~postinstall: cookie@0.1.2
    [0m[91mnpm info lifecycle[0m[91m cookie-signature@1.0.6~postinstall: cookie-signature@1.0.6
    [0m[91mnpm[0m[91m info lifecycle crc@3.2.1~postinstall: crc@3.2.1
    [0m[91mnpm[0m[91m info lifecycle depd@1.0.1~postinstall: depd@1.0.1
    [0m[91mnpm info lifecycle destroy@1.0.3~postinstall: destroy@1.0.3
    [0m[91mnpm info lifecycle ee-first@1.1.0~postinstall: ee-first@1.1.0
    [0m[91mnpm info lifecycle escape-html@1.0.1~postinstall: escape-html@1.0.1
    [0m[91mnpm[0m[91m info lifecycle etag@1.5.1~postinstall: etag@1.5.1
    [0m[91mnpm info lifecycle forwarded@0.1.0~postinstall: forwarded@0.1.0
    [0m[91mnpm info lifecycle fresh@0.2.4~postinstall: fresh@0.2.4
    [0m[91mnpm info lifecycle ipaddr.js@1.0.5~postinstall: ipaddr.js@1.0.5
    [0m[91mnpm info lifecycle media-typer@0.3.0~postinstall: media-typer@0.3.0
    [0m[91mnpm info lifecycle merge-descriptors@0.0.2~postinstall: merge-descriptors@0.0.2
    [0m[91mnpm info[0m[91mnpm[0m[91m [0m[91m http 200 https://registry.npmjs.org/proxy-addr
    [0m[91mlifecycle methods@1.1.2~postinstall: methods@1.1.2
    [0m[91mnpm[0m[91mnpm info[0m[91m [0m[91m lifecycle mime@1.3.4~postinstall: mime@1.3.4
    [0m[91mhttp fetch 200 https://registry.npmjs.org/type-is/-/type-is-1.6.11.tgz
    [0m[91mnpm info lifecycle mime-db@1.21.0~postinstall: mime-db@1.21.0
    [0m[91mnpm[0m[91mnpm info lifecycle mime-types@2.1.9~postinstall: mime-types@2.1.9
    [0m[91m info retry fetch attempt 1 at 10:28:16 PM
    npm info attempt[0m[91m registry request try #1 at 10:28:16 PM
    npm http fetch GET https://registry.npmjs.org/content-type/-/content-type-1.0.1.tgz
    [0m[91mnpm[0m[91m info lifecycle ms@0.7.0~postinstall: ms@0.7.0
    [0m[91mnpm[0m[91m info lifecycle debug@2.1.3~postinstall: debug@2.1.3
    [0m[91mnpm[0m[91m info lifecycle negotiator@0.5.3~postinstall: negotiator@0.5.3
    [0m[91mnpm[0m[91m info lifecycle accepts@1.2.13~postinstall: accepts@1.2.13
    [0m[91mnpm[0m[91m info lifecycle on-finished@2.2.1~postinstall: on-finished@2.2.1
    [0m[91mnpm info lifecycle finalhandler@0.3.3~postinstall: finalhandler@0.3.3
    [0m[91mnpm[0m[91m info lifecycle parseurl@1.3.1~postinstall: parseurl@1.3.1
    [0m[91mnpm[0m[91m info lifecycle path-to-regexp@0.1.3~postinstall: path-to-regexp@0.1.3
    [0m[91mnpm[0m[91m info lifecycle proxy-addr@1.0.10~postinstall: proxy-addr@1.0.10
    [0m[91mnpm[0m[91mnpm[0m[91m info retry fetch attempt 1 at 10:28:16 PM
    npm info attempt registry request try #1 at 10:28:17 PM
    [0m[91m [0m[91mnpm http fetch GET https://registry.npmjs.org/proxy-addr/-/proxy-addr-1.0.10.tgz
    [0m[91minfo lifecycle qs@2.3.3~postinstall: qs@2.3.3
    [0m[91mnpm[0m[91m info lifecycle range-parser@1.0.3~postinstall: range-parser@1.0.3
    [0m[91mnpm[0m[91m info lifecycle send@0.12.1~postinstall: send@0.12.1
    [0m[91mnpm info lifecycle etag@1.6.0~postinstall: etag@1.6.0
    [0m[91mnpm info [0m[91mlifecycle ms@0.7.1~postinstall: ms@0.7.1
    [0m[91mnpm[0m[91m info lifecycle debug@2.2.0~postinstall: debug@2.2.0
    [0m[91mnpm info lifecycle send@0.12.3~postinstall: send@0.12.3
    [0m[91mnpm[0m[91m info lifecycle type-is@1.6.11~postinstall: type-is@1.6.11
    [0m[91mnpm info lifecycle utils-merge@1.0.0~postinstall: utils-merge@1.0.0
    [0m[91mnpm info lifecycle serve-static@1.9.3~postinstall: serve-static@1.9.3
    [0m[91mnpm info lifecycle vary@1.0.1~postinstall: vary@1.0.1
    [0m[91mnpm info lifecycle express@4.12.0~postinstall: express@4.12.0
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/depd/-/depd-1.0.1.tgz
    [0m[91mnpm[0m[91m info lifecycle node-hello-world@0.0.1~preinstall: node-hello-world@0.0.1
    [0m[91mnpm[0m[91m info linkStuff node-hello-world@0.0.1
    [0m[91mnpm[0m[91m info lifecycle node-hello-world@0.0.1~install: node-hello-world@0.0.1
    [0m[91mnpm[0m[91m info lifecycle node-hello-world@0.0.1~postinstall: node-hello-world@0.0.1
    [0m[91mnpm info lifecycle node-hello-world@0.0.1~prepublish: node-hello-world@0.0.1
    [0mnode-hello-world@0.0.1 /src
    `-- express@4.12.0 
      +-- accepts@1.2.13 
      | +-- mime-types@2.1.9 
      | | `-- mime-db@1.21.0 
      | `-- negotiator@0.5.3 
      +-- content-disposition@0.5.0 
      +-- content-type@1.0.1 
      +-- cookie@0.1.2 
      +-- cookie-signature@1.0.6 
      +-- debug@2.1.3 
      | `-- ms@0.7.0 
      +-- depd@1.0.1 
      +-- escape-html@1.0.1 
      +-- etag@1.5.1 
      | `-- crc@3.2.1 
      +-- finalhandler@0.3.3 
      +-- fresh@0.2.4 
      +-- merge-descriptors@0.0.2 
      +-- methods@1.1.2 
      +-- on-finished@2.2.1 
      | `-- ee-first@1.1.0 
      +-- parseurl@1.3.1 
      +-- path-to-regexp@0.1.3 
      +-- proxy-addr@1.0.10 
      | +-- forwarded@0.1.0 
      | `-- ipaddr.js@1.0.5 
      +-- qs@2.3.3 
      +-- range-parser@1.0.3 
      +-- send@0.12.1 
      | +-- destroy@1.0.3 
      | `-- mime@1.3.4 
      +-- serve-static@1.9.3 
      | `-- send@0.12.3 
      |   +-- debug@2.2.0 
      |   +-- etag@1.6.0 
      |   `-- ms@0.7.1 
      +-- type-is@1.6.11 
      | `-- media-typer@0.3.0 
      +-- utils-merge@1.0.0 
      `-- vary@1.0.1 
    
    [91mnpm info ok 
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/escape-html/-/escape-html-1.0.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/methods/-/methods-1.1.2.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/content-type/-/content-type-1.0.1.tgz
    npm http fetch 200 https://registry.npmjs.org/content-disposition/-/content-disposition-0.5.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/finalhandler/-/finalhandler-0.3.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/range-parser/-/range-parser-1.0.3.tgz
    npm http fetch 200 https://registry.npmjs.org/proxy-addr/-/proxy-addr-1.0.10.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/send
    npm info retry fetch attempt 1 at 10:28:18 PM
    npm info attempt registry request try #1 at 10:28:18 PM
    npm http fetch GET https://registry.npmjs.org/send/-/send-0.12.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/send/-/send-0.12.1.tgz
    [0m ---> c78f914c93cb
    Removing intermediate container fba4ae11b2e7
    Step 5 : EXPOSE 80
     ---> Running in 1c96d9c997a1
     ---> 57f274bf16e3
    Removing intermediate container 1c96d9c997a1
    Step 6 : CMD node index.js
     ---> Running in 89f4a1c90e06
     ---> 9d79079da6a8
    Removing intermediate container 89f4a1c90e06
    Successfully built 9d79079da6a8
    [5B[91mnpm http 200 https://registry.npmjs.org/debug
    [0m[91mnpm info retry fetch attempt 1 at 10:28:21 PM
    npm info attempt registry request try #1 at 10:28:21 PM
    npm http fetch GET https://registry.npmjs.org/debug/-/debug-2.1.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/debug/-/debug-2.1.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/content-disposition
    [0m[91mnpm http 200 https://registry.npmjs.org/depd
    [0m[91mnpm info retry fetch attempt 1 at 10:28:26 PM
    [0m[91mnpm info attempt registry request try #1 at 10:28:26 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/content-disposition/-/content-disposition-0.5.0.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:28:26 PM
    npm info attempt registry request try #1 at 10:28:26 PM
    [0m[91mnpm [0m[91mhttp fetch GET https://registry.npmjs.org/depd/-/depd-1.0.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/content-disposition/-/content-disposition-0.5.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/depd/-/depd-1.0.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/send
    [0m[91mnpm info retry fetch attempt 1 at 10:28:27 PM
    npm info attempt registry request try #1 at 10:28:27 PM
    npm http[0m[91m fetch GET https://registry.npmjs.org/send/-/send-0.12.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/send/-/send-0.12.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/type-is
    [0m[91mnpm info retry fetch attempt 1 at 10:28:29 PM
    npm info attempt registry request try #1 at 10:28:29 PM
    npm http fetch GET https://registry.npmjs.org/type-is/-/type-is-1.6.11.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/debug
    [0m[91mnpm info retry fetch attempt 1 at 10:28:29 PM
    npm info attempt registry request try #1 at 10:28:29 PM
    npm http fetch GET https://registry.npmjs.org/debug/-/debug-2.1.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/accepts
    [0m[91mnpm info retry fetch attempt 1 at 10:28:29 PM
    npm info attempt registry request try #1 at 10:28:29 PM
    npm http fetch GET https://registry.npmjs.org/accepts/-/accepts-1.2.13.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/type-is/-/type-is-1.6.11.tgz
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/range-parser
    [0m[91mnpm http 200 https://registry.npmjs.org/parseurl
    [0m[91mnpm http [0m[91m200 https://registry.npmjs.org/utils-merge
    [0m[91mnpm info retry fetch attempt 1 at 10:28:30 PM
    npm info attempt registry request try #1 at 10:28:30 PM
    npm[0m[91m http fetch GET https://registry.npmjs.org/range-parser/-/range-parser-1.0.3.tgz
    npm[0m[91m info retry fetch attempt 1 at 10:28:30 PM
    npm info attempt registry request try #1 at 10:28:30 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/parseurl/-/parseurl-1.3.1.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:28:30 PM
    npm[0m[91m info attempt registry request try #1 at 10:28:30 PM
    npm http fetch GET https://registry.npmjs.org/utils-merge/-/utils-merge-1.0.0.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/on-finished
    [0m[91mnpm info retry fetch attempt 1 at 10:28:30 PM
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:28:30 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/on-finished/-/on-finished-2.2.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/etag
    [0m[91mnpm info retry fetch attempt 1 at 10:28:30 PM
    npm[0m[91m info attempt registry request try #1 at 10:28:30 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/etag/-/etag-1.5.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/debug/-/debug-2.1.3.tgz
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/on-finished/-/on-finished-2.2.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/etag/-/etag-1.5.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/accepts/-/accepts-1.2.13.tgz
    [0m[91mnpm [0m[91mhttp 200 https://registry.npmjs.org/depd
    [0m[91mnpm info retry fetch attempt 1 at 10:28:30 PM
    [0m[91mnpm info attempt registry request try #1 at 10:28:30 PM
    npm http [0m[91mfetch GET https://registry.npmjs.org/depd/-/depd-1.0.1.tgz
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/depd/-/depd-1.0.1.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/utils-merge
    [0m[91mnpm info retry fetch attempt 1 at 10:28:31 PM
    npm info attempt registry request try #1 at 10:28:31 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/utils-merge/-/utils-merge-1.0.0.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/debug
    [0m[91mnpm info retry fetch attempt 1 at 10:28:31 PM
    npm info attempt registry request try #1 at 10:28:31 PM
    npm http fetch GET https://registry.npmjs.org/debug/-/debug-2.1.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/debug/-/debug-2.1.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/content-disposition
    [0m[91mnpm info retry fetch attempt 1 at 10:28:33 PM
    npm [0m[91minfo attempt registry request try #1 at 10:28:33 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/content-disposition/-/content-disposition-0.5.0.tgz
    [0m[91mnpm http[0m[91m fetch[0m[91m 200 https://registry.npmjs.org/utils-merge/-/utils-merge-1.0.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/parseurl/-/parseurl-1.3.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/range-parser/-/range-parser-1.0.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/content-disposition/-/content-disposition-0.5.0.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/accepts
    [0m[91mnpm info retry fetch attempt 1 at 10:28:33 PM
    npm info attempt registry request try #1 at 10:28:33 PM
    npm http fetch GET https://registry.npmjs.org/accepts/-/accepts-1.2.13.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/accepts/-/accepts-1.2.13.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:28:33 PM
    npm http request GET https://registry.npmjs.org/mime-types
    npm info attempt registry request try #1 at 10:28:33 PM
    npm http request GET https://registry.npmjs.org/negotiator
    [0m[91mnpm http 200 https://registry.npmjs.org/negotiator
    [0m[91mnpm info retry fetch attempt 1 at 10:28:34 PM
    npm info attempt registry request try #1 at 10:28:34 PM
    npm http fetch GET https://registry.npmjs.org/negotiator/-/negotiator-0.5.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/mime-types
    [0m[91mnpm info retry fetch attempt 1 at 10:28:34 PM
    npm info attempt registry request try #1 at 10:28:34 PM
    npm http fetch GET https://registry.npmjs.org/mime-types/-/mime-types-2.1.9.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/negotiator/-/negotiator-0.5.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/mime-types/-/mime-types-2.1.9.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:28:34 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/mime-db
    [0m[91mnpm http 200 https://registry.npmjs.org/mime-db
    [0m[91mnpm info retry fetch attempt 1 at 10:28:34 PM
    npm info attempt registry request try #1 at 10:28:34 PM
    npm http fetch GET https://registry.npmjs.org/mime-db/-/mime-db-1.21.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/mime-db/-/mime-db-1.21.0.tgz
    [0m[91mnpm[0m[91m [0m[91mhttp fetch 200 https://registry.npmjs.org/utils-merge/-/utils-merge-1.0.0.tgz
    [0m[91mnpm[0m[91m info [0m[91mattempt registry request try #1 at 10:28:34 PM
    npm http request GET https://registry.npmjs.org/ms
    [0m[91mnpm http 200 https://registry.npmjs.org/ms
    [0m[91mnpm info retry fetch attempt 1 at 10:28:35 PM
    npm [0m[91minfo attempt registry request try #1 at 10:28:35 PM
    npm http fetch GET https://registry.npmjs.org/ms/-/ms-0.7.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/ms/-/ms-0.7.0.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:28:35 PM
    npm[0m[91m http request GET https://registry.npmjs.org/crc
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/crc
    [0m[91mnpm info retry fetch attempt 1 at 10:28:35 PM
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:28:35 PM
    [0m[91mnpm [0m[91mhttp fetch GET https://registry.npmjs.org/crc/-/crc-3.2.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/crc/-/crc-3.2.1.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:28:35 PM
    npm http request GET https://registry.npmjs.org/ee-first
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/ee-first
    [0m[91mnpm info retry fetch attempt 1 at 10:28:36 PM
    npm info attempt[0m[91m registry request try #1 at 10:28:36 PM
    [0m[91mnpm http[0m[91m fetch GET https://registry.npmjs.org/ee-first/-/ee-first-1.1.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/ee-first/-/ee-first-1.1.0.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:28:36 PM
    [0m[91mnpm http request GET https://registry.npmjs.org/forwarded
    [0m[91mnpm info attempt registry request try #1 at 10:28:36 PM
    npm http[0m[91m request GET https://registry.npmjs.org/ipaddr.js
    [0m[91mnpm http 200 https://registry.npmjs.org/forwarded
    [0m[91mnpm info retry fetch attempt 1 at 10:28:36 PM
    npm info attempt registry request try #1 at 10:28:36 PM
    npm http fetch GET https://registry.npmjs.org/forwarded/-/forwarded-0.1.0.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/ipaddr.js
    [0m[91mnpm info retry fetch attempt 1 at 10:28:36 PM
    npm info attempt registry request try #1 at 10:28:36 PM
    npm http fetch GET https://registry.npmjs.org/ipaddr.js/-/ipaddr.js-1.0.5.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/forwarded/-/forwarded-0.1.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/ipaddr.js/-/ipaddr.js-1.0.5.tgz
    [0m[91mnpm info[0m[91m attempt registry request try #1 at 10:28:36 PM
    npm http request GET https://registry.npmjs.org/destroy
    [0m[91mnpm info attempt registry request try #1 at 10:28:36 PM
    [0m[91mnpm http[0m[91m request GET https://registry.npmjs.org/mime
    [0m[91mnpm http 200 https://registry.npmjs.org/destroy
    [0m[91mnpm http 200 https://registry.npmjs.org/mime
    [0m[91mnpm info retry fetch attempt 1 at 10:28:37 PM
    npm info attempt registry request try #1 at 10:28:37 PM
    npm http fetch GET https://registry.npmjs.org/destroy/-/destroy-1.0.3.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:28:37 PM
    npm info attempt registry request try #1 at 10:28:37 PM
    npm http fetch[0m[91m GET https://registry.npmjs.org/mime/-/mime-1.3.4.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/qs
    [0m[91mnpm info retry fetch attempt 1 at 10:28:37 PM
    npm info attempt registry request try #1 at 10:28:37 PM
    npm http fetch GET https://registry.npmjs.org/qs/-/qs-2.3.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/destroy/-/destroy-1.0.3.tgz
    npm http fetch 200 https://registry.npmjs.org/mime/-/mime-1.3.4.tgz
    [0m[91mnpm info[0m[91m attempt registry request try #1 at 10:28:37 PM
    npm[0m[91m http request GET https://registry.npmjs.org/send
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/qs/-/qs-2.3.3.tgz
    [0m[91mnpm http 304 https://registry.npmjs.org/send
    [0m[91mnpm info retry fetch attempt 1 at 10:28:37 PM
    npm info attempt registry request try #1 at 10:28:37 PM
    npm http fetch GET https://registry.npmjs.org/send/-/send-0.12.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/send/-/send-0.12.3.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:28:37 PM
    npm http request GET https://registry.npmjs.org/debug
    [0m[91mnpm info attempt registry request try #1 at 10:28:37 PM
    npm http request GET https://registry.npmjs.org/etag
    [0m[91mnpm info retry fetch attempt 1 at 10:28:37 PM
    npm info attempt registry request try #1 at 10:28:37 PM
    npm http fetch GET https://registry.npmjs.org/ms/-/ms-0.7.1.tgz
    [0m[91mnpm http 304 https://registry.npmjs.org/debug
    [0m[91mnpm info retry fetch attempt 1 at 10:28:38 PM
    npm info attempt registry request try #1 at 10:28:38 PM
    npm http fetch GET https://registry.npmjs.org/debug/-/debug-2.2.0.tgz
    [0m[91mnpm http[0m[91m fetch 200 https://registry.npmjs.org/ms/-/ms-0.7.1.tgz
    [0m[91mnpm http 304 https://registry.npmjs.org/etag
    [0m[91mnpm info [0m[91mretry fetch attempt 1 at 10:28:38 PM
    [0m[91mnpm info attempt registry request try #1 at 10:28:38 PM
    npm[0m[91m http fetch GET https://registry.npmjs.org/etag/-/etag-1.6.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/debug/-/debug-2.2.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/etag/-/etag-1.6.0.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:28:38 PM
    npm http request GET https://registry.npmjs.org/media-typer
    [0m[91mnpm http 200 https://registry.npmjs.org/media-typer
    [0m[91mnpm info retry fetch attempt 1 at 10:28:38 PM
    npm info attempt registry request try #1 at 10:28:38 PM
    npm http fetch GET https://registry.npmjs.org/media-typer/-/media-typer-0.3.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/media-typer/-/media-typer-0.3.0.tgz
    [0m[91mnpm info lifecycle content-disposition@0.5.0~preinstall: content-disposition@0.5.0
    npm info lifecycle content-type@1.0.1~preinstall: content-type@1.0.1
    npm info lifecycle cookie@0.1.2~preinstall: cookie@0.1.2
    [0m[91mnpm info lifecycle cookie-signature@1.0.6~preinstall: cookie-signature@1.0.6
    npm info lifecycle crc@3.2.1~preinstall: crc@3.2.1
    npm [0m[91minfo lifecycle depd@1.0.1~preinstall: depd@1.0.1
    npm info lifecycle destroy@1.0.3~preinstall: destroy@1.0.3
    npm info lifecycle ee-first@1.1.0~preinstall: ee-first@1.1.0
    npm[0m[91m info lifecycle escape-html@1.0.1~preinstall: escape-html@1.0.1
    [0m[91mnpm[0m[91m info lifecycle etag@1.5.1~preinstall: etag@1.5.1
    npm info [0m[91mlifecycle forwarded@0.1.0~preinstall: forwarded@0.1.0
    npm info lifecycle fresh@0.2.4~preinstall: fresh@0.2.4
    [0m[91mnpm info lifecycle ipaddr.js@1.0.5~preinstall: ipaddr.js@1.0.5
    [0m[91mnpm info lifecycle media-typer@0.3.0~preinstall: media-typer@0.3.0
    npm info lifecycle merge-descriptors@0.0.2~preinstall: merge-descriptors@0.0.2
    [0m[91mnpm info lifecycle methods@1.1.2~preinstall: methods@1.1.2
    npm info lifecycle mime@1.3.4~preinstall: mime@1.3.4
    [0m[91mnpm info lifecycle mime-db@1.21.0~preinstall: mime-db@1.21.0
    npm info lifecycle mime-types@2.1.9~preinstall: mime-types@2.1.9
    npm info lifecycle ms@0.7.0~preinstall: ms@0.7.0
    npm info lifecycle debug@2.1.3~preinstall: debug@2.1.3
    [0m[91mnpm info lifecycle negotiator@0.5.3~preinstall: negotiator@0.5.3
    npm info lifecycle accepts@1.2.13~preinstall: accepts@1.2.13
    npm info lifecycle on-finished@2.2.1~preinstall: on-finished@2.2.1
    npm info lifecycle finalhandler@0.3.3~preinstall: finalhandler@0.3.3
    npm info lifecycle parseurl@1.3.1~preinstall: parseurl@1.3.1
    npm info lifecycle path-to-regexp@0.1.3~preinstall: path-to-regexp@0.1.3
    npm info lifecycle proxy-addr@1.0.10~preinstall: proxy-addr@1.0.10
    npm info lifecycle qs@2.3.3~preinstall: qs@2.3.3
    npm info lifecycle range-parser@1.0.3~preinstall: range-parser@1.0.3
    npm info lifecycle send@0.12.1~preinstall: send@0.12.1
    npm info lifecycle etag@1.6.0~preinstall: etag@1.6.0
    npm info lifecycle ms@0.7.1~preinstall: ms@0.7.1
    npm info lifecycle debug@2.2.0~preinstall: debug@2.2.0
    npm info lifecycle send@0.12.3~preinstall: send@0.12.3
    npm info lifecycle type-is@1.6.11~preinstall: type-is@1.6.11
    npm info lifecycle utils-merge@1.0.0~preinstall: utils-merge@1.0.0
    npm info lifecycle serve-static@1.9.3~preinstall: serve-static@1.9.3
    npm info lifecycle vary@1.0.1~preinstall: vary@1.0.1
    npm info lifecycle express@4.12.0~preinstall: express@4.12.0
    [0m[91mnpm info linkStuff content-disposition@0.5.0
    [0m[91mnpm info linkStuff content-type@1.0.1
    [0m[91mnpm info linkStuff cookie@0.1.2
    [0m[91mnpm info linkStuff cookie-signature@1.0.6
    [0m[91mnpm info linkStuff crc@3.2.1
    [0m[91mnpm info linkStuff depd@1.0.1
    [0m[91mnpm info[0m[91m linkStuff destroy@1.0.3
    [0m[91mnpm info linkStuff ee-first@1.1.0
    [0m[91mnpm info linkStuff escape-html@1.0.1
    [0m[91mnpm info linkStuff etag@1.5.1
    [0m[91mnpm info linkStuff forwarded@0.1.0
    [0m[91mnpm info linkStuff fresh@0.2.4
    [0m[91mnpm info linkStuff ipaddr.js@1.0.5
    [0m[91mnpm[0m[91m info linkStuff media-typer@0.3.0
    [0m[91mnpm[0m[91m info linkStuff merge-descriptors@0.0.2
    [0m[91mnpm info linkStuff methods@1.1.2
    [0m[91mnpm[0m[91m info linkStuff mime@1.3.4
    [0m[91mnpm info linkStuff mime-db@1.21.0
    [0m[91mnpm info linkStuff mime-types@2.1.9
    [0m[91mnpm info linkStuff ms@0.7.0
    [0m[91mnpm info linkStuff debug@2.1.3
    [0m[91mnpm info linkStuff negotiator@0.5.3
    [0m[91mnpm info linkStuff accepts@1.2.13
    [0m[91mnpm info linkStuff on-finished@2.2.1
    [0m[91mnpm info linkStuff finalhandler@0.3.3
    [0m[91mnpm info[0m[91m linkStuff parseurl@1.3.1
    [0m[91mnpm info linkStuff path-to-regexp@0.1.3
    [0m[91mnpm info linkStuff proxy-addr@1.0.10
    [0m[91mnpm info linkStuff qs@2.3.3
    [0m[91mnpm info linkStuff range-parser@1.0.3
    [0m[91mnpm info linkStuff send@0.12.1
    [0m[91mnpm info[0m[91m linkStuff etag@1.6.0
    [0m[91mnpm info linkStuff ms@0.7.1
    [0m[91mnpm info linkStuff debug@2.2.0
    [0m[91mnpm info linkStuff[0m[91m send@0.12.3
    [0m[91mnpm info linkStuff type-is@1.6.11
    [0m[91mnpm info linkStuff utils-merge@1.0.0
    [0m[91mnpm info linkStuff serve-static@1.9.3
    [0m[91mnpm info linkStuff vary@1.0.1
    [0m[91mnpm info linkStuff express@4.12.0
    [0m[91mnpm info lifecycle content-disposition@0.5.0~install: content-disposition@0.5.0
    [0m[91mnpm info lifecycle content-type@1.0.1~install: content-type@1.0.1
    [0m[91mnpm info lifecycle[0m[91m cookie@0.1.2~install: cookie@0.1.2
    [0m[91mnpm info lifecycle cookie-signature@1.0.6~install: cookie-signature@1.0.6
    [0m[91mnpm info lifecycle crc@3.2.1~install: crc@3.2.1
    [0m[91mnpm info lifecycle depd@1.0.1~install: depd@1.0.1
    [0m[91mnpm info lifecycle destroy@1.0.3~install: destroy@1.0.3
    [0m[91mnpm info lifecycle ee-first@1.1.0~install: ee-first@1.1.0
    [0m[91mnpm info lifecycle escape-html@1.0.1~install: escape-html@1.0.1
    [0m[91mnpm info lifecycle etag@1.5.1~install: etag@1.5.1
    [0m[91mnpm info lifecycle forwarded@0.1.0~install: forwarded@0.1.0
    [0m[91mnpm info lifecycle fresh@0.2.4~install: fresh@0.2.4
    [0m[91mnpm info lifecycle ipaddr.js@1.0.5~install: ipaddr.js@1.0.5
    [0m[91mnpm info lifecycle media-typer@0.3.0~install: media-typer@0.3.0
    [0m[91mnpm info lifecycle merge-descriptors@0.0.2~install: merge-descriptors@0.0.2
    [0m[91mnpm info lifecycle methods@1.1.2~install: methods@1.1.2
    [0m[91mnpm info lifecycle mime@1.3.4~install: mime@1.3.4
    [0m[91mnpm info lifecycle mime-db@1.21.0~install: mime-db@1.21.0
    [0m[91mnpm[0m[91m info lifecycle mime-types@2.1.9~install: mime-types@2.1.9
    [0m[91mnpm info lifecycle ms@0.7.0~install: ms@0.7.0
    [0m[91mnpm info lifecycle debug@2.1.3~install: debug@2.1.3
    [0m[91mnpm info lifecycle negotiator@0.5.3~install: negotiator@0.5.3
    [0m[91mnpm info lifecycle accepts@1.2.13~install: accepts@1.2.13
    [0m[91mnpm info lifecycle on-finished@2.2.1~install: on-finished@2.2.1
    [0m[91mnpm info lifecycle finalhandler@0.3.3~install: finalhandler@0.3.3
    [0m[91mnpm info lifecycle parseurl@1.3.1~install: parseurl@1.3.1
    [0m[91mnpm info lifecycle path-to-regexp@0.1.3~install: path-to-regexp@0.1.3
    [0m[91mnpm info lifecycle proxy-addr@1.0.10~install: proxy-addr@1.0.10
    [0m[91mnpm info lifecycle qs@2.3.3~install: qs@2.3.3
    [0m[91mnpm info lifecycle range-parser@1.0.3~install: range-parser@1.0.3
    [0m[91mnpm[0m[91m info lifecycle send@0.12.1~install: send@0.12.1
    [0m[91mnpm info lifecycle etag@1.6.0~install: etag@1.6.0
    [0m[91mnpm info lifecycle ms@0.7.1~install: ms@0.7.1
    [0m[91mnpm info lifecycle debug@2.2.0~install: debug@2.2.0
    [0m[91mnpm info lifecycle send@0.12.3~install: send@0.12.3
    [0m[91mnpm info lifecycle type-is@1.6.11~install: type-is@1.6.11
    [0m[91mnpm info lifecycle utils-merge@1.0.0~install: utils-merge@1.0.0
    [0m[91mnpm info lifecycle serve-static@1.9.3~install: serve-static@1.9.3
    [0m[91mnpm info lifecycle vary@1.0.1~install: vary@1.0.1
    [0m[91mnpm info lifecycle express@4.12.0~install: express@4.12.0
    [0m[91mnpm [0m[91minfo lifecycle content-disposition@0.5.0~postinstall: content-disposition@0.5.0
    [0m[91mnpm info lifecycle content-type@1.0.1~postinstall: content-type@1.0.1
    [0m[91mnpm info lifecycle cookie@0.1.2~postinstall: cookie@0.1.2
    [0m[91mnpm info [0m[91mlifecycle cookie-signature@1.0.6~postinstall: cookie-signature@1.0.6
    [0m[91mnpm[0m[91m [0m[91minfo lifecycle crc@3.2.1~postinstall: crc@3.2.1
    [0m[91mnpm info lifecycle depd@1.0.1~postinstall: depd@1.0.1
    [0m[91mnpm info lifecycle destroy@1.0.3~postinstall: destroy@1.0.3
    [0m[91mnpm info lifecycle ee-first@1.1.0~postinstall: ee-first@1.1.0
    [0m[91mnpm info lifecycle escape-html@1.0.1~postinstall: escape-html@1.0.1
    [0m[91mnpm info lifecycle etag@1.5.1~postinstall: etag@1.5.1
    [0m[91mnpm info lifecycle forwarded@0.1.0~postinstall: forwarded@0.1.0
    [0m[91mnpm info lifecycle fresh@0.2.4~postinstall: fresh@0.2.4
    [0m[91mnpm info lifecycle ipaddr.js@1.0.5~postinstall: ipaddr.js@1.0.5
    [0m[91mnpm info lifecycle media-typer@0.3.0~postinstall: media-typer@0.3.0
    [0m[91mnpm info lifecycle merge-descriptors@0.0.2~postinstall: merge-descriptors@0.0.2
    [0m[91mnpm info lifecycle methods@1.1.2~postinstall: methods@1.1.2
    [0m[91mnpm info lifecycle mime@1.3.4~postinstall: mime@1.3.4
    [0m[91mnpm info lifecycle mime-db@1.21.0~postinstall: mime-db@1.21.0
    [0m[91mnpm info lifecycle mime-types@2.1.9~postinstall: mime-types@2.1.9
    [0m[91mnpm info lifecycle ms@0.7.0~postinstall: ms@0.7.0
    [0m[91mnpm info lifecycle debug@2.1.3~postinstall: debug@2.1.3
    [0m[91mnpm info lifecycle negotiator@0.5.3~postinstall: negotiator@0.5.3
    npm info lifecycle accepts@1.2.13~postinstall: accepts@1.2.13
    [0m[91mnpm info lifecycle on-finished@2.2.1~postinstall: on-finished@2.2.1
    npm info lifecycle finalhandler@0.3.3~postinstall: finalhandler@0.3.3
    [0m[91mnpm info lifecycle parseurl@1.3.1~postinstall: parseurl@1.3.1
    [0m[91mnpm info lifecycle path-to-regexp@0.1.3~postinstall: path-to-regexp@0.1.3
    [0m[91mnpm info lifecycle proxy-addr@1.0.10~postinstall: proxy-addr@1.0.10
    [0m[91mnpm [0m[91minfo lifecycle qs@2.3.3~postinstall: qs@2.3.3
    [0m[91mnpm info lifecycle range-parser@1.0.3~postinstall: range-parser@1.0.3
    [0m[91mnpm info lifecycle send@0.12.1~postinstall: send@0.12.1
    [0m[91mnpm info lifecycle etag@1.6.0~postinstall: etag@1.6.0
    [0m[91mnpm info lifecycle ms@0.7.1~postinstall: ms@0.7.1
    [0m[91mnpm[0m[91m info lifecycle debug@2.2.0~postinstall: debug@2.2.0
    [0m[91mnpm info lifecycle send@0.12.3~postinstall: send@0.12.3
    [0m[91mnpm info lifecycle type-is@1.6.11~postinstall: type-is@1.6.11
    [0m[91mnpm info lifecycle utils-merge@1.0.0~postinstall: utils-merge@1.0.0
    [0m[91mnpm info lifecycle serve-static@1.9.3~postinstall: serve-static@1.9.3
    [0m[91mnpm info lifecycle vary@1.0.1~postinstall: vary@1.0.1
    [0m[91mnpm info lifecycle express@4.12.0~postinstall: express@4.12.0
    [0m[91mnpm info lifecycle node-hello-world@0.0.1~preinstall: node-hello-world@0.0.1
    [0m[91mnpm info linkStuff node-hello-world@0.0.1
    [0m[91mnpm info lifecycle node-hello-world@0.0.1~install: node-hello-world@0.0.1
    [0m[91mnpm info lifecycle node-hello-world@0.0.1~postinstall: node-hello-world@0.0.1
    [0m[91mnpm info lifecycle node-hello-world@0.0.1~prepublish: node-hello-world@0.0.1
    [0mnode-hello-world@0.0.1 /src
    `-- express@4.12.0 
      +-- accepts@1.2.13 
      | +-- mime-types@2.1.9 
      | | `-- mime-db@1.21.0 
      | `-- negotiator@0.5.3 
      +-- content-disposition@0.5.0 
      +-- content-type@1.0.1 
      +-- cookie@0.1.2 
      +-- cookie-signature@1.0.6 
      +-- debug@2.1.3 
      | `-- ms@0.7.0 
      +-- depd@1.0.1 
      +-- escape-html@1.0.1 
      +-- etag@1.5.1 
      | `-- crc@3.2.1 
      +-- finalhandler@0.3.3 
      +-- fresh@0.2.4 
      +-- merge-descriptors@0.0.2 
      +-- methods@1.1.2 
      +-- on-finished@2.2.1 
      | `-- ee-first@1.1.0 
      +-- parseurl@1.3.1 
      +-- path-to-regexp@0.1.3 
      +-- proxy-addr@1.0.10 
      | +-- forwarded@0.1.0 
      | `-- ipaddr.js@1.0.5 
      +-- qs@2.3.3 
      +-- range-parser@1.0.3 
      +-- send@0.12.1 
      | +-- destroy@1.0.3 
      | `-- mime@1.3.4 
      +-- serve-static@1.9.3 
      | `-- send@0.12.3 
      |   +-- debug@2.2.0 
      |   +-- etag@1.6.0 
      |   `-- ms@0.7.1 
      +-- type-is@1.6.11 
      | `-- media-typer@0.3.0 
      +-- utils-merge@1.0.0 
      `-- vary@1.0.1 
    
    [91mnpm info ok 
    [0m ---> a2ad5704fb6d
    Removing intermediate container a13d7268fb35
    Step 5 : EXPOSE 80
     ---> Running in 72671d6a2d63
     ---> 3f137ae019d6
    Removing intermediate container 72671d6a2d63
    Step 6 : CMD node index.js
     ---> Running in 239cb2d32cfe
     ---> e48a0a2d44cc
    Removing intermediate container 239cb2d32cfe
    Successfully built e48a0a2d44cc
    [4B[91mnpm [0m[91mhttp 200 https://registry.npmjs.org/fresh
    [0m[91mnpm info retry fetch attempt 1 at 10:28:57 PM
    [0m[91mnpm info attempt registry request try #1 at 10:28:57 PM
    [0m[91mnpm [0m[91mhttp fetch[0m[91m GET https://registry.npmjs.org/fresh/-/fresh-0.2.4.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/qs
    [0m[91mnpm http 200 https://registry.npmjs.org/parseurl
    [0m[91mnpm info retry fetch attempt 1 at 10:28:57 PM
    npm info attempt registry request try #1 at 10:28:57 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/qs/-/qs-2.3.3.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:28:57 PM
    npm info attempt registry request try #1 at 10:28:57 PM
    npm http fetch GET https://registry.npmjs.org/parseurl/-/parseurl-1.3.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/fresh/-/fresh-0.2.4.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/parseurl/-/parseurl-1.3.1.tgz
    npm http fetch 200 https://registry.npmjs.org/qs/-/qs-2.3.3.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:28:57 PM
    npm http request GET https://registry.npmjs.org/mime-types
    [0m[91mnpm info attempt registry request try #1 at 10:28:57 PM
    npm http request GET https://registry.npmjs.org/negotiator
    [0m[91mnpm http [0m[91m200 https://registry.npmjs.org/negotiator
    [0m[91mnpm info retry fetch attempt 1 at 10:28:57 PM
    npm info attempt registry request try #1 at 10:28:57 PM
    npm http fetch GET https://registry.npmjs.org/negotiator/-/negotiator-0.5.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/mime-types
    [0m[91mnpm[0m[91m info retry fetch attempt 1 at 10:28:57 PM
    npm info attempt registry request try #1 at 10:28:57 PM
    npm[0m[91m http fetch GET https://registry.npmjs.org/mime-types/-/mime-types-2.1.9.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/negotiator/-/negotiator-0.5.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/mime-types/-/mime-types-2.1.9.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:28:58 PM
    npm http request GET https://registry.npmjs.org/mime-db
    [0m[91mnpm http 200 https://registry.npmjs.org/mime-db
    [0m[91mnpm info retry fetch attempt 1 at 10:28:58 PM
    npm info attempt registry request try #1 at 10:28:58 PM
    npm http fetch GET https://registry.npmjs.org/mime-db/-/mime-db-1.21.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/mime-db/-/mime-db-1.21.0.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:28:58 PM
    npm http request GET https://registry.npmjs.org/ms
    [0m[91mnpm http 200 https://registry.npmjs.org/ms
    [0m[91mnpm info retry fetch attempt 1 at 10:28:58 PM
    npm info attempt registry request try #1 at 10:28:58 PM
    npm http fetch GET https://registry.npmjs.org/ms/-/ms-0.7.0.tgz
    [0m[91mnpm http fetch[0m[91m 200 https://registry.npmjs.org/ms/-/ms-0.7.0.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:28:59 PM
    npm http request GET https://registry.npmjs.org/crc
    [0m[91mnpm http 200 https://registry.npmjs.org/crc
    [0m[91mnpm info retry fetch attempt 1 at 10:28:59 PM
    npm info attempt registry request try #1 at 10:28:59 PM
    npm[0m[91m http fetch GET https://registry.npmjs.org/crc/-/crc-3.2.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/crc/-/crc-3.2.1.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:28:59 PM
    npm http request GET https://registry.npmjs.org/ee-first
    [0m[91mnpm http 200 https://registry.npmjs.org/ee-first
    [0m[91mnpm info retry fetch attempt 1 at 10:28:59 PM
    npm info attempt registry request try #1 at 10:28:59 PM
    npm http fetch[0m[91m GET https://registry.npmjs.org/ee-first/-/ee-first-1.1.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/ee-first/-/ee-first-1.1.0.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:29:00 PM
    npm http request GET https://registry.npmjs.org/forwarded
    [0m[91mnpm info attempt registry request try #1 at 10:29:00 PM
    npm http request GET https://registry.npmjs.org/ipaddr.js
    [0m[91mnpm http 200 https://registry.npmjs.org/forwarded
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/ipaddr.js
    [0m[91mnpm info retry fetch attempt 1 at 10:29:00 PM
    npm info attempt registry request try #1 at 10:29:00 PM
    npm http fetch GET https://registry.npmjs.org/forwarded/-/forwarded-0.1.0.tgz
    npm[0m[91m info retry fetch attempt 1 at 10:29:00 PM
    npm info attempt registry request try #1 at 10:29:00 PM
    npm[0m[91m http [0m[91mfetch GET https://registry.npmjs.org/ipaddr.js/-/ipaddr.js-1.0.5.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/ipaddr.js/-/ipaddr.js-1.0.5.tgz
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/forwarded/-/forwarded-0.1.0.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:29:01 PM
    npm http request GET https://registry.npmjs.org/destroy
    [0m[91mnpm[0m[91m info attempt registry request try #1 at 10:29:01 PM
    npm http[0m[91m request GET https://registry.npmjs.org/mime
    [0m[91mnpm http 200 https://registry.npmjs.org/destroy
    [0m[91mnpm info retry fetch attempt 1 at 10:29:01 PM
    npm info attempt registry request try #1 at 10:29:01 PM
    npm http fetch GET https://registry.npmjs.org/destroy/-/destroy-1.0.3.tgz
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/mime
    [0m[91mnpm[0m[91m info retry fetch attempt 1 at 10:29:01 PM
    [0m[91mnpm info attempt registry request try #1 at 10:29:01 PM
    npm http fetch GET https://registry.npmjs.org/mime/-/mime-1.3.4.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/destroy/-/destroy-1.0.3.tgz
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/mime/-/mime-1.3.4.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:29:01 PM
    npm http request GET https://registry.npmjs.org/send
    [0m[91mnpm http 304 https://registry.npmjs.org/send
    [0m[91mnpm info retry fetch attempt 1 at 10:29:01 PM
    npm info attempt registry request try #1 at 10:29:01 PM
    npm http fetch GET https://registry.npmjs.org/send/-/send-0.12.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/send/-/send-0.12.3.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:29:02 PM
    npm http request GET https://registry.npmjs.org/debug
    [0m[91mnpm info attempt registry request try #1 at 10:29:02 PM
    npm[0m[91m http request GET https://registry.npmjs.org/etag
    [0m[91mnpm info retry fetch attempt 1 at 10:29:02 PM
    npm info attempt registry request try #1 at 10:29:02 PM
    [0m[91mnpm[0m[91m http fetch GET https://registry.npmjs.org/ms/-/ms-0.7.1.tgz
    [0m[91mnpm http 304 https://registry.npmjs.org/debug
    [0m[91mnpm http 304 https://registry.npmjs.org/etag
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/ms/-/ms-0.7.1.tgz
    [0m[91mnpm info[0m[91m retry fetch attempt 1 at 10:29:02 PM
    npm info attempt registry request try #1 at 10:29:02 PM
    npm http fetch[0m[91m GET https://registry.npmjs.org/debug/-/debug-2.2.0.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:29:02 PM
    npm info attempt registry request try #1 at 10:29:02 PM
    npm http fetch GET https://registry.npmjs.org/etag/-/etag-1.6.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/debug/-/debug-2.2.0.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/etag/-/etag-1.6.0.tgz
    [0m[91mnpm info attempt registry request try #1 at 10:29:02 PM
    npm http request GET https://registry.npmjs.org/media-typer
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/media-typer
    [0m[91mnpm info retry fetch attempt 1 at 10:29:03 PM
    npm info[0m[91m attempt registry request try #1 at 10:29:03 PM
    npm http [0m[91mfetch GET https://registry.npmjs.org/media-typer/-/media-typer-0.3.0.tgz
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/media-typer/-/media-typer-0.3.0.tgz
    [0m[91mnpm info lifecycle content-disposition@0.5.0~preinstall: content-disposition@0.5.0
    npm info lifecycle content-type@1.0.1~preinstall: content-type@1.0.1
    [0m[91mnpm info lifecycle cookie@0.1.2~preinstall: cookie@0.1.2
    npm info lifecycle cookie-signature@1.0.6~preinstall: cookie-signature@1.0.6
    npm[0m[91m info lifecycle crc@3.2.1~preinstall: crc@3.2.1
    npm info lifecycle depd@1.0.1~preinstall: depd@1.0.1
    [0m[91mnpm info lifecycle destroy@1.0.3~preinstall: destroy@1.0.3
    npm info lifecycle ee-first@1.1.0~preinstall: ee-first@1.1.0
    npm info lifecycle escape-html@1.0.1~preinstall: escape-html@1.0.1
    [0m[91mnpm info lifecycle etag@1.5.1~preinstall: etag@1.5.1
    npm info lifecycle forwarded@0.1.0~preinstall: forwarded@0.1.0
    npm info lifecycle fresh@0.2.4~preinstall: fresh@0.2.4
    [0m[91mnpm info lifecycle ipaddr.js@1.0.5~preinstall: ipaddr.js@1.0.5
    [0m[91mnpm info lifecycle media-typer@0.3.0~preinstall: media-typer@0.3.0
    npm[0m[91m info lifecycle merge-descriptors@0.0.2~preinstall: merge-descriptors@0.0.2
    npm info[0m[91m lifecycle methods@1.1.2~preinstall: methods@1.1.2
    npm info [0m[91mlifecycle mime@1.3.4~preinstall: mime@1.3.4
    npm info lifecycle mime-db@1.21.0~preinstall: mime-db@1.21.0
    [0m[91mnpm info lifecycle mime-types@2.1.9~preinstall: mime-types@2.1.9
    [0m[91mnpm info lifecycle ms@0.7.0~preinstall: ms@0.7.0
    [0m[91mnpm info lifecycle debug@2.1.3~preinstall: debug@2.1.3
    npm info[0m[91m lifecycle[0m[91m negotiator@0.5.3~preinstall: negotiator@0.5.3
    [0m[91mnpm info lifecycle accepts@1.2.13~preinstall: accepts@1.2.13
    npm info lifecycle[0m[91m on-finished@2.2.1~preinstall: on-finished@2.2.1
    npm info lifecycle finalhandler@0.3.3~preinstall: finalhandler@0.3.3
    [0m[91mnpm info lifecycle parseurl@1.3.1~preinstall: parseurl@1.3.1
    npm[0m[91m info lifecycle path-to-regexp@0.1.3~preinstall: path-to-regexp@0.1.3
    npm info lifecycle[0m[91m proxy-addr@1.0.10~preinstall: proxy-addr@1.0.10
    npm info lifecycle qs@2.3.3~preinstall: qs@2.3.3
    [0m[91mnpm info lifecycle range-parser@1.0.3~preinstall: range-parser@1.0.3
    npm [0m[91minfo lifecycle send@0.12.1~preinstall: send@0.12.1
    npm info lifecycle etag@1.6.0~preinstall: etag@1.6.0
    [0m[91mnpm info lifecycle ms@0.7.1~preinstall: ms@0.7.1
    [0m[91mnpm [0m[91minfo lifecycle debug@2.2.0~preinstall: debug@2.2.0
    [0m[91mnpm info lifecycle send@0.12.3~preinstall: send@0.12.3
    npm info [0m[91mlifecycle type-is@1.6.11~preinstall: type-is@1.6.11
    npm info lifecycle utils-merge@1.0.0~preinstall: utils-merge@1.0.0
    [0m[91mnpm info lifecycle serve-static@1.9.3~preinstall: serve-static@1.9.3
    [0m[91mnpm info lifecycle vary@1.0.1~preinstall: vary@1.0.1
    npm info lifecycle express@4.12.0~preinstall: express@4.12.0
    [0m[91mnpm info linkStuff content-disposition@0.5.0
    [0m[91mnpm info linkStuff content-type@1.0.1
    [0m[91mnpm info linkStuff cookie@0.1.2
    [0m[91mnpm info linkStuff cookie-signature@1.0.6
    [0m[91mnpm info linkStuff crc@3.2.1
    [0m[91mnpm info linkStuff depd@1.0.1
    [0m[91mnpm info linkStuff destroy@1.0.3
    [0m[91mnpm info linkStuff ee-first@1.1.0
    [0m[91mnpm info linkStuff escape-html@1.0.1
    [0m[91mnpm info linkStuff etag@1.5.1
    [0m[91mnpm info linkStuff forwarded@0.1.0
    [0m[91mnpm info linkStuff fresh@0.2.4
    [0m[91mnpm info linkStuff ipaddr.js@1.0.5
    [0m[91mnpm info linkStuff media-typer@0.3.0
    [0m[91mnpm info linkStuff merge-descriptors@0.0.2
    [0m[91mnpm info linkStuff methods@1.1.2
    [0m[91mnpm [0m[91minfo linkStuff mime@1.3.4
    [0m[91mnpm info linkStuff mime-db@1.21.0
    [0m[91mnpm info linkStuff mime-types@2.1.9
    [0m[91mnpm info linkStuff ms@0.7.0
    [0m[91mnpm info linkStuff debug@2.1.3
    [0m[91mnpm[0m[91m info linkStuff negotiator@0.5.3
    [0m[91mnpm info linkStuff accepts@1.2.13
    [0m[91mnpm info linkStuff on-finished@2.2.1
    [0m[91mnpm info linkStuff finalhandler@0.3.3
    npm info[0m[91m linkStuff parseurl@1.3.1
    [0m[91mnpm info linkStuff path-to-regexp@0.1.3
    [0m[91mnpm info linkStuff proxy-addr@1.0.10
    [0m[91mnpm info linkStuff qs@2.3.3
    npm info[0m[91m linkStuff range-parser@1.0.3
    [0m[91mnpm info linkStuff send@0.12.1
    [0m[91mnpm info linkStuff etag@1.6.0
    [0m[91mnpm info linkStuff ms@0.7.1
    [0m[91mnpm info linkStuff debug@2.2.0
    [0m[91mnpm info linkStuff send@0.12.3
    [0m[91mnpm[0m[91m info linkStuff type-is@1.6.11
    [0m[91mnpm info linkStuff utils-merge@1.0.0
    [0m[91mnpm info linkStuff serve-static@1.9.3
    [0m[91mnpm[0m[91m info linkStuff vary@1.0.1
    [0m[91mnpm info linkStuff express@4.12.0
    [0m[91mnpm info lifecycle content-disposition@0.5.0~install: content-disposition@0.5.0
    [0m[91mnpm info lifecycle content-type@1.0.1~install: content-type@1.0.1
    [0m[91mnpm info lifecycle cookie@0.1.2~install: cookie@0.1.2
    [0m[91mnpm info lifecycle cookie-signature@1.0.6~install: cookie-signature@1.0.6
    [0m[91mnpm info lifecycle crc@3.2.1~install: crc@3.2.1
    [0m[91mnpm info lifecycle depd@1.0.1~install: depd@1.0.1
    npm[0m[91m info lifecycle destroy@1.0.3~install: destroy@1.0.3
    [0m[91mnpm info lifecycle ee-first@1.1.0~install: ee-first@1.1.0
    [0m[91mnpm info lifecycle escape-html@1.0.1~install: escape-html@1.0.1
    [0m[91mnpm info lifecycle etag@1.5.1~install: etag@1.5.1
    [0m[91mnpm info lifecycle forwarded@0.1.0~install: forwarded@0.1.0
    [0m[91mnpm info lifecycle fresh@0.2.4~install: fresh@0.2.4
    [0m[91mnpm info lifecycle ipaddr.js@1.0.5~install: ipaddr.js@1.0.5
    npm info lifecycle media-typer@0.3.0~install: media-typer@0.3.0
    [0m[91mnpm info lifecycle merge-descriptors@0.0.2~install: merge-descriptors@0.0.2
    [0m[91mnpm info lifecycle methods@1.1.2~install: methods@1.1.2
    [0m[91mnpm info lifecycle mime@1.3.4~install: mime@1.3.4
    [0m[91mnpm info lifecycle mime-db@1.21.0~install: mime-db@1.21.0
    [0m[91mnpm info lifecycle mime-types@2.1.9~install: mime-types@2.1.9
    [0m[91mnpm info lifecycle ms@0.7.0~install: ms@0.7.0
    [0m[91mnpm info lifecycle debug@2.1.3~install: debug@2.1.3
    [0m[91mnpm info lifecycle negotiator@0.5.3~install: negotiator@0.5.3
    [0m[91mnpm info lifecycle accepts@1.2.13~install: accepts@1.2.13
    [0m[91mnpm info lifecycle on-finished@2.2.1~install: on-finished@2.2.1
    [0m[91mnpm info [0m[91mlifecycle finalhandler@0.3.3~install: finalhandler@0.3.3
    [0m[91mnpm info lifecycle parseurl@1.3.1~install: parseurl@1.3.1
    [0m[91mnpm info lifecycle path-to-regexp@0.1.3~install: path-to-regexp@0.1.3
    [0m[91mnpm info lifecycle proxy-addr@1.0.10~install: proxy-addr@1.0.10
    [0m[91mnpm info lifecycle qs@2.3.3~install: qs@2.3.3
    npm info lifecycle[0m[91m range-parser@1.0.3~install: range-parser@1.0.3
    [0m[91mnpm info lifecycle send@0.12.1~install: send@0.12.1
    [0m[91mnpm info lifecycle etag@1.6.0~install: etag@1.6.0
    [0m[91mnpm[0m[91m info lifecycle ms@0.7.1~install: ms@0.7.1
    [0m[91mnpm info lifecycle debug@2.2.0~install: debug@2.2.0
    [0m[91mnpm info lifecycle send@0.12.3~install: send@0.12.3
    [0m[91mnpm info lifecycle type-is@1.6.11~install: type-is@1.6.11
    [0m[91mnpm info lifecycle utils-merge@1.0.0~install: utils-merge@1.0.0
    [0m[91mnpm info lifecycle serve-static@1.9.3~install: serve-static@1.9.3
    [0m[91mnpm info lifecycle vary@1.0.1~install: vary@1.0.1
    [0m[91mnpm info lifecycle express@4.12.0~install: express@4.12.0
    [0m[91mnpm info lifecycle content-disposition@0.5.0~postinstall: content-disposition@0.5.0
    [0m[91mnpm info lifecycle content-type@1.0.1~postinstall: content-type@1.0.1
    [0m[91mnpm info lifecycle cookie@0.1.2~postinstall: cookie@0.1.2
    [0m[91mnpm info lifecycle cookie-signature@1.0.6~postinstall: cookie-signature@1.0.6
    [0m[91mnpm info lifecycle crc@3.2.1~postinstall: crc@3.2.1
    [0m[91mnpm info lifecycle depd@1.0.1~postinstall: depd@1.0.1
    [0m[91mnpm info lifecycle destroy@1.0.3~postinstall: destroy@1.0.3
    [0m[91mnpm info lifecycle ee-first@1.1.0~postinstall: ee-first@1.1.0
    npm info lifecycle escape-html@1.0.1~postinstall: escape-html@1.0.1
    [0m[91mnpm info lifecycle etag@1.5.1~postinstall: etag@1.5.1
    [0m[91mnpm info lifecycle forwarded@0.1.0~postinstall: forwarded@0.1.0
    [0m[91mnpm info lifecycle fresh@0.2.4~postinstall: fresh@0.2.4
    [0m[91mnpm info lifecycle ipaddr.js@1.0.5~postinstall: ipaddr.js@1.0.5
    [0m[91mnpm info lifecycle media-typer@0.3.0~postinstall: media-typer@0.3.0
    npm info [0m[91mlifecycle merge-descriptors@0.0.2~postinstall: merge-descriptors@0.0.2
    [0m[91mnpm info lifecycle methods@1.1.2~postinstall: methods@1.1.2
    [0m[91mnpm info[0m[91m lifecycle mime@1.3.4~postinstall: mime@1.3.4
    [0m[91mnpm info lifecycle mime-db@1.21.0~postinstall: mime-db@1.21.0
    [0m[91mnpm info lifecycle mime-types@2.1.9~postinstall: mime-types@2.1.9
    [0m[91mnpm info lifecycle ms@0.7.0~postinstall: ms@0.7.0
    [0m[91mnpm info lifecycle debug@2.1.3~postinstall: debug@2.1.3
    [0m[91mnpm info lifecycle negotiator@0.5.3~postinstall: negotiator@0.5.3
    [0m[91mnpm info lifecycle accepts@1.2.13~postinstall: accepts@1.2.13
    [0m[91mnpm info lifecycle on-finished@2.2.1~postinstall: on-finished@2.2.1
    [0m[91mnpm info lifecycle finalhandler@0.3.3~postinstall: finalhandler@0.3.3
    [0m[91mnpm info lifecycle parseurl@1.3.1~postinstall: parseurl@1.3.1
    [0m[91mnpm info lifecycle path-to-regexp@0.1.3~postinstall: path-to-regexp@0.1.3
    [0m[91mnpm info lifecycle proxy-addr@1.0.10~postinstall: proxy-addr@1.0.10
    [0m[91mnpm info lifecycle qs@2.3.3~postinstall: qs@2.3.3
    [0m[91mnpm info lifecycle range-parser@1.0.3~postinstall: range-parser@1.0.3
    [0m[91mnpm info lifecycle send@0.12.1~postinstall: send@0.12.1
    [0m[91mnpm info lifecycle etag@1.6.0~postinstall: etag@1.6.0
    [0m[91mnpm info lifecycle ms@0.7.1~postinstall: ms@0.7.1
    [0m[91mnpm info lifecycle debug@2.2.0~postinstall: debug@2.2.0
    [0m[91mnpm info lifecycle send@0.12.3~postinstall: send@0.12.3
    [0m[91mnpm info lifecycle type-is@1.6.11~postinstall: type-is@1.6.11
    [0m[91mnpm info lifecycle utils-merge@1.0.0~postinstall: utils-merge@1.0.0
    [0m[91mnpm info lifecycle serve-static@1.9.3~postinstall: serve-static@1.9.3
    [0m[91mnpm info lifecycle vary@1.0.1~postinstall: vary@1.0.1
    [0m[91mnpm info lifecycle express@4.12.0~postinstall: express@4.12.0
    [0m[91mnpm info lifecycle node-hello-world@0.0.1~preinstall: node-hello-world@0.0.1
    [0m[91mnpm info linkStuff node-hello-world@0.0.1
    [0m[91mnpm info lifecycle node-hello-world@0.0.1~install: node-hello-world@0.0.1
    [0m[91mnpm info [0m[91mlifecycle node-hello-world@0.0.1~postinstall: node-hello-world@0.0.1
    [0m[91mnpm info lifecycle node-hello-world@0.0.1~prepublish: node-hello-world@0.0.1
    [0mnode-hello-world@0.0.1 /src
    `-- express@4.12.0 
      +-- accepts@1.2.13 
      | +-- mime-types@2.1.9 
      | | `-- mime-db@1.21.0 
      | `-- negotiator@0.5.3 
      +-- content-disposition@0.5.0 
      +-- content-type@1.0.1 
      +-- cookie@0.1.2 
      +-- cookie-signature@1.0.6 
      +-- debug@2.1.3 
      | `-- ms@0.7.0 
      +-- depd@1.0.1 
      +-- escape-html@1.0.1 
      +-- etag@1.5.1 
      | `-- crc@3.2.1 
      +-- finalhandler@0.3.3 
      +-- fresh@0.2.4 
      +-- merge-descriptors@0.0.2 
      +-- methods@1.1.2 
      +-- on-finished@2.2.1 
      | `-- ee-first@1.1.0 
      +-- parseurl@1.3.1 
      +-- path-to-regexp@0.1.3 
      +-- proxy-addr@1.0.10 
      | +-- forwarded@0.1.0 
      | `-- ipaddr.js@1.0.5 
      +-- qs@2.3.3 
      +-- range-parser@1.0.3 
      +-- send@0.12.1 
      | +-- destroy@1.0.3 
      | `-- mime@1.3.4 
      +-- serve-static@1.9.3 
      | `-- send@0.12.3 
      |   +-- debug@2.2.0 
      |   +-- etag@1.6.0 
      |   `-- ms@0.7.1 
      +-- type-is@1.6.11 
      | `-- media-typer@0.3.0 
      +-- utils-merge@1.0.0 
      `-- vary@1.0.1 
    
    [91mnpm info ok 
    [0m ---> 8bbdda9bbe0c
    Error removing intermediate container b35bd00b892b: nosuchcontainer: No such container: b35bd00b892b2a48782d3b756f6112255c047e30b1af1a307922c4dee491b534
    Step 5 : EXPOSE 80
     ---> Running in e0c1e5e8847b
     ---> bd9a901883d3
    Error removing intermediate container b35bd00b892b: nosuchcontainer: No such container: b35bd00b892b2a48782d3b756f6112255c047e30b1af1a307922c4dee491b534
    Step 6 : CMD node index.js
     ---> Running in 35a332534cae
     ---> 638bf58ad43d
    Error removing intermediate container b35bd00b892b: nosuchcontainer: No such container: b35bd00b892b2a48782d3b756f6112255c047e30b1af1a307922c4dee491b534
    Successfully built 638bf58ad43d
    [1B[91mnpm http 200 https://registry.npmjs.org/parseurl
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/etag
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/content-disposition
    [0m[91mnpm info retry fetch attempt 1 at 10:29:13 PM
    [0m[91mnpm info attempt registry request try #1 at 10:29:13 PM
    npm http fetch GET https://registry.npmjs.org/parseurl/-/parseurl-1.3.1.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:29:13 PM
    npm info attempt[0m[91m registry request try #1 at 10:29:13 PM
    npm http fetch GET https://registry.npmjs.org/etag/-/etag-1.5.1.tgz
    [0m[91mnpm[0m[91m http 200 https://registry.npmjs.org/proxy-addr
    [0m[91mnpm http 200 https://registry.npmjs.org/cookie
    [0m[91mnpm info retry fetch attempt 1 at 10:29:13 PM
    npm info [0m[91mattempt registry request try #1 at 10:29:13 PM
    npm http[0m[91m fetch GET https://registry.npmjs.org/content-disposition/-/content-disposition-0.5.0.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:29:13 PM
    npm info attempt registry request try #1 at 10:29:13 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/proxy-addr/-/proxy-addr-1.0.10.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:29:13 PM
    [0m[91mnpm info attempt registry request try #1 at 10:29:13 PM
    npm http fetch GET https://registry.npmjs.org/cookie/-/cookie-0.1.2.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/etag/-/etag-1.5.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/parseurl/-/parseurl-1.3.1.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/content-disposition/-/content-disposition-0.5.0.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/serve-static
    [0m[91mnpm info retry fetch attempt 1 at 10:29:17 PM
    npm info attempt registry request try #1 at 10:29:17 PM
    npm http[0m[91m fetch GET https://registry.npmjs.org/serve-static/-/serve-static-1.9.3.tgz
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/serve-static/-/serve-static-1.9.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/proxy-addr/-/proxy-addr-1.0.10.tgz
    [0m[91mnpm[0m[91m http fetch 200 https://registry.npmjs.org/cookie/-/cookie-0.1.2.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/cookie
    [0m[91mnpm http 200 https://registry.npmjs.org/finalhandler
    [0m[91mnpm http 200 https://registry.npmjs.org/qs
    [0m[91mnpm info retry fetch attempt 1 at 10:29:29 PM
    npm info attempt registry request try #1 at 10:29:29 PM
    npm http fetch GET https://registry.npmjs.org/cookie/-/cookie-0.1.2.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:29:29 PM
    npm info attempt[0m[91m registry request try #1 at 10:29:29 PM
    npm http fetch GET https://registry.npmjs.org/finalhandler/-/finalhandler-0.3.3.tgz
    [0m[91mnpm info retry fetch attempt 1 at 10:29:29 PM
    npm info attempt registry request try #1 at 10:29:29 PM
    npm http fetch GET https://registry.npmjs.org/qs/-/qs-2.3.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/cookie/-/cookie-0.1.2.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/qs/-/qs-2.3.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/finalhandler/-/finalhandler-0.3.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/serve-static
    [0m[91mnpm info retry fetch attempt 1 at 10:29:33 PM
    [0m[91mnpm info attempt registry request try #1 at 10:29:33 PM
    npm http fetch GET https://registry.npmjs.org/serve-static/-/serve-static-1.9.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/path-to-regexp
    [0m[91mnpm info retry fetch attempt 1 at 10:29:34 PM
    [0m[91mnpm info attempt registry request try #1 at 10:29:34 PM
    [0m[91mnpm http fetch GET https://registry.npmjs.org/path-to-regexp/-/path-to-regexp-0.1.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/serve-static/-/serve-static-1.9.3.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/path-to-regexp/-/path-to-regexp-0.1.3.tgz
    [0m[91mnpm http 200 https://registry.npmjs.org/proxy-addr
    [0m[91mnpm info retry fetch attempt 1 at 10:29:35 PM
    npm info attempt registry request try #1 at 10:29:35 PM
    npm http fetch GET https://registry.npmjs.org/proxy-addr/-/proxy-addr-1.0.10.tgz
    [0m[91mnpm http fetch 200 https://registry.npmjs.org/proxy-addr/-/proxy-addr-1.0.10.tgz
    [0m[31mERROR[0m: 
    Aborting.



```bash
docker-compose ps
```


```bash
docker-compose up --force-recreate -d
```


```bash
# TODO:
docker-compose events
```


```bash
docker-compose ps
```


```bash
#docker-compose logs
```


```bash
# docker-compose up
# docker-compose down
# TODO: Add heterogeneous example ...
```


```bash

```

TODO: extend to heterogeneous cases ...


# Rails Example with Compose
<a href="#TOP">TOP</a>

This example heavily inspired from this article [Building Microservices with Docker and the Rails API gem](https://medium.com/connect-the-dots/building-microservices-with-docker-and-the-rails-api-gem-2a463862f5d)

<font size=+1 color="#77f">
<b>The goal of this step is to have hands-on experience with Compose ...</b> 
<br/>
It is recommended to use [yamllint](http://www.yamllint.com/) to validate your YAML file - because it's easy to make mistakes in YAML, and Compose is picky.
</font>


```bash
cd /root
mkdir -p src/railsapi
cd src/railsapi
pwd
touch Dockerfile docker-compose.yml Gemfile Gemfile.lock
```


```bash
cat > Dockerfile <<EOF

FROM ruby:2.3.0

RUN apt-get update -qq && apt-get install -y build-essential libmysqlclient-dev

RUN mkdir /railsapi

WORKDIR /railsapi

ADD Gemfile /railsapi/Gemfile

ADD Gemfile.lock /railsapi/Gemfile.lock

RUN bundle install

ADD . /railsapi

EOF
```


See [References](#References) section below for information on *Compose*




```bash
cat > docker-compose.yml <<EOF

version: 2
services:
  db:
   image: mysql:latest
   ports:
     - 3306:3306
   environment:
     MYSQL_ROOT_PASSWORD: mypassword
   
  web:
    build: .
    command: puma
    ports:
      - 9292:9292
    links:
      - db
    volumes:
      - .:/railsapi

EOF
```


```bash
docker-compose build
```


```bash
cat > Gemfile <<EOF

source 'https://rubygems.org'

gem 'rails', '4.2.5'
gem 'rails-api', '0.4.0'
gem 'mysql2'
gem 'puma'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

# Use ActiveModelSerializers to serialize JSON responses
gem 'active_model_serializers', '~> 0.10.0.rc3'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end
 
group :development do # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

EOF
```


```bash
ls -altr
```

Now let's build our image


```bash
docker-compose build
```


```bash
docker images
```


```bash
docker-compose run web rails-api new .
```


```bash
cat > database.yml <<EOF
development:
 adapter: mysql2
 encoding: utf8
 reconnect: false
 database: inventory_manager_dev
 pool: 5
 username: root
 password: mypassword
 host: db
test:
 adapter: mysql2
 encoding: utf8
 reconnect: false
 database: inventory_manager_test
 pool: 5
 username: root
 password: mypassword
 host: db
EOF
```


```bash
docker-compose up web
```


```bash
curl http://localhost:80
```

<a name="building-docker" />
# Building Docker with Docker
<a href="#TOP">TOP</a>

<a name="Building-Docker-with-Docker" />
# Building Docker with Docker
<a href="#TOP">TOP</a>

A major advantage of Docker is to simplify build environments.

Let's look at how we can build the Docker engine client/daemon binary without having to explicitly install a development environment.

<font size=+1 color="#77f">
<b>The goal of this step is simply to show the ease with which we can build Docker, thanks to Docker itself.</b>   
</font>

We do not make particular use of the built image.

The process involves the following steps, several of which have already been performed so as to prevent excessive network utilisation during the lab.  Nevertheless all steps are  described here so that you can see just how easy it is to build Docker from scratch:
- Install make
- Clone the Docker source code
- Checkout the same code revision as our current Docker binary (client and daemon)
- Build the code - which pulls the docker-dev image containing the required version of the Go compiler
- Run the executable to demonstrate it is correct

#### Installing make

In your environment we have already installed the make package, but no compiler using yum:

    yum install make

#### Cloning the Docker source code

We have already downloaded the Docker source code from github as follows:

    mkdir -p /root/src/docker
    cd /root/src/docker
    git clone https://github.com/docker/docker .

To build Docker we simply have to build using the

    make build
    
command.

#### Checkout the source code revision corresponding to our installed Docker Engine

If we build the latest sources this may not be compatible with our installed Docker version.

This is the case.  We have 1.10.0-rc2 installed, which has API version 22, but the current github source is 1.10.0-dev which has changed to API version 23.  So if we build this we find that we cannot use this client to communicate with the installed daemon.

So let's checkout the code for 1.10.0-rc2.

At the time of writing this is the latest release(candidate) of the Docker engine.
We can obtain that version of the source code by referring to the releases page https://github.com/docker/docker/releases
and selecting the SHA1 hash of build 1.10.0-rc2 

    git checkout c1cdc6e



#### Build the code - which pulls the docker-dev image containing the required version of the Go compiler

We can build the code as follows:

    make build
    
We have run 'make build' already, so the docker-dev image has already been downloaded (again to prevent excessive network traffic).  The docker-dev image includes the required go compiler and other build tools.

Run 'make build' again and you will see a standard build process and finally where it places the compiled binary

#### Run the executable to demonstrate it is correct

In preparation for the lab we built from the latest source (not the c1cdc6e version we checked out).

Run this build as follows to see that it is not compatible with the installed binary (/usr/bin/docker).
We see that this binary has version 1.10.0-dev and API version 1.23 but that this cannot communicate with our installed binary which has API version 1.22.


```bash
cd /root/src/docker; ls -altr bundles/1.10.0-dev/binary/docker-1.10.0-dev; ./bundles/1.10.0-dev/binary/docker version
```

But if we run our new build - as follows - created from revision c1cdc6e of the source code (corresponding to Docker version 1.10.0-rc2) we see that it has the correct version, with the same API version and can interrogate the server.



```bash
cd /root/src/docker; ls -altr bundles/1.10.0-rc2/binary/docker-1.10.0-rc2; ./bundles/1.10.0-rc2/binary/docker version
```


```bash

```

# References
[TOP](#TOP)

- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)

- [Compose file documentation](https://docs.docker.com/compose/compose-file/)

- [Compose file reference](https://github.com/docker/compose/blob/1.6.0-rc1/docs/compose-file.md)

- [Visualizing Docker Containers and Images](http://merrigrove.blogspot.in/2015/10/visualizing-docker-containers-and-images.html)

- [Awesome Docker](https://github.com/veggiemonk/awesome-docker)

- [Docker Cheat Sheet]()

- [Building Good Docker Images](http://jonathan.bergknoff.com/journal/building-good-docker-images)

- [How to scale a Docker Container with Docker Compose](https://www.brianchristner.io/how-to-scale-a-docker-container-with-docker-compose/)

- [Docker Compose Demo](https://github.com/vegasbrianc/docker-compose-demo)



```bash

```
