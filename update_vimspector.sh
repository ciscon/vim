link=https://github.com/puremourning/vimspector/releases/download/2862812645/vimspector-linux-2862812645.tar.gz

sudo apt install -y nodejs
rm -rf ./pack/vimspector
curl -skL "$link"|tar -C ./pack/ -xzf -
./pack/vimspector/opt/vimspector/install_gadget.py
chmod u+wX ./pack -Rf
find ./pack/vimspector/opt/vimspector/gadgets/linux/download/ -mindepth 1 -maxdepth 1 -type d ! -iname '*php*' -exec rm -rf {} \;
ln -sf ../../../../../../../vimspector.json ./pack/vimspector/opt/vimspector/configurations/linux/_all/vimspector.json
