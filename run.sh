bash script
for file in $(ls inputs)
do
    ./a.out inputs/$file
done
