# lol, limewire
A personal project, I guess it's a sort of malware, written in bash, for macOS.

---

# Disclaimer:
### I am not responsible for any damage to your computer. Do not run any of the scripts contaied in this repo on a computer which you are not authorized to run this on (pretty much, anyone else's computer, unless you have their consent)

---

I find malware (and how it works) interesting, and I guess this is me making a simple peice of malware, in bash. This shouldn't damage your computer or system in any way, but will (presuming it works) spread itself to ensure it gets ran.

To quote R0wDrunner, "your solutions are sometimes weird as fuck", and indeed, this is one of those (weird solutions).

---

I named this lol, limewire because the [song](https://www.youtube.com/watch?v=SAp0xO-LwFs) was/is stuck in my head.

## Stage 1
Stage one pretty much replicates itself and makes sure that it gets ran

To do:
- [ ] Test everything
- [x] Rewrite stage-1-old
- [x] Seperate DEBUG and LOGGING
- [ ] Add --debug/-d and --logging/-l
- [x] Fix log deletion issue
- [x] Add sed edits for counts 
  - [x] For LOGGING log (runs)
  - [x] For LOGGING log (replications)
  - [x] For log for removal
- [x] Add checks to prevent choosing /Applications/Utilities/
- [x] Place and edit copy of script in target location
- [ ] If replication fails, remove the placed copy of the script
- [ ] Rewrite creation and adition to log for removal, and actually make the log a removal script
- [ ] Trigger if present in x applications
- [ ] Network monitors
  - [ ] Add newest Little Snitch killing
  - [ ] Add LuLu killing
  - [ ] Add Hands Off! killing

## Stage 2
- [ ] Something to do with icon changing maybe?
- [ ] Thing about, decide on, and write stage 2
- [ ] Setup logging and debug hand-over from stage 1 (in stage 1)

## Removal
- [ ] Stage 1 removal
  - [ ] Read from record
  - [ ] Plist reverting (or restoring!!!)
  - [ ] Script removal
- [ ] Stage 2 removal
