
JUPYTER_DEBUG=""
JUPYTER_DEBUG="--debug"

DOCKER_VOLUMES="-v /usr/bin/docker:/usr/bin/docker -v /var/run/docker.sock:/var/run/docker.sock"

#docker run --rm -it -p 8888:8888 \
           #-v /var/run/docker.sock:/var/run/docker.sock \
           #-v /vagrant:/home/jovyan/work \
           #mjbright/jupyter_all-notebook

# Vagrant mapping:
#    8888 -> 8880 (use http://localhost:8880 in external browser)
#    8878 -> 8870 (use http://localhost:8880 in external browser)

die() {
    echo "$0: die - $*" >&2
    exit 1
}

env | grep TMUX || 
    die "Best started under tmux ... tmux not running - exiting"

REVEAL=".jupyter/nbconfig/livereveal.json"
CSS=".jupyter/custom/custom.css"
SKYCSS=".local/share/jupyter/nbextensions/livereveal/reveal.js/css/theme/sky.css"

VOLUME_REVEAL="/home/vagrant/$REVEAL:/home/jovyan/$REVEAL"
VOLUME_CSS="/home/vagrant/$CSS:/home/jovyan/$CSS"
VOLUME_SKYCSS="/home/vagrant/$SKYCSS:/home/jovyan/$SKYCSS"

native_jupyter() {
    cd /vagrant/

    [ -f vagrant.jupyter.log ] && mv vagrant.jupyter.log vagrant.jupyter.log.bak

    jupyter notebook $JUPYTER_DEBUG --no-browser |& tee vagrant.jupyter.log
}

docker_demo() {
    IMAGE=demo
    [ -f docker.jupyter.${IMAGE}.log ] && mv docker.jupyter.${IMAGE}.log docker.jupyter.${IMAGE}.log.bak

    CMD=""
    [ ! -z "$JUPYTER_DEBUG" ] &&
        #CMD="tini -- start-notebook.sh $JUPYTER_DEBUG"
        CMD="start-notebook.sh $JUPYTER_DEBUG"

    set -x
    docker run --rm -it -p 8878:8888 \
           $DOCKER_VOLUMES \
           -v /vagrant:/home/jovyan/work \
           -v $VOLUME_REVEAL \
           -v $VOLUME_CSS    \
           -v $VOLUME_SKYCSS    \
           mjbright/jupyter_demo $CMD |& tee docker.jupyter.${IMAGE}.log
    set +x
}

docker_minimal() {
    IMAGE=minimal
    [ -f docker.jupyter.${IMAGE}.log ] && mv docker.jupyter.${IMAGE}.log docker.jupyter.${IMAGE}.log.bak

    CMD=""
    [ ! -z "$JUPYTER_DEBUG" ] &&
        #CMD="tini -- start-notebook.sh $JUPYTER_DEBUG"
        CMD="start-notebook.sh $JUPYTER_DEBUG"

    docker run --rm -it -p 8888:8888 \
           $DOCKER_VOLUMES \
           -v /vagrant:/home/jovyan/work \
           -v $VOLUME_REVEAL \
           -v $VOLUME_CSS    \
           -v $VOLUME_SKYCSS    \
           mjbright/jupyter_minimal-notebook $CMD |& tee docker.jupyter.${IMAGE}.log
}


[ -z "$1" ] && set -- -demo

while [ ! -z "$1" ];do
    case $1 in
        -demo)
            docker_demo;;
        -min*)
            docker_minimal;;
        -n*)
            native_jupyter;;

        *) die "Unknown option '$1'";;
    esac
    shift
done

#if [ "$1" = "-demo" ];then
#else
#fi


