# This extension will enable S3 as a blobstore
## Clone the cfp-s3-blobstore-extension repository
You can apply all these changes before or after the initial deployment.<br>
**WARNING**: If you apply this after the initial deployment, anything in the blobstore will be LOST
## Setup on AWS side
1. Log into `AWS management console`
2. Open up `S3`
3. `Create bucket` you need to create 4 buckets, and the names need to be unique.<br>
    If you **DO NOT** use the names listed below, make sure you update these values in `s3-vars-template.yml`<br>
    Make sure you pick the same region for each bucket and that this region is the same one you are deploying too.
  - app-package-s3-bucket-cf
  - buildpack-s3-bucket-cf
  - droplet-s3-bucket-cf
  - resource-s3-bucket-cf

## Create the extension zip
3. Do this after you create the buckets, in case you had to change a bucket name
4. Create a zip file
```
zip -r ../cfp-s3-blobstore-extension.zip *
```
5. Copy the zip file to the IBM Cloud Foundry installer directory
6. Run, make sure you have the right path to the zip file
```
./cm extension -e cfp-s3-blobstore-extension register -p ./cfp-s3-blobstore-extension.zip
```

7. Now we add the extension to our main state file:
```
./cm states insert -i cfp-s3-blobstore-extension -n prepare-cf
```
8. At this point it is ready for use, run
```
launch_deployment.sh -c <uiconfig.file>
```

_Note: If you have trouble loading changes to the extension with the same name, do an unregister first, then register the extension again._
```
./cm extension -e cfp-s3-blobstore-extension unregister
```
