# ICD API documentation version v1
http://{ipAddress}/{version}

---

## /images

### /images

* **get**: All images
* **delete**: Delete all images

### /images/latest

* **get**: Return the most recently captured image

### /images/{id}

* **get**: Return an image for a given ID
* **put**: Update an image for a given ID
* **delete**: Delete an image for a given ID

## /cameras

### /cameras

* **get**: All cameras

### /cameras/{id}

* **get**: Return a camera for a given ID
* **put**: Update a camera for a given ID

### /cameras/{id}/settings

* **get**: Return all settings of a camera for a given ID

### /cameras/{id}/settings/{key}

* **get**: Get a setting of a camera for a given ID and key
* **put**: Update the setting of a camera for a given ID and key

## /jobs

### /jobs

* **get**: All jobs
* **post**: Create a new job

### /jobs/{id}

* **get**: Get the job with the ID provided
* **put**: Update an existing job
* **delete**: Delete a job with a given ID

## /queue

### /queue

* **get**: All queued asynchronous tasks

### /queue/{id}

* **get**: Get a single asynchronous task from the queue

