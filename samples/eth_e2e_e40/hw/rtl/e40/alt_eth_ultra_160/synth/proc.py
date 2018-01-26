
import os

dir = {}

# traverse root directory, and list directories as dirs and files as files
for root, dirs, files in os.walk("/tools/acdstest-rtl/16.0/211/linux64/ip/altera/ethernet/alt_eth_ultra/40g/mentor"):
    path = root.split(os.sep)
    for file in files:
        dir[file] = "/".join(path) + "/" + file

x = open("files.txt","r")

os.system("mkdir ./bak")
while (1):
	f = x.readline().strip()
	if f == "": break
	os.system("mv ./" + f + " ./bak")
	os.system("cp -rf " + dir[f] + " .")

print "done"
