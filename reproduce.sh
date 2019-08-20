# rm -rf ~/tmp/source
# rm -rf ~/tmp/digikam
# rm -rf ~/tmp/res
# rm -f ~/pictures/*.db
# rm -f ~/.config/digikamrc
# rm -rf ~/.local/share/digikam
# rm -rf ~/.cache/digikam
# mkdir -p ~/tmp/res
ppwd="$PWD"
export HOME=$(mktemp -d)
for i in `env | sed 's/=.*//' | grep XDG`; do unset $i; done
cd "$HOME"
mkdir -p "$HOME/Pictures"
mkdir -p "$HOME/build/share"
export XDG_DATA_DIRS="$HOME/build/share"
ln -s /home/timo/tmp/deletable-pics "$HOME/Pictures/p"

nix-shell -A digikam "$ppwd" --command '
	unpackPhase &&
	cd digikam || cd source &&
	cmake -DCMAKE_INSTALL_PREFIX=$HOME/build -DCMAKE_BUILD_TYPE=debug . &&
	make -j4 &&
	make install &&
	echo -e "gdb -q -ex r core/app/digikam" > run-in-gdb.sh &&
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
