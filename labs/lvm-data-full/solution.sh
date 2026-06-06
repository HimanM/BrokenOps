#!/bin/bash
lvextend -l +100%FREE /dev/vg_data/lv_data
resize2fs /dev/vg_data/lv_data
