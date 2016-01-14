docker run --rm -it -p 8878:8888 -v /usr/bin/docker:/usr/bin/docker -v /var/run/docker.sock:/var/run/docker.sock -v /vagrant:/home/jovyan/work mjbright/jupyter_demo start-notebook.sh --debug
