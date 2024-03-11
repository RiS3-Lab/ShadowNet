# ShadowNet Test Environment Setup
- Hardware Platform: Hikey960 (available on ebay).
- Flash AOSP Images with modified TEE OS, UEFI and ShadowNet TA. (see hikey-images/)
- Models: ShadowNet model has two part: part a (loaded and run inside CA); part b (loaded into TEE and run by TA, see models/);
- Android Demo App (see tflite-demo-java-app/)
- Android Demo App runtime modified tflite library (see tflite-shadownet-lib/)
- TA: ShadowNet trusted application (see ta/);

Disclaimer: Our lab server sufferred a disk error(three out eight RAID5 disks array broke and it was too late to realize the consequence). We lost all our data and experimental environment. We lost unsynced code, data. Thanks to the fact that we have to copy compiler images and flashed them onto our experimental board for evaluation, we got some leftover. What we are trying to offer here is what is copied from server to local desktop for flash images onto our development board. We can't provide any guarante here.

## Android studio
`/path-to-androidstudio/android-studio/bin/studio.sh`

## update ta and ca
- adb install ta
```
adb root
adb remount system rw
adb push 8aaaf200-2450-11e4-abe2-0002a5d5c51b.ta /system/lib/optee_armtz/8aaaf200-2450-11e4-abe2-0002a5d5c51b.ta
```
#
## test MobileNets
- step1: copy mobilenet model part b(tee) to board as /data/data/android.example.com.tflitecamerademo/cache/masks.weights
- step2: copy mobilenet model part a(Normal World) to board /data/data/android.example.com.tflitecamerademo/cache/mobilenet.tflite 
