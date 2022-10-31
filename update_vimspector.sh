link=https://github.com$(curl -s https://github.com/puremourning/vimspector/tags|grep --color=never -E 'refs/tags/[0-9]+\.tar\.gz'| head -n1 | awk -F 'href="' '{print $2}' | awk -F'"' '{print $1}')

sudo apt install -y nodejs
rm -rf ./pack/vimspector
curl -skL "$link"|tar -C ./pack/ -xzf -
mv -f ./pack/vimspector* ./pack/vimspector

if [ -d ./pack/vimspector/opt/vimspector ];then
	vimspecbase=./pack/vimspector/opt/vimspector
else
	vimspecbase=./pack/vimspector
	ln -sf ../../.. pack/vimspector/opt
fi

./$vimspecbase/install_gadget.py --force-enable-php

chmod u+wX ./pack -Rf
#find $vimspecbase/gadgets/linux/download/ -mindepth 1 -maxdepth 1 -type d ! -iname '*php*' -exec rm -rf {} \;
ln $(readlink -f vimspector.json) $vimspecbase/configurations/linux/_all/vimspector.json
