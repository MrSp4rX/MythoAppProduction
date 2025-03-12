import os
import platform
import sys

RED = "\033[91m"
GREEN = "\033[92m"
BLUE = "\033[94m"
CYAN = "\033[96m"
RESET = "\033[0m"

NULL_DEVICE = "nul" if platform.system() == "Windows" else "/dev/null"

def run_command(command):
    os.system(f"{command} > {NULL_DEVICE} 2>&1")

def basic():
    print(f"{GREEN}Running Flutter Script!{RESET}")
    print(f"{RED}Removing Old Libraries!{RESET}")
    run_command("flutter clean")
    print(f"{GREEN}Getting Latest Packages!{RESET}")
    run_command("flutter pub get")

def main():
    if len(sys.argv) != 2 or sys.argv[1] not in ["debug", "release", "push"]:
        print(f"{RED}Usage: python run.py <debug|release|push>{RESET}")
        sys.exit(1)

    build_mode = sys.argv[1]

    os.system("cls" if platform.system() == "Windows" else "clear")
    

    if build_mode == "debug":
        basic()
        print(f"{BLUE}Running Debug APK with Logs!{RESET}")
        os.system("flutter run")
        
    elif build_mode == "release":
        basic()
        print(f"{BLUE}Building Release APK!{RESET}")
        run_command("flutter build apk")
        print(f"{CYAN}Installing APK!{RESET}")
        run_command("flutter install")
        print(f"{GREEN}Run APK Now!{RESET}")
        sys.exit(0)

    elif build_mode == "push":
        print(f"{BLUE}Adding Changes in GIT{RESET}")
        os.chdir("../")
        os.system("git add .")
        msg = input(f"{CYAN}Enter Commit Message: {RESET}")
        os.system(f"git commit -m {msg}")
        print(f"{CYAN}Pushing Now on MAIN Branch!{RESET}")
        os.system("git push origin main")
        print(f"{GREEN}Pushed to MAIN Branch Successfully!{RESET}")
        sys.exit(0)
    else:
        print(f"{RED}Invalid Build Mode!{RESET}")
        sys.exit(1)
        

if __name__ == "__main__":
    main()
