#!/usr/bin/swift

import CoreGraphics

func display() -> CGDirectDisplayID? {
    let max: UInt32 = 32;
    let displays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: Int(max));
    let size = UnsafeMutablePointer<UInt32>.allocate(capacity: 1);
    CGGetActiveDisplayList(max, displays, size);

    if (size.pointee == 2) {
        return displays[1];
    }

    return nil;
}

func target() -> Double? {
    if (CommandLine.arguments.count < 2) {
        return nil;
    }
    let t = CommandLine.arguments[1];
    return Double(t)

}

func printmode(_ mode: CGDisplayMode) {
    print(" - \(mode.pixelWidth)x\(mode.pixelHeight) @ \(mode.refreshRate)")
}

func mapModes(_ id: CGDirectDisplayID, _ fn: (CGDisplayMode) -> Void) {
    let modes = CGDisplayCopyAllDisplayModes(id, nil);
    let count = CFArrayGetCount(modes);
    let width: Int = 1920
    let height: Int = 1080

    for i in 0...(count-1) {
        let mode: CGDisplayMode = unsafeBitCast(
            CFArrayGetValueAtIndex(modes, i), to: CGDisplayMode.self);

        if (mode.pixelWidth != width || mode.pixelHeight != height ||
            !mode.isUsableForDesktopGUI()) {
            continue;
        }

        fn(mode);
    }

}

func printCurrentMode(_ id: CGDirectDisplayID) {
        if let current = CGDisplayCopyDisplayMode(id) {
            print("current mode: ")
            printmode(current)
        }

}

func setDisplayMode(_ id: CGDirectDisplayID, _ mode: CGDisplayMode) {
    let config = UnsafeMutablePointer<CGDisplayConfigRef?>.allocate(capacity:1)
    let error = CGBeginDisplayConfiguration(config)
    if error == .success {
        CGConfigureDisplayWithDisplayMode(config.pointee, id, mode, nil)
        let afterCheck = CGCompleteDisplayConfiguration(
            config.pointee, CGConfigureOption.permanently)
        if afterCheck != .success {
            CGCancelDisplayConfiguration(config.pointee)
        }
    }
}

func main() {
    if let id = display() {
        printCurrentMode(id);

        print("modes: ")
        mapModes(id, printmode);

        if let t = target() {
            print("\nsetting mode with refresh \(t)...")
            mapModes(id) {
                if ($0.refreshRate == t) {
                    setDisplayMode(id, $0);
                    printCurrentMode(id);
                }
            }
        }
    } else {
        print("second display not connected");
    }
}

main()
