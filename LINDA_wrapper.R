###
# LINDA R Wrapper
###

require(LINDA)
require(ANTsRCore)
require(ANTsR)
require(ITKR)
require(oro.nifti)

#Double check that you have FSL installed, and that its path is specified correctly for "fslorient".


###
# 0. Initial information. Change it yourself depending on data and situation.

base_work_path = "/home/lars/Desktop/stroke_few_cases/T1_images/"

common_pattern = "/T1_3D_SAG/"

old_name = "t1_3d_sag.nii.gz"
new_name = "t1_3d_sag_RtoL.nii.gz" #Do not have equal to "old_name".

path_to_flip_csv = "/home/lars/Desktop/stroke_few_cases/other/flip_hemi.csv" # 0 = left. 1 = right. 2 = bilateral.
out_path_stat_csv = "/home/lars/Desktop/stroke_few_cases/other/stats_stroke.csv"

overwrite_new = FALSE
LINDA_cache = TRUE

linda_prob_pred_name = "linda/Prediction3_probability_native.nii.gz"

thr_of_max = 0.5

###
# 1. Copying original image.
nchar_old = nchar(old_name)

setwd(base_work_path)
IDs_pres = list.files()

n_ids = length(IDs_pres)

print(IDs_pres)
print(paste("Number of IDs found:",n_ids,sep = " "))

for(i in 1:n_ids){
  fresh_copy = FALSE
  
  print("--------------------------------")
  current_ID = IDs_pres[i]
  
  ##Check original file.
  current_file = paste(base_work_path,current_ID,common_pattern,old_name,sep = "")
  
  print("Current file considering copied is:")
  print(current_file)
  
  current_file_exist = file.exists(current_file)
  if(current_file_exist){
    print("It exists, continuing...")
  }
  else{
    print("It does not exists...")
  }
  
  ##Check possible existing copy.
  possibly_existing_new_file = paste(base_work_path,current_ID,common_pattern,new_name,sep = "")
  
  print("Possible new file name is:")
  print(possibly_existing_new_file)
  
  new_file_exist = file.exists(possibly_existing_new_file)
  if(new_file_exist){
    print("New file exists, should it be replaced?")
    print(overwrite_new)
    
    if(overwrite_new){
      fresh_copy = TRUE
    }
  }
  else{
    print("New file does not exists, copying if required/wanted.")
    fresh_copy = TRUE
  }
  
  #Handles the copying process, include further & statements to determine necessity from list.
  if(current_file_exist & fresh_copy){
    print("Copying new file...")
    file.copy(from = current_file,to = possibly_existing_new_file,overwrite = overwrite_new)
    #We always make a copy to cover all possible cases.
  }
  else{
    warning(paste("File to copy from does not exists...",current_file,"Something may be amiss!",sep = " "))
  }
  
  ###
  # 2. Swapping direction of the copied image.
  if(fresh_copy){
    base_command = "/usr/local/fsl/bin/fslorient -swaporient "
    full_command = paste(base_command,possibly_existing_new_file,sep = "")
    
    print("Executing following command in system:")
    print(full_command)
    system(full_command,wait = TRUE)
    print("System command completed...")
  }
  else{
    print("Not swapping orientation...")
  }
  
}


###
# 3. Running LINDA.

bilateral_folder = "sec_bil_run/" #Append after common_pattern.

flip_csv = read.csv(path_to_flip_csv) #Assume coloumn 1 = ID and coloumn 2 = Flip indexing.

ID_flip = flip_csv[,1]
index_flip = flip_csv[,2]

n_csv = dim(flip_csv)[1]

for(i in 1:n_csv){
  
  current_ID = as.character(ID_flip[i])
  current_flip = index_flip[i]
  
  
  ################################################## Unilateral case:
  if(current_flip == 0){
    #Use original
    current_file = paste(base_work_path,current_ID,common_pattern,old_name,sep = "")
    
    
    print(current_file)
    current_file_exist = file.exists(current_file)
    
    if(current_file_exist){
      print("Starting unilateral LINDA for:")
      print(current_file)
      
      #linda_predict(current_file,cache = LINDA_cache)
      linda_predict_custom(current_file,cache = LINDA_cache)
    }
    else{
      warning(paste("LINDA PREDICTION: This file does not exist... ",current_file,sep = ""))
    }
    
  }
  
  
  ################################################## Unilateral flipped case:
  if(current_flip == 1){
    #Use flipped
    current_file = paste(base_work_path,current_ID,common_pattern,new_name,sep = "")
    
    
    print(current_file)
    current_file_exist = file.exists(current_file)
    
    if(current_file_exist){
      print("Starting unilateral (flipped) LINDA for:")
      print(current_file)
      
      #linda_predict(current_file,cache = LINDA_cache)
      linda_predict_custom(current_file,cache = LINDA_cache)
    }
    else{
      warning(paste("LINDA (flipped) PREDICTION: This file does not exist... ",current_file,sep = ""))
    }
    
  }
  
  
  ################################################## Bilateral case:
  if(current_flip == 2){
    #Use both hemispheres!
    #This requires the second file to be moved to its own folder.
    #And, unfortunately this additional structure has to be considered later as well...
    
    sep_folder = paste(base_work_path,current_ID,common_pattern,bilateral_folder,sep = "")
    
    exist_sep_folder = dir.exists(sep_folder)
    if(!exist_sep_folder){ #Make sure that the seperate folder is created and exists
      print("Creating separate folder for bilateral segmentation...")
      dir.create(sep_folder)
    }
    
    current_file_1 = paste(base_work_path,current_ID,common_pattern,old_name,sep = "") #Left
    current_file_2 = paste(base_work_path,current_ID,common_pattern,new_name,sep = "") #Right made left
    current_file_3 = paste(base_work_path,current_ID,common_pattern,bilateral_folder,new_name,sep = "") #Right made left in sep folder
    
    #Assume file 1 and 2 exist from step 1 and 2.
    
    current_file_1_exist = file.exists(current_file_1)
    current_file_2_exist = file.exists(current_file_2)
    
    if(current_file_2_exist){
      file.copy(from = current_file_2,to = current_file_3,overwrite = overwrite_new)
    }
    else{
      warning(paste("File to copy from does not exists...",current_file_2,sep = ""))
    }
    
    current_file_3_exist = file.exists(current_file_3)
    
    if(current_file_1_exist){
      print("Starting unilateral LINDA for: (Part 1)")
      print(current_file_1)
      
      #linda_predict(current_file_1,cache = LINDA_cache)
      linda_predict_custom(current_file_1,cache = LINDA_cache)
    }
    else{
      warning(paste("LINDA PREDICTION (Part 1): This file does not exist... ",current_file,sep = ""))
    }
    
    if(current_file_3_exist){
      print("Starting unilateral LINDA for: (Part 2)")
      print(current_file_3)
      
      #linda_predict(current_file_3,cache = LINDA_cache)
      linda_predict_custom(current_file_3,cache = LINDA_cache)
    }
    else{
      warning(paste("LINDA PREDICTION (Part 2): This file does not exist... ",current_file,sep = ""))
    }
    
  }
  
}

###
# 4. Read image(s) and summarize statistics into a csv.
detach("package:ANTsR",unload = TRUE)
detach("package:ANTsRCore",unload = TRUE)
detach("package:ITKR",unload = TRUE)

num_stroke_voxels = rep(0,n_csv)
stroke_flip_csv = flip_csv

for(i in 1:n_csv){
  
  current_ID = as.character(ID_flip[i])
  current_flip = index_flip[i]
  sum_stroke = 0
  
  ################################################## Unilateral case:
  if(current_flip <= 1){
    #Use original or flipped. They are stored in the same location.
    current_file = paste(base_work_path,current_ID,common_pattern,linda_prob_pred_name,sep = "")
    
    
    print(current_file)
    current_file_exist = file.exists(current_file)
    
    if(current_file_exist){
      print("Starting collecting stats:")
      print(current_file)
      
      current_nifti = readNIfTI(current_file,reorient = FALSE)
      
      range_nifti = range(current_nifti)
      
      if(diff(range_nifti) == 0){ #Just to catch range = [0,0]
        sum_stroke = 0
      }
      else{
        thr_nifti = (current_nifti > thr_of_max*max(range_nifti))
        sum_stroke = sum(thr_nifti)
      }
      
    }
    else{
      warning(paste("Summary Stats: This file does not exist... ",current_file,sep = ""))
    }
    
  }
  
  ################################################## Bilateral case:
  if(current_flip == 2){
    #Use both hemispheres!
    
    current_file_1 = paste(base_work_path,current_ID,common_pattern,linda_prob_pred_name,sep = "")
    current_file_2 = paste(base_work_path,current_ID,common_pattern,bilateral_folder,linda_prob_pred_name,sep = "")
    
    print(current_file_1)
    print(current_file_2)
    
    current_file_exist_1 = file.exists(current_file_1)
    current_file_exist_2 = file.exists(current_file_2)
    
    if(current_file_exist_1 & current_file_exist_2){
      print("Starting collecting stats:")
      print(current_file_1)
      print(current_file_2)
      
      current_nifti_1 = readNIfTI(current_file_1,reorient = FALSE)
      current_nifti_2 = readNIfTI(current_file_2,reorient = FALSE)
      
      range_nifti_1 = range(current_nifti_1)
      range_nifti_2 = range(current_nifti_2)
      
      if(diff(range_nifti_1) == 0){ #Just to catch range = [0,0]
        sum_stroke = sum_stroke + 0
      }
      else{
        thr_nifti = (current_nifti_1 > thr_of_max*max(range_nifti_1))
        sum_stroke = sum_stroke + sum(thr_nifti)
      }
      
      if(diff(range_nifti_2) == 0){ #Just to catch range = [0,0] (NULL case)
        sum_stroke = sum_stroke + 0
      }
      else{
        thr_nifti = (current_nifti_2 > thr_of_max*max(range_nifti_2))
        sum_stroke = sum_stroke + sum(thr_nifti)
      }
      
    }
    else{
      warning(paste("Summary Stats: One or both of these files do not exist... ",current_file_1," ",current_file_2,sep = ""))
    }
    
  }
  
  num_stroke_voxels[i] = sum_stroke
  
}

stroke_flip_csv$VolStroke = num_stroke_voxels

write.csv(x = stroke_flip_csv,file = out_path_stat_csv)









