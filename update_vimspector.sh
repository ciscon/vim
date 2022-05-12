curl -skL https://github.com/puremourning/vimspector/releases/download/2254158724/vimspector-linux-2254158724.tar.gz|tar -C ./pack/ -xzvf -
find ./pack/vimspector/opt/vimspector/gadgets/linux/download/ -mindepth 1 -maxdepth 1 -type d ! -iname '*php*' -exec rm -rf {} \;
ln -sf ../../../../../../vimspector.json ./pack/vimspector/opt/vimspector/configurations/linux/_all/vimspector.json
