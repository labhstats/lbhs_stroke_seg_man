#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Oct 25 11:21:26 2017

Copy files from source_dir into target_dir while upholding the higher level structure.

#source_dir: Location of the files to be copied.
#target_dir: Location of where the files should be copied to.
#sub_dir: Name of the sub-folder ("under ID") containing the files desired.

@author: lars
"""

def copy_from_to_manual_ids(source_dir,target_dir,sub_dir,ids_specified):
    
    print "Source: ",source_dir, " Target: " ,target_dir, " Folder: " ,sub_dir
    
    import shutil
    
    id_list_dir = ids_specified
    
    n = len(id_list_dir)
    n_i = 1
    
    for i in id_list_dir:
        print "Copying ID: ", i, " Number: ", n_i, " of ", n
        
        source_i_dir = source_dir + i + sub_dir
        target_i_dir = target_dir + i + sub_dir
        shutil.copytree(source_i_dir,target_i_dir)
        
        n_i = n_i + 1
        print("ID copied...")
    
    print("Finished...")


nifti_sorted_dir = "/media/lars/LaCie/sorted_nifti/"
working_dir = "/home/lars/Desktop/stroke_few_cases/more_cases/T1_images/"
#series_type_dir = "/T2_FLAIR_3D/"
series_type_dir = "/T1_3D_SAG/"

import pandas
id_csv = pandas.read_csv("/home/lars/Desktop/stroke_few_cases/more_cases/other/hemi_flip.csv")
id_csv["ID"].tolist()

string_lpa_id_list = [str(i) for i in id_csv["ID"].tolist()]


copy_from_to_manual_ids(nifti_sorted_dir,
                        working_dir,
                        series_type_dir,
                        string_lpa_id_list)
