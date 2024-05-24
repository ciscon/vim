git submodule foreach --recursive git reset --hard
git submodule update --init --recursive --remote
chmod u+wX ./pack -Rf
./pack/vimspector/install_gadget.py --force-enable-php
rm -f ./pack/vimspector/configurations/linux/_all/vimspector.json 
ln -sf .. pack/vimspector/opt
ln -sf $(readlink -f vimspector.json) ./pack/vimspector/configurations/linux/_all/vimspector.json
