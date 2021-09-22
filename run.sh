bash script
for file in $(ls inputs)
do
    yes '' | sed 3q
    echo "${file##*/}"
    yes '' | sed 1q
    ./a.out inputs/$file
done
