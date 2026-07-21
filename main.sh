#!/usr/bin/env bash

# USBMuxd & Pairing Helper for Termux (No-Root)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SELECTED_USB=""

check_iphone_status() {
    local udid
    udid=$(idevice_id -l 2>/dev/null | head -n 1)

    if [ -z "$udid" ]; then
        echo -e "${RED}🔴 iPhone Status: DISCONNECTED (or usbmuxd not running)${NC}"
    else
        if idevicepair validate >/dev/null 2>&1; then
            echo -e "${GREEN}🟢 iPhone Status: CONNECTED & TRUSTED${NC} (UDID: ${CYAN}${udid:0:8}...${NC})"
        else
            echo -e "${YELLOW}🟠 iPhone Status: CONNECTED - UNTRUSTED / UNPAIRED${NC}"
        fi
    fi
}

while true; do
    clear
    echo -e "${CYAN}=====================================================${NC}"
    echo -e "${CYAN}       🚀 USBMUXD & PAIRING TOOL (NO-ROOT)           ${NC}"
    echo -e "${CYAN}=====================================================${NC}"

    check_iphone_status

    if [ -n "$SELECTED_USB" ]; then
        echo -e "${GREEN}📌 Selected USB:${NC} ${CYAN}$SELECTED_USB${NC}"
    else
        echo -e "${YELLOW}📌 Selected USB:${NC} None (Run Option 2)"
    fi
    echo -e "${CYAN}-----------------------------------------------------${NC}"
    echo -e "${YELLOW}[1]${NC} Setup Packages & Check Termux:API"
    echo -e "${YELLOW}[2]${NC} List USB Devices & Request Permission"
    echo -e "${YELLOW}[3]${NC} Start usbmuxd (Background)"
    echo -e "${YELLOW}[4]${NC} Test Pairing (2-Step Verification)"
    echo -e "${YELLOW}[5]${NC} Exit"
    echo -e "${CYAN}=====================================================${NC}"
    read -rp "👉 Choice (1-5): " CHOICE

    case $CHOICE in
        1)
            clear
            echo -e "${YELLOW}=== 1: SETUP & CHECK DEPENDENCIES ===${NC}\n"
            pkg update -y && pkg upgrade -y
            pkg install libusb libimobiledevice termux-api usbmuxd -y

            echo ""
            if command -v termux-usb &>/dev/null; then
                echo -e "${GREEN}✓ 'termux-usb' found. Environment ready.${NC}"
            else
                echo -e "${RED}❌ Missing Termux:API! Please install the Termux:API app on your TV.${NC}"
            fi
            echo ""
            read -rp "Press Enter to return..."
            ;;

        2)
            clear
            echo -e "${YELLOW}=== 2: USB DEVICE LIST & PERMISSION ===${NC}\n"
            echo "[+] Scanning for USB devices..."

            USB_LIST=($(termux-usb -l 2>/dev/null | grep -o '/dev/bus/usb/[0-9]*/[0-9]*'))

            if [ ${#USB_LIST[@]} -eq 0 ]; then
                echo -e "${RED}❌ No USB devices found!${NC}"
                echo "👉 Tip: Reconnect the cable or unlock your iPhone screen."
                SELECTED_USB=""
            else
                echo -e "${GREEN}✓ Found ${#USB_LIST[@]} USB device(s):${NC}\n"
                for i in "${!USB_LIST[@]}"; do
                    echo -e "   [${YELLOW}$((i+1))${NC}] ${CYAN}${USB_LIST[$i]}${NC}"
                done

                echo ""
                read -rp "👉 Select device number (Default 1): " USB_INDEX
                USB_INDEX=${USB_INDEX:-1}

                REAL_INDEX=$((USB_INDEX - 1))
                SELECTED_USB="${USB_LIST[$REAL_INDEX]}"

                if [ -n "$SELECTED_USB" ]; then
                    echo -e "\n[+] Requesting permission for: ${CYAN}$SELECTED_USB${NC}"
                    echo -e "Command: ${YELLOW}termux-usb -r $SELECTED_USB${NC}"

                    termux-usb -r "$SELECTED_USB"

                    echo -e "\n${GREEN}✓ Permission request sent!${NC}"
                    echo -e "⚠️  ${YELLOW}ANDROID TV NOTE:${NC} If no popup appears on TV:"
                    echo "   Go to TV Settings -> Apps -> Termux:API -> Enable 'Display over other apps'."
                else
                    echo -e "${RED}Invalid selection!${NC}"
                    SELECTED_USB=""
                fi
            fi
            echo ""
            read -rp "Press Enter to return..."
            ;;

        3)
            clear
            echo -e "${YELLOW}=== 3: START USBMUXD ===${NC}\n"

            if [ -z "$SELECTED_USB" ]; then
                SELECTED_USB=$(termux-usb -l 2>/dev/null | grep -o '/dev/bus/usb/[0-9]*/[0-9]*' | head -n 1)
            fi

            if [ -z "$SELECTED_USB" ]; then
                echo -e "${RED}❌ No USB device found! Please run Option 2 first.${NC}"
            else
                pkill -f usbmuxd 2>/dev/null

                echo -e "[+] Starting usbmuxd on: ${CYAN}$SELECTED_USB${NC}"
                echo -e "Command: ${YELLOW}termux-usb -r -E -e \"usbmuxd -f -p\" $SELECTED_USB${NC}"

                termux-usb -r -E -e "usbmuxd -f -p" "$SELECTED_USB" >/dev/null 2>&1 &

                sleep 2
                if pgrep -x "usbmuxd" >/dev/null; then
                    echo -e "\n${GREEN}✓ usbmuxd is running in the background!${NC}"
                else
                    echo -e "\n${YELLOW}⚠️ usbmuxd command dispatched via termux-usb.${NC}"
                fi
            fi
            echo ""
            read -rp "Press Enter to return..."
            ;;

        4)
            clear
            echo -e "${YELLOW}=== 4: PAIRING TEST (2-STEP) ===${NC}\n"
            echo -e "${CYAN}--- STEP 1: INITIATE PAIR REQUEST ---${NC}"
            echo "👉 Check iPhone screen: Tap 'Trust' and ENTER YOUR PASSCODE."
            echo ""

            idevicepair pair

            echo -e "\n[+] Waiting 5 seconds..."
            sleep 5

            echo -e "\n${CYAN}--- STEP 2: CONFIRM CONNECTION ---${NC}"
            PAIR_OUT_2=$(idevicepair pair 2>&1)
            echo "$PAIR_OUT_2"

            if echo "$PAIR_OUT_2" | grep -i "SUCCESS" >/dev/null; then
                echo -e "\n${GREEN}🎉 PAIRING SUCCESSFUL!${NC}"
            else
                echo -e "\n${YELLOW}⚠️ Pairing incomplete. Ensure you tapped 'Trust' and entered your passcode.${NC}"
            fi
            echo ""
            read -rp "Press Enter to return..."
            ;;

        5)
            clear
            echo "Exiting..."
            exit 0
            ;;

        *)
            echo -e "${RED}Invalid choice!${NC}"
            sleep 1
            ;;
    esac
done
