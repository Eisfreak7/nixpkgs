rm -rf ~/tmp/source
rm -rf ~/tmp/res
rm -f ~/pictures/*.db
rm -f ~/.config/digikamrc
rm -rf ~/.local/share/digikam
rm -rf ~/.cache/digikam
mkdir -p ~/tmp/res

nix-shell -A digikam --command '
	cd ~/tmp &&
	unpackPhase &&
	echo waiting &&
	true || read &&
	cd source &&
	cmake -DCMAKE_INSTALL_PREFIX=/home/timo/tmp/res -DCMAKE_BUILD_TYPE=debug . &&
	make -j4 &&
	make install &&
	echo "gdb -q -ex r core/app/digikam" > run-in-gdb.sh &&
	chmod +x run-in-gdb.sh &&
	wrapQtApp run-in-gdb.sh &&
	./run-in-gdb.sh;
	return
'

# hit enter a couple of times to confirm all initialization dialogs
# wait for digikam to recognize all images
# hit faces tab
# click scan collection for new faces -> detect faces, clear unconfirmed results and rescan -> scan
# select the `Unknown` tag to make sure thumbnails are shown
# https://bugs.kde.org/show_bug.cgi?id=399923
