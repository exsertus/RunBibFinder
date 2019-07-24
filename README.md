AWS Lambda event for adding to an S3 bucket for detecting runner bib numbers in images.

Requires inbox, matched and unmatched dirs in bucket and that images are JPEG.

Event fires when images are uploaded into inbox (for each image uploaded). Each image analysed and where there is a numeric bib detected, the image is copied into the matched folder with the bib number. Multiple bibs detected in one image will result in multiple matched files - same image, but named with each numeric bib number
