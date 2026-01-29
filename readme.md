## Cake
``` 
     🎂  CAKE SYSTEM MONITOR  🎂  
      ===========================
      
        
      ██████╗  █████╗ ██╗  ██╗███████╗              
     ██╔════╝ ██╔══██╗██║ ██╔╝██╔════╝              
     ██║      ███████║█████╔╝ █████╗                
     ██║      ██╔══██║██╔═██╗ ██╔══╝                
     ╚██████╗ ██║  ██║██║  ██╗███████╗              
      ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝

```
## About
Cake is all about a custom display, similar to Neofetch, that is fully customizable. View live system stats and information all in one active display. Plugins can customize welcome screens, themes and ascci art. You can edit them and change them in the files or, in the built in config settings, to your needs.

### Features
- Built in apps panel/switcher (activated when you press "a")
- Settings and easy config (activated when you press "q")
- 
A system stats moniter that displays current system information, time, date and hostname.
## Screenshots

#### Hello plugin loaded:
<img width="774" height="279" alt="Screenshot 2026-01-28 at 19 26 25" src="https://github.com/user-attachments/assets/7d594ebe-b2f1-47d9-9543-d3b679584872" />

---

## Installation
Installing Cake is easy and simple for new users. <br>
```
# First, update:
sudo apt update
```

```
# Then install git, if not already installed:
sudo apt install git
```

```
# Now, clone the repo:
git clone https://github.com/SYOP200/Cake.git
# If that does not work, try "sudo git https://github.com/SYOP200/Cake.git"
```

```
# Then open the directory:
cd Cake
```

```
# Finally, run cake:
bash cake.sh
```
---

## Project Structure
```
Cake/
├── core/
│   ├── terminal.c        
│   ├── exec.c           
│   ├── plugin.c       
│   ├── theme.c         
│   └── cake.h         
│
├── plugins/
│   └── sample_plugin.c
|   └── hello_plugin.c
|   └── default_plugin.c
│
├── themes/
│   └── default.json
│
├── ui/                   


```
---

**Made by SYOP200**

