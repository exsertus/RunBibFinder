# Summary
Demo project to process images and extract bib number, resulting in "source" image being moved (and renamed) to bib number and moved into matched folder.

AWS Lambda event handles processing on S3 file upload, using Rekognition to process image. 
AWS Transfer for SFTP simply used to front-end S3 to make it more user friendly. As is the use of r53 to keep a consistent, predicatable endpoint FQDN.

Event fires when images are uploaded into inbox (for each image uploaded). Each image analysed and where there is a numeric bib detected, the image is copied into the matched folder with the bib number. Multiple bibs detected in one image will result in multiple matched files - same image, but named with each numeric bib number

# Bootstrapping
1. Git clone the repo
2. Ensure you have an AWS account and an IAM user with access key/secret key, ideally setup as a profile called "default" on the device you run Terraform from. The IAM user needs to be privilaged to create/update/destroy the components in the script (R35, IAM, S3, Lambda, Rekognition, AWS Transfer for SFTP). Essentially "admin" access.
3. Download Terraform for applicable OS
4. Run terraform init, then terraform plan, then terraform apply
5. Script will prompt for domain name (primary), this will need to be a domain managed by r53. THis step can be removed for demo purposes and the "raw" AWS Transfer for SFTP endpoint can be used, if need be.
