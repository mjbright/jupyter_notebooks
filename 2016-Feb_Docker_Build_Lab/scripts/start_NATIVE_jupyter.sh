
cd /vagrant/

env | grep TMUX || {
    echo "Best started under tmux ... tmux not running - exiting"
    exit 1
}

[ -f vagrant.jupyter.log ] && mv vagrant.jupyter.log vagrant.jupyter.log.bak

jupyter notebook --debug --no-browser |& tee vagrant.jupyter.log


