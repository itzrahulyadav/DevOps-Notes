# Openshift


## imagestreams

An image stream and its associated tags provide an abstraction for referencing container images from within OpenShift Container Platform. The image stream and its tags allow you to see what images are available and ensure that you are using the specific image you need even if the image in the repository changes.

Commands:

```
- oc get is
- oc get istag
- oc describe is/hello-world
- oc import image --confirm quay.io/practicalopenshift/hello-world

```

## S2I

Source-to-Image (S2I) is a framework that makes it easy to write images that take application source code as an input and produce a new image that runs the assembled application as output.

[Docs](https://docs.openshift.com/container-platform/3.11/creating_images/s2i.html)
