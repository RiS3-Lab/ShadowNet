#!/bin/sh
#scp e1:/home/ethan/optee_android_manifest/out/target/product/hikey960/vendor/lib/optee_armtz/8aaaf200-2450-11e4-abe2-0002a5d5c51b.ta  .
repo=optee_android_manifest_v390dirty
#repo=optee_android_manifest
#adb push 8aaaf200-2450-11e4-abe2-0002a5d5c51b.ta /sdcard/work/
#adb root
#adb remount vendor rw
#adb push 8aaaf200-2450-11e4-abe2-0002a5d5c51b.ta /vendor/lib/optee_armtz/

remount() {
	adb root
	adb remount vendor rw
}

push() {
	adb push 8aaaf200-2450-11e4-abe2-0002a5d5c51b.ta /vendor/lib/optee_armtz/
}

push_ca() {
	adb push optee_example_hello_world /vendor/bin/
}

fetch() {
	md5sum 8aaaf200-2450-11e4-abe2-0002a5d5c51b.ta 
	scp e1:/home/ethan/$repo/out/target/product/hikey960/vendor/lib/optee_armtz/8aaaf200-2450-11e4-abe2-0002a5d5c51b.ta  .
	md5sum 8aaaf200-2450-11e4-abe2-0002a5d5c51b.ta 
}

MASKS_PATH=/data/data/android.example.com.tflitecamerademo/cache/
fetch_and_push_masks() {
	md5sum $1 
	scp e1:/home/ethan/flatbuf_test/shadownet-model/level_1/$1  .
	adb push $1 $MASKS_PATH
	md5sum $1 
}

fetch_ca() {
	md5sum optee_example_hello_world
	scp e1:/home/ethan/$repo/out/target/product/hikey960/vendor/bin/optee_example_hello_world .
	md5sum optee_example_hello_world
}

WEIGHTS_PATH=/data/data/android.example.com.tflitecamerademo/cache/
weights_src="/home/ethan/flatbuf_test/shadownet-model/level_1/"
fetch_and_push_weights() {
	#scp e1:$weights_src/$1 .
	adb push $1 $WEIGHTS_PATH
}

#[ $# -ne 2 ] && { echo "Usage: $0 cmd filename" } 
[ $# -eq 0 ] && { echo "Usage: $0 cmd [filename]"; exit 1; } 

echo $1 
case "$1" in
	"pushta") echo "push ta" 
		push 
		;;
	"ta") echo "fetch and push ta" 
		fetch
		push 
		;;
	"all") echo "adb root and remount vendor and fetch and push TA"
		#remount
		#fetch
		#fetch_ca
		push
		push_ca
		;;
	"re") echo "remount only"
		remount
		;;
	"ca") echo "fetch and push ca"
		fetch_ca
		push_ca
		;;
	"wt") echo "fetch and push weights"
		[ $# -ne 2 ] && { echo "Usage: $0 $1 filename"; exit 1; } 
		fetch_and_push_weights $2
		;;
	"masks") echo "fetch and push masks"
		[ $# -ne 2 ] && { echo "Usage: $0 $1 filename"; exit 1; } 
		fetch_and_push_masks $2
		;;

esac
		

