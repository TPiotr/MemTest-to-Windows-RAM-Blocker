## ⚠️ Disclaimer
This tool is software "band-aid." If your RAM is physically dying, more sectors may fail over time. Some sectors might appear "healthy" during a test but fail later, causing intermittent instability. In my case, this saved my 32GB kit during these unfortunate times, I’m sharing it in hopes it helps someone else too.
**Note:** This tool is for **Windows only**, as it translates raw addresses into Windows page indexes. Linux has similar options to block addresses, but you will need to research that separately.

# MemTest-to-Windows-Fixer

If you are experiencing random BSODs and system instability, your RAM may be faulty. Often, only a few specific addresses are broken (in my case, literally only a few kilobytes were bad), but they cause the whole system to crash. If you've found your way here, you likely already know this and are looking for a way to bypass the damage.

When a RAM module starts failing, MemTest86 identifies specific faulty memory addresses. While replacing the hardware is the best solution, it isn't always viable—especially with soldered laptop RAM or the current RAM market. Windows has a built-in feature called `badmemorylist` that can block these specific sectors from being used by the OS.

## What this script does?
Automates the process of parsing MemTest86 logs and executing the `bcdedit` commands required to populate that list (if you want you could do this by hand).

## What you need
1. USB drive
2. Admin privileges on your machine

## 🛠️ How to Use

### **Step 1: The Hard Part (Gathering Data)**

1. Download **MemTest86** and create a bootable USB drive. (popular program to test your RAM, you can find a lot of resources online how to use it)
2. Boot from the USB drive (change the boot order in your BIOS) and run the test.
3. You don't necessarily have to finish the test. Even if it fails due to too many errors, the log file we need will be saved.
4. Once the test has run, unplug the USB, restart your PC, and boot back into Windows.
5. Plug the MemTest86 thumb drive back in. Open File Explorer and navigate to:
`USB Drive -> EFI -> BOOT`
6. Locate your `.log` file (e.g., `MemTest86-20260307-160643_243435.log`).

### **Step 2: The Easy Part (Applying the Fix)**

1. Download the `findBadMemAdressesAndApplyFix.bat` file from this repository.
2. Drag your `.log` file onto the `.bat` file, or double-click the `.bat` to browse for the log via file browser.
3. Review the detected bad pages. (Take a screenshot or copy them; it’s helpful for verification later).
4. Type `Y` and press Enter to apply the fix. (Windows will ask for Administrator privileges).
5. Another console should popup with success information.
6. **Restart your computer.**

---

## 🔍 How to Verify the Fix

We can use a tool called **RAMMap** to verify that Windows is actually ignoring the faulty addresses.

1. Download **RAMMap** (part of Microsoft Sysinternals). Just first google link should take you to offical Microsoft site where you can download it.
2. Open the app and go to the **"Physical Ranges"** tab.
3. Look for the address ranges that match your blocked faulty addresses.
4. You should see that your RAM ranges are now split. For example, if you blocked a small section of memory, you will see two separate ranges of "Available" memory with a gap between them where your faulty addresses used to be.
