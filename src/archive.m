build(true)
curdir = cd;
cd ..
copyfile dist zebrain
zip zebrain.zip zebrain
rmdir zebrain s
cd(curdir);