感谢各位大佬的无私奉献



qemu-img convert -f raw -O qcow2 DSM.img DSM.qcow2  #镜像转换

qm importdisk 102 DSM.qcow2 local-lvm               #镜像挂载
